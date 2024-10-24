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
            ZStack {
                NavigationStack(path: $store.scope(state: \.path, action: \.path))
                {
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
                
                if store.isLoading {
                    ProgressView()
                        .controlSize(.large)
                }
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
        let mode: StationDetailsFeature.Mode = store.playingStation == station  ? .playing : .notPlaying
        NavigationLink(state: StationDetailsFeature.State(station: station, mode: mode)) {
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
                    if store.playingStation == station {
                        RadioPlayingAnimationView(color: color,
                                                  duration: 0.3,
                                                  barsHeight: 30,
                                                  numberOfBars: 6)
                            .frame(width: 40, height: 30)
                            .padding([.bottom, .trailing], 10)
                    }
                    Text(station.isMusical ? "🎵" : "🎙")
                    Image(systemName: "chevron.right")
                        .tint(color)
                }
                .padding(16)
            }
            .padding(.horizontal)
        }
    }
}

#if DEBUG
#Preview {
    let store = Store(initialState: StationsFeature.State(playingStation: Station.sample)) {
        StationsFeature()
    }
    StationsView(store: store)
}
#endif
