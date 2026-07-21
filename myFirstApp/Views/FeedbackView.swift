//
//  FeedbackView.swift
//  myFirstApp
//

import SwiftUI

/// Solid heart drawn from scratch: two top lobes (arcs) meeting in a
/// notch, with bezier curves tapering to the bottom point.
struct HeartShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addCurve(
            to: CGPoint(x: rect.minX, y: rect.height / 4),
            control1: CGPoint(x: rect.width * 0.16, y: rect.height * 0.72),
            control2: CGPoint(x: rect.minX, y: rect.height * 0.48)
        )
        path.addArc(
            center: CGPoint(x: rect.width / 4, y: rect.height / 4),
            radius: rect.width / 4,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addArc(
            center: CGPoint(x: rect.width * 3 / 4, y: rect.height / 4),
            radius: rect.width / 4,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX, y: rect.height * 0.48),
            control2: CGPoint(x: rect.width * 0.84, y: rect.height * 0.72)
        )
        path.closeSubpath()
        return path
    }
}

struct FeedbackView: View {
    @EnvironmentObject private var session: UserSession
    @State private var totalTaps: Int = 0
    @State private var heartScale: CGFloat = 1.0
    @State private var showBigHeart = false
    @State private var bigHeartScale: CGFloat = 0.3
    @State private var bigHeartOpacity: Double = 0.0
    @State private var tapGeneration = 0

    var body: some View {
        ZStack {
            HPGradientBackground()

            VStack(spacing: 16) {
                Spacer()

                HookPlaygroundTitle(size: 32, twoLines: true)

                Text("Created by jiaming")
                    .font(HPFont.heading)
                    .foregroundColor(.white)
                Divider().background(.white.opacity(0.3)).padding(.horizontal, 60)

                Button {
                    if let url = URL(string: "https://www.instagram.com/rhymingjiaming/") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("Instagram @rhymingjiaming")
                        .font(HPFont.body)
                        .foregroundColor(HPColor.backgroundDark)
                        .underline()
                }

                Text("DM me anytime!")
                    .font(HPFont.body)
                    .foregroundColor(.white)

                Spacer().frame(height: 20)

                Text("Tap the green heart if you enjoyed this app")
                    .font(HPFont.caption)
                    .foregroundColor(.white.opacity(0.7))

                Button { tapHeart() } label: {
                    HeartShape()
                        .fill(HPColor.backgroundDark)
                        .frame(width: 60, height: 54)
                        .scaleEffect(heartScale)
                }
                .buttonStyle(.plain)

                Text("times tapped: \(totalTaps)")
                    .font(HPFont.subheading)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()

            // Green heart swells from the center to fill the screen, then fades
            if showBigHeart {
                HeartShape()
                    .fill(HPColor.backgroundDark)
                    .frame(width: 120, height: 110)
                    .scaleEffect(bigHeartScale)
                    .opacity(bigHeartOpacity)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()
            }
        }
        .navigationTitle("")
        .onAppear { totalTaps = UserDefaults.standard.integer(forKey: tapsKey) }
        .onChange(of: session.displayName) { _, _ in
            totalTaps = UserDefaults.standard.integer(forKey: tapsKey)
        }
    }

    /// Signed-in users get a per-account key so the count survives
    /// sign-out and is restored on their next sign-in.
    private var tapsKey: String {
        session.isSignedIn ? "heartTaps_\(session.displayName)" : "totalHeartTaps"
    }

    private func tapHeart() {
        totalTaps += 1
        UserDefaults.standard.set(totalTaps, forKey: tapsKey)

        // Little bounce on the tappable heart
        withAnimation(.spring(response: 0.2, dampingFraction: 0.45)) {
            heartScale = 1.3
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6).delay(0.12)) {
            heartScale = 1.0
        }

        // Restart the fullscreen swell from small on every tap
        tapGeneration += 1
        let generation = tapGeneration
        showBigHeart = true
        bigHeartScale = 0.3
        bigHeartOpacity = 0.95

        withAnimation(.easeOut(duration: 0.5)) {
            bigHeartScale = 18  // large enough that the heart's edges leave the screen
        }
        withAnimation(.easeIn(duration: 0.5).delay(0.45)) {
            bigHeartOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // A newer tap owns the overlay now — let its cleanup handle it
            guard generation == tapGeneration else { return }
            showBigHeart = false
            bigHeartScale = 0.3
        }
    }
}
