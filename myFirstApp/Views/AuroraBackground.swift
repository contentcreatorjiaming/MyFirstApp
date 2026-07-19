//
//  AuroraBackground.swift
//  myFirstApp
//
//  Aurora/silk-style animated background (inspired by reactbits.dev
//  "aurora" and "silk"): large blurred green-tone blobs drift slowly
//  and blend over the brand green, keeping the screen alive while the
//  user decides what to do.
//

import SwiftUI

struct AuroraBackground: View {
    @State private var phase = false

    private let deepGreen = Color(red: 0.13, green: 0.55, blue: 0.40)
    private let mint = Color(red: 0.72, green: 0.95, blue: 0.78)
    private let teal = Color(red: 0.25, green: 0.75, blue: 0.65)
    private let limeGreen = Color(red: 0.65, green: 0.90, blue: 0.55)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                HPColor.background

                Circle()
                    .fill(deepGreen.opacity(0.55))
                    .frame(width: w * 1.1)
                    .blur(radius: 70)
                    .position(x: phase ? w * 0.15 : w * 0.85, y: phase ? h * 0.15 : h * 0.45)
                    .animation(.easeInOut(duration: 9).repeatForever(autoreverses: true), value: phase)

                Circle()
                    .fill(mint.opacity(0.6))
                    .frame(width: w * 0.9)
                    .blur(radius: 60)
                    .position(x: phase ? w * 0.9 : w * 0.1, y: phase ? h * 0.75 : h * 0.35)
                    .animation(.easeInOut(duration: 7).repeatForever(autoreverses: true), value: phase)

                Circle()
                    .fill(teal.opacity(0.45))
                    .frame(width: w * 1.0)
                    .blur(radius: 80)
                    .position(x: phase ? w * 0.5 : w * 0.2, y: phase ? h * 1.0 : h * 0.6)
                    .animation(.easeInOut(duration: 11).repeatForever(autoreverses: true), value: phase)

                Circle()
                    .fill(limeGreen.opacity(0.5))
                    .frame(width: w * 0.8)
                    .blur(radius: 65)
                    .position(x: phase ? w * 0.75 : w * 0.35, y: phase ? h * 0.05 : h * 0.85)
                    .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: phase)
            }
        }
        .ignoresSafeArea()
        .onAppear { phase = true }
    }
}
