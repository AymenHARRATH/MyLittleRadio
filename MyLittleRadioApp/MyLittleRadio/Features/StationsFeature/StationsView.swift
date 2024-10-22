// Copyright © Radio France. All rights reserved.

import SwiftUI

import ComposableArchitecture

struct StationsView: View {

    @Perception.Bindable private var store: StoreOf<StationsFeature>

    init(store: StoreOf<StationsFeature>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(store.stations) { station in
                            stationCell(station)
                        }
                    }
                }
                .navigationTitle("Radios")
            } destination: { store in
                StationDetailsView(store: store)
            }
        }
        .task {
            store.send(.task)
        }
        .alert($store.scope(state: \.alert, action: \.alert))
    }
}

private extension StationsView {
    func stationCell(_ station: Station) -> some View {
        NavigationLink(state: StationDetailsFeature.State(station: station)) {
            HStack(spacing: 8) {
                Text(station.title)
                Spacer()
                Image(systemName: "chevron.right")
            }
            .padding()
            .frame(height: 50)
        }
        .tint(.black)
    }
}

#if DEBUG
#Preview {
    let store = Store(initialState: StationsFeature.State()) {
        StationsFeature()
    }
    StationsView(store: store)
}
#endif
