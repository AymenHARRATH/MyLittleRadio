//
//  PlayerManager.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 22/10/2024.
//

import Foundation
import AVFoundation
import Combine

enum PlayerState {
    case playing
    case loading
    case stopped
}

final class PlayerManager {
    private var delegate: Delegate?
    
    func play(url: String) async -> AsyncStream<PlayerState> {
        
        guard let url = URL(string: url) else {
            return .finished
        }
        
        return AsyncStream<PlayerState> { continuation in
            delegate = Delegate(
                url: url,
                continuation: continuation
            )
            delegate?.play()
        }
    }
    
    func stop() async {
        delegate?.stop()
    }
}

final class Delegate {
    
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    private var cancellables = Set<AnyCancellable>()
    
    init(url: URL, continuation: AsyncStream<PlayerState>.Continuation) {
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)

        playerItem?.publisher(for: \.status)
            .sink { status in
                switch status {
                case .readyToPlay:
                    continuation.yield(.loading)
                case .failed:
                    continuation.yield(.stopped)
                case .unknown:
                    continuation.yield(.loading)
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        player?.publisher(for: \.timeControlStatus)
            .sink { status in
                switch status {
                case .playing:
                    continuation.yield(.playing)
                case .waitingToPlayAtSpecifiedRate:
                    continuation.yield(.loading)
                case .paused:
                    continuation.yield(.stopped)
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
        
        player?.publisher(for: \.rate)
            .sink { rate in
                if rate == 0 {
                    continuation.yield(.stopped)
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
