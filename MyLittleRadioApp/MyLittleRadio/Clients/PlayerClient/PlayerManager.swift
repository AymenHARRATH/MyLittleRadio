//
//  PlayerManager.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 22/10/2024.
//

import Foundation
import AVFoundation
import Combine

struct PlayerState {
    enum Status {
        case playing
        case loading
        case stopped
    }
    var status: Status = .stopped
    var playingURL: String?
    
    init(status: Status, playingURL: String? = nil) {
        self.status = status
        self.playingURL = playingURL
    }
    
    var isPlaying: Bool {
        status == .playing
    }
    var isStopped: Bool {
        status == .stopped
    }
}

final class PlayerManager {
    private var delegate: Delegate?
    func play(url: String) async throws {
        guard let url = URL(string: url) else {
            throw(URLError(.badURL))
        }
        delegate = Delegate(url: url)
        delegate?.play()
    }
    
    func stop() async {
        delegate?.stop()
    }
    
    func playerState() async -> AsyncStream<PlayerState> {
        .init {
            delegate?.observePlayerState($0)
        }
    }
}

final class Delegate {
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var cancellables = Set<AnyCancellable>()
    private(set) var url: URL
    
    init(url: URL) {
        self.url = url
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
    }
    
    func observePlayerState(_ continuation: AsyncStream<PlayerState>.Continuation) {
        playerItem?.publisher(for: \.status)
            .sink { [weak self] status in
                switch status {
                case .readyToPlay:
                    continuation.yield(.init(status: .loading, playingURL: self?.url.absoluteString))
                case .failed:
                    continuation.yield(.init(status: .stopped, playingURL: self?.url.absoluteString))
                case .unknown:
                    continuation.yield(.init(status: .loading, playingURL: self?.url.absoluteString))
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        player?.publisher(for: \.timeControlStatus)
            .sink { [weak self] status in
                switch status {
                case .playing:
                    continuation.yield(.init(status: .playing, playingURL: self?.url.absoluteString))
                case .waitingToPlayAtSpecifiedRate:
                    continuation.yield(.init(status: .loading, playingURL: self?.url.absoluteString))
                case .paused:
                    continuation.yield(.init(status: .stopped, playingURL: self?.url.absoluteString))
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        player?.publisher(for: \.rate)
            .sink { [weak self] rate in
                if rate == 0 {
                    continuation.yield(.init(status: .stopped, playingURL: self?.url.absoluteString))
                }
            }
            .store(in: &cancellables)
    }
    
    func play() {
        player?.play()
    }
    
    func stop() {
        player?.pause()
        playerItem = nil
        player = nil
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
