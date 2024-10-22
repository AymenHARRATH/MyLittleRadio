//
//  PlayerClient+Dependency.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 22/10/2024.
//

import Dependencies

extension DependencyValues {
  var player: PlayerClient {
    get { self[PlayerClient.self] }
    set { self[PlayerClient.self] = newValue }
  }
}

extension PlayerClient: DependencyKey {
    public static let liveValue: Self = {
        let manager = PlayerManager()
        return Self { url in
            await manager.play(url: url)
        } pause: {
            await manager.pause()
        }
    }()
}

extension PlayerClient: TestDependencyKey {
    public static let previewValue = Self()
    public static let testValue = Self()
}
