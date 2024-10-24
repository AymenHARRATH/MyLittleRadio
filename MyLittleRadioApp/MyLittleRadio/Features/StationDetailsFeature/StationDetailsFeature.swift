//
//  StationDetailsFeature.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 19/10/2024.
//

import ComposableArchitecture

@Reducer
struct StationDetailsFeature {
    
    @ObservableState
    struct State: Equatable {
        let station: Station
        var mode = Mode.notPlaying
    }

    enum Action {
        case updatePlayerState(PlayerState)
        case playPauseButtonTapped
        case backButtonTapped
    }
    
    @CasePathable
    @dynamicMemberLookup
    enum Mode: Equatable {
        case notPlaying
        case playing
        case loading
    }

    
    @Dependency(\.player) var player
    private enum CancelID { case play }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case let .updatePlayerState(playerState):
                switch playerState {
                case .playing:
                    state.mode = .playing
                case .stopped:
                    state.mode = .notPlaying
                case .loading:
                    state.mode = .loading
                }
                return .none
            case .playPauseButtonTapped:
                switch state.mode {
                case .notPlaying:
                    return .run { [url = state.station.streamUrl] send in
                        for await playerState in await player.play(url: url) {
                            await send(.updatePlayerState(playerState))
                        }
                    }
                    .cancellable(id: CancelID.play, cancelInFlight: true)
                case .playing:
                    return .merge (
                        .run { send in
                            await player.stop()
                            await send(.updatePlayerState(.stopped))
                        },
                        .cancel(id: CancelID.play)
                    )
                case .loading:
                    return .none
                }
            case .backButtonTapped:
                return .run { send in
                    await player.stop()
                }
            }
        }
    }

}
