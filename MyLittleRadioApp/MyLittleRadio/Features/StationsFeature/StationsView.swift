// Copyright © Radio France. All rights reserved.

import SwiftUI

import ComposableArchitecture

struct StationsView: View {

    @Perception.Bindable private var store: StoreOf<StationsFeature>

    @State var selectedStation: Station?

    init(store: StoreOf<StationsFeature>) {
        self.store = store
    }

    var body: some View {
        WithPerceptionTracking {
            NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(store.stations) { station in
                            NavigationLink(state: StationDetailsFeature.State(station: station)) {
                                HStack(spacing: 8) {
                                    Text(station.title)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .frame(height: 50)
                            }
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
