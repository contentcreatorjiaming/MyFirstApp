//
//  FeedbackView.swift
//  myFirstApp
//
//  Creator credits page with tappable heart animation.
//

import SwiftUI

struct FeedbackView: View {
    @AppStorage("totalHeartTaps") private var totalTaps: Int = 0
    @State private var showHearts = false
    @State private var heartPositions: [CGPoint] = []

    var body: some View {
        ZStack {
            HPGradientBackground()

            VStack(spacing: 20) {
                Spacer()

                Text("created by jiaming")
                    .font(HPFont.heading)
                    .foregroundColor(.white)
                Divider().background(.white.opacity(0.3))
                Text("instagram @rhymingjiaming")
                    .font(HPFont.body)
                    .foregroundColor(.white.opacity(0.85))

                Spacer().frame(height: 20)

                Text("DM me anytime!")
                    .font(HPFont.body)
                    .foregroundColor(.white)

                Button {
                    tapHeart()
                } label: {
                    Text("💚")
                        .font(.system(size: 60))
                        .scaleEffect(showHearts ? 1.3 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.5), value: showHearts)
                }
                .buttonStyle(.plain)

                Text("tap the green heart if you enjoyed this app")
                    .font(HPFont.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)

                Text("users tapped: \(totalTaps)")
                    .font(HPFont.subheading)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()

            // Heart explosion animation
            ForEach(0..<heartPositions.count, id: \.self) { i in
                Text("💚")
                    .font(.system(size: 24))
                    .position(heartPositions[i])
                    .opacity(showHearts ? 0 : 1)
                    .animation(.easeOut(duration: 2.0).delay(Double(i) * 0.05), value: showHearts)
            }
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 16) } }
    }

    private func tapHeart() {
        totalTaps += 1
        showHearts = true

        // Generate heart positions in a heart-like shape
        heartPositions = (0..<20).map { i in
            let angle = Double(i) / 20.0 * 2 * .pi
            let r: CGFloat = 120
            let x = UIScreen.main.bounds.width / 2 + r * CGFloat(sin(angle)) * CGFloat(1 + cos(angle)) / 2
            let y = 300 - r * CGFloat(cos(angle))
            return CGPoint(x: x, y: y)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            showHearts = false
            heartPositions = []
        }
    }
}
