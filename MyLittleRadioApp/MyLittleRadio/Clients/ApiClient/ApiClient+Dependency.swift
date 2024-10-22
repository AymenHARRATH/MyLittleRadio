// Copyright © Radio France. All rights reserved.

import Dependencies

extension DependencyValues {

    var apiClient: ApiClient {
        get { self[ApiClient.self] }
        set { self[ApiClient.self] = newValue }
    }
}

extension ApiClient: DependencyKey {

    public static let liveValue: Self = {
        let manager = ApiManager()

        return Self(
            fetchStations: { try await manager.fetchStations() }
        )
    }()
}


extension ApiClient: TestDependencyKey {

    public static let previewValue = Self { [Station.sample] }
    public static let testValue = Self()
}


