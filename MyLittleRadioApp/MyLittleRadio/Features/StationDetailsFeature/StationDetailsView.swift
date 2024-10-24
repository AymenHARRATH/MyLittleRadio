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
            let color = Color(hex: store.station.colors.primary)
            VStack {
                StationCoverImageView(
                    squareImageUrl: store.station.assets?.squareImageUrl,
                    color: color,
                    text: store.station.shortTitle
                )
                .frame(width: 200, height: 200)
                .shadow(radius: 5)
                
                stationTitleView()
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
        let color = Color(hex: store.station.colors.primary)
        VStack {
            if store.mode.is(\.playing) {
                RadioPlayingAnimationView(color: color.opacity(0.3))
            }
            ZStack {
                Button(action: {
                    store.send(.playPauseButtonTapped)
                }) {
                    playerButtonImage()
                }
                .tint(.white)
                if store.mode.is(\.loading) {
                    ProgressView()
                        .controlSize(.large)
                        .tint(color)
                }
            }
        }
    }
    
    private func playerButtonImage() -> some View {
        let image: String
        switch store.mode {
        case .playing:
            image = "stop.circle.fill"
        case .loading:
            image = "circle.fill"
        case .notPlaying:
            image = "play.circle.fill"
        }
        return Image(systemName: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
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
    let store = Store(initialState: StationDetailsFeature.State(station: Station.sample,
                                                                mode: .playing)) {
        StationDetailsFeature()
    }
    StationDetailsView(store: store)
}
