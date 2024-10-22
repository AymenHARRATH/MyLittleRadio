// Copyright © Radio France. All rights reserved.

import ComposableArchitecture

@Reducer
struct StationsFeature {

    @ObservableState
    struct State: Equatable {
        var stations: [Station] = []
        var path = StackState<StationDetailsFeature.State>()
        @Presents var alert: AlertState<Action.Alert>?
    }

    enum Action {
        case fetchStations
        case setStations([Station])
        
        case path(StackAction<StationDetailsFeature.State, StationDetailsFeature.Action>)

        enum Alert: Equatable {
            case retryRequest
        }
        case fetchStationsFailure
        case alert(PresentationAction<Alert>)
        
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
                    let stations = try await apiClient.fetchStations()
                    await send(.setStations(stations))
                } catch: { error, send in
                    await send(.fetchStationsFailure)
                }
                
            case let .setStations(stations):
                state.stations = stations
                return .none
                
            case .task:
                return .run { send in
                    await send(.fetchStations)
                }
                
            case .path:
                return .none
                
            case .fetchStationsFailure:
                state.alert = AlertState {
                  TextState("Une erreur est survenue lors de la récupération des stations radio. \n Voulez-vous réessayer?")
                } actions: {
                    ButtonState(action: .retryRequest) {
                    TextState("Réessayer")
                  }
                    ButtonState(role: .cancel) {
                        TextState("Annuler")
                    }
                }
                return .none
                
            case .alert(.presented(.retryRequest)):
                return .run { send in
                    await send(.fetchStations)
                }
                
            case .alert:
              return .none
            }
        }
        .forEach(\.path, action: \.path) {
            StationDetailsFeature()
        }
        .ifLet(\.$alert, action: \.alert)
    }
}
