//
//  StationDetailsView.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 19/10/2024.
//

import SwiftUI

import ComposableArchitecture

struct StationDetailsView: View {
    
    @Perception.Bindable private var store: StoreOf<StationDetailsFeature>

    init(store: StoreOf<StationDetailsFeature>) {
        self.store = store
    }

    var body: some View {
        Text(store.station.title)
    }
}

#Preview {
    let store = Store(initialState: StationDetailsFeature.State(station: Station.sample)) {
        StationDetailsFeature()
    }
    StationDetailsView(store: store)
}
