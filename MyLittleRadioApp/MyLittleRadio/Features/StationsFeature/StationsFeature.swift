// Copyright © Radio France. All rights reserved.

import ComposableArchitecture

@Reducer
struct StationsFeature {

    @ObservableState
    struct State: Equatable {
        var stations: [Station] = []
        var path = StackState<StationDetailsFeature.State>()
        @Presents var alert: AlertState<Action.Alert>?
        var isLoading: Bool = false
        var playingStation: Station? = nil
    }

    enum Action {
        case fetchStations
        case setStations([Station])
        
        case path(StackAction<StationDetailsFeature.State, StationDetailsFeature.Action>)

        enum Alert: Equatable {
            case retryRequest
        }
        case fetchStationsFailure(Error)
        case alert(PresentationAction<Alert>)
        
        case updatePlayerState(PlayerState)
        
        case task
    }

    // MARK: - Dependencies

    @Dependency(\.apiClient)
    private var apiClient
    @Dependency(\.player)
    private var player

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .fetchStations:
                return .run { send in
                    let stations = try await apiClient.fetchStations()
                    await send(.setStations(stations))
                } catch: { error, send in
                    await send(.fetchStationsFailure(error))
                }
                
            case let .setStations(stations):
                state.isLoading = false
                state.stations = stations
                return .none
                
            case .task:
                state.isLoading = true
                return .run { send in
                    await send(.fetchStations)
                    for await playerState in await player.playerStateObserver() {
                        await send(.updatePlayerState(playerState))
                    }
                }
                
            case .path:
                return .none
                
            case let .updatePlayerState(playerState):
                if playerState.isPlaying {
                    state.playingStation = state.stations.first {
                        $0.streamUrl == playerState.playingURL
                    }
                } else if playerState.isStopped {
                    state.playingStation = nil
                }
                return .none
            case let .fetchStationsFailure(error):
                state.isLoading = false
                state.alert = .fechStationsFailureState(error)
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

extension AlertState where Action == StationsFeature.Action.Alert {
    static func fechStationsFailureState(_ error: Error) -> Self {
    Self  {
        let message = (error as? APIError)?.localizedDescription ?? "Une erreur est survenue lors de la récupération des stations radio. \n Voulez-vous réessayer?"
        return TextState(message)
      } actions: {
          ButtonState(action: .retryRequest) {
          TextState("Réessayer")
        }
          ButtonState(role: .cancel) {
              TextState("Annuler")
          }
      }
  }
}

