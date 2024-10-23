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
    @ViewBuilder
    func stationCell(_ station: Station) -> some View {
        let color = Color(hex: station.colors.primary)
        NavigationLink(state: StationDetailsFeature.State(station: station)) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: color.opacity(0.2), radius: 10, x: 0, y: 5)
                HStack(spacing: 8) {
                    StationCoverImageView(
                        squareImageUrl: station.assets?.squareImageUrl,
                        color: color,
                        text: station.shortTitle
                    )
                    .frame(width: 40, height: 40)
                    Text(station.title)
                        .foregroundColor(color)
                    
                    Spacer()
                    
                    Text(station.isMusical ? "🎵" : "🎙")
                    Image(systemName: "chevron.right")
                        .tint(color)
                }
                .padding(16)
            }
            .padding(.horizontal)
            .frame(height: 70)
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
