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
    var play: @Sendable (_ url: String) async throws -> Void
    var playerStateObserver: @Sendable () async -> AsyncStream<PlayerState> = {  .finished }
    var stop: @Sendable () async -> Void
}
