// Copyright © Radio France. All rights reserved.

import ComposableArchitecture

@Reducer
struct StationsFeature {

    @ObservableState
    struct State: Equatable {
        var stations: [Station] = []
    }

    enum Action {
        case fetchStations
        case setStations([Station])

        case task
    }

    // MARK: - Dependencies

    @Dependency(\.apiClient)
    private var apiClient

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
                case .fetchStations:
                    return .run { send in
                        if let stations = try? await apiClient.fetchStations() {
                            await send(.setStations(stations))
                        }
                    }
                case let .setStations(stations):
                    state.stations = stations
                    return .none

                case .task:
                    return .run { send in
                        await send(.fetchStations)
                    }
            }
        }
    }
}
