//
//  StationCoverImageView.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 23/10/2024.
//

import SwiftUI

struct StationCoverImageView: View {
    private var squareImageUrl: String?
    private var color: Color
    private var text: String
    
    init(squareImageUrl: String? = nil, color: Color, text: String) {
        self.squareImageUrl = squareImageUrl
        self.color = color
        self.text = text
    }
    
    var body: some View {
            if let squareImageUrl,
               let url = URL(string: squareImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        placeholderView(color: color, text: text)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(12)
                    case .failure:
                        placeholderView(color: color, text: text)
                    @unknown default:
                        placeholderView(color: color, text: text)
                    }
                }
            } else {
                placeholderView(color: color, text: text)
            }
    }
}

private extension StationCoverImageView {
    func placeholderView(color: Color, text: String) -> some View {
        ZStack {
            Rectangle()
                .fill(color.opacity(0.5).gradient)
                .cornerRadius(12)
            Text(text)
                .padding(.horizontal, 2)
                .font(.title)
                .foregroundColor(.white.opacity(0.5))
                .lineLimit(1)
                .minimumScaleFactor(0.1) 
                .allowsTightening(true)
        }
    }
}

#Preview {
    StationCoverImageView(color: .gray, text: "Culture")
        .frame(width: 80, height: 80)
}
