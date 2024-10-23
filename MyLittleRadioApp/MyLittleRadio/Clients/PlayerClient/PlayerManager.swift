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
            delegate?.player.play()
        }
    }
    
    func pause() async {
        delegate?.player.pause()
    }
}

final class Delegate: NSObject {
    
    let player: AVPlayer
    private var cancellables = Set<AnyCancellable>()
    
    init(url: URL, continuation: AsyncStream<PlayerState>.Continuation) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        super.init()
        
        playerItem.publisher(for: \.status)
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
        
        player.publisher(for: \.timeControlStatus)
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
        
        player.publisher(for: \.rate)
            .sink { rate in
                if rate == 0 {
                    continuation.yield(.stopped)
                }
            }
            .store(in: &cancellables)
    }
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}
