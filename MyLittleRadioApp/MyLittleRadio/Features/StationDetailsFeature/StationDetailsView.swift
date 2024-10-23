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
        WithPerceptionTracking {
            VStack {
                StationCoverImageView(
                    squareImageUrl: store.station.assets?.squareImageUrl,
                    color: Color(hex: store.station.colors.primary),
                    text: store.station.shortTitle
                )
                .frame(width: 200, height: 200)
                .shadow(radius: 5)
                
                stationTitleView()
                if store.mode.is(\.loading) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(Color(hex: store.station.colors.primary))
                }
                Spacer()
                playerView()
            }
            .padding([.top, .bottom], 50)
            .frame(maxWidth: .infinity)
            .background(
                gradient()
            )
        }
    }
}

private extension StationDetailsView {
    
    func stationTitleView() -> some View {
        Text(store.station.title)
            .font(.largeTitle)
            .bold()
            .foregroundColor(Color(hex: store.station.colors.primary))
            .padding(.top)
    }
    
    @ViewBuilder
    func playerView() -> some View {
        VStack {
            if store.mode.is(\.playing) {
                RadioPlayingAnimationView(color: Color(hex: store.station.colors.primary).opacity(0.3))
            }
            Button(action: {
                store.send(.playPauseButtonTapped)
            }) {
                Image(systemName: store.mode.is(\.playing) ? "stop.circle.fill" : "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            }
            .tint(.white)
        }
    }
    
    func gradient() -> some View {
        LinearGradient(
            gradient: Gradient(colors: [Color(hex: store.station.colors.primary).opacity(0.5), .clear]),
            startPoint: .bottom,
            endPoint: .top
        )
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    let store = Store(initialState: StationDetailsFeature.State(station: Station.sample)) {
        StationDetailsFeature()
    }
    StationDetailsView(store: store)
}
