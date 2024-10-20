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
    }

    enum Action {
        case play
    }

    var body: some ReducerOf<Self> {
        Reduce<State, Action> { state, action in
            switch action {
            case .play:
                return .none
            }
        }
    }
}
