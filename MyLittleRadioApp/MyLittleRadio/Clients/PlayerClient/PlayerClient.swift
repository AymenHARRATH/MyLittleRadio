//
//  PlayerClient.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 22/10/2024.
//

import Foundation
import ComposableArchitecture

@DependencyClient
struct PlayerClient {
    var play: @Sendable (_ url: String) async -> AsyncStream<PlayerState> = { _ in .finished }
    var pause: @Sendable () async -> Void
}
