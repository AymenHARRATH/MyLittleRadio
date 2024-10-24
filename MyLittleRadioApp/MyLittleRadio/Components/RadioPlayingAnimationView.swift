//
//  RadioPlayingAnimationView.swift
//  MyLittleRadio
//
//  Created by HARRATH Aymen on 23/10/2024.
//
import SwiftUI

struct RadioPlayingAnimationView: View {

    @State private var isPlaying: Bool = false
    private var color: Color
    private var duration: Double
    private var barsHeight: CGFloat
    private var numberOfBars: Int

    init(color: Color,
         duration: Double = 0.5,
         barsHeight: CGFloat = 120,
         numberOfBars: Int = 100) {
        self.color = color
        self.duration = duration
        self.barsHeight = barsHeight
        self.numberOfBars = numberOfBars
    }
    
    var body: some View {
        HStack {
            ForEach(0..<numberOfBars, id: \.self) { _ in
                let speed = Double.random(in: 0.5...1.5)
                bar(fraction: CGFloat.random(in: 0.2...0.6))
                    .animation(
                        .linear(duration: duration).repeatForever().speed(speed),
                        value: isPlaying
                    )
            }
        }
        .onAppear {
            isPlaying.toggle()
        }
    }
    
    func bar(fraction: CGFloat = 0.0) -> some View {
        RoundedRectangle(cornerRadius: 3)
            .fill(color.gradient)
            .frame(width: 3)
            .frame(height: (isPlaying ? 1 : fraction) * barsHeight)
            .frame(height: barsHeight, alignment: .bottom)
    }
}

#Preview {
    RadioPlayingAnimationView(color: .cyan)
}
