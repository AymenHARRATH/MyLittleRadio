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
    
    @ViewBuilder
    func coverImageView() -> some View {
        if let imageUrl = store.station.assets?.squareImageUrl,
           let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: 200, height: 200)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                        .shadow(radius: 5)
                        .frame(width: 200, height: 200)
                case .failure:
                    placeholderView()
                @unknown default:
                    placeholderView()
                }
            }
        } else {
            placeholderView()
        }
    }
    
    func placeholderView() -> some View {
        ZStack {
            Rectangle()
                .fill(Color(hex: store.station.colors.primary).opacity(0.5).gradient)
                .frame(width: 200, height: 200)
                .cornerRadius(12)
                .shadow(radius: 5)

            Text(store.station.shortTitle.capitalized)
                .font(.title)
                .foregroundColor(.white.opacity(0.5))
        }
    }

    func stationTitleView() -> some View {
        Text(store.station.title)
            .font(.largeTitle)
            .bold()
            .foregroundColor(Color(hex: store.station.colors.primary))
            .padding(.top)
    }
    
    func playerView() -> some View {
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
