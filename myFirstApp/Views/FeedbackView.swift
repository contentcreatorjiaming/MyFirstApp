//
//  FeedbackView.swift
//  myFirstApp
//

import SwiftUI

struct FeedbackView: View {
    @EnvironmentObject private var session: UserSession
    @AppStorage("totalHeartTaps") private var totalTaps: Int = 0
    @AppStorage("userHasTappedV2") private var userHasTapped: Bool = false
    @State private var heartScale: CGFloat = 1.0
    @State private var heartOpacity: Double = 0.0
    @State private var showBigHeart = false

    var body: some View {
        ZStack {
            HPGradientBackground()

            VStack(spacing: 16) {
                Spacer()

                HookPlaygroundTitle(size: 32, twoLines: true)

                Text("created by jiaming")
                    .font(HPFont.heading)
                    .foregroundColor(.white)
                Divider().background(.white.opacity(0.3)).padding(.horizontal, 60)

                Button {
                    if let url = URL(string: "https://www.instagram.com/rhymingjiaming/") {
                        UIApplication.shared.open(url)
                    }
                } label: {
                    Text("instagram @rhymingjiaming")
                        .font(HPFont.body)
                        .foregroundColor(HPColor.backgroundDark)
                        .underline()
                }

                Text("DM me anytime!")
                    .font(HPFont.body)
                    .foregroundColor(.white)

                Spacer().frame(height: 20)

                Text("tap the green heart if you enjoyed this app")
                    .font(HPFont.caption)
                    .foregroundColor(.white.opacity(0.7))

                Button { tapHeart() } label: {
                    Text("💚")
                        .font(.system(size: 60))
                        .scaleEffect(heartScale)
                }
                .buttonStyle(.plain)

                Text("users tapped: \(totalTaps)")
                    .font(HPFont.subheading)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()

            // Full-screen green heart swell
            if showBigHeart {
                Color.green.opacity(heartOpacity)
                    .ignoresSafeArea()
                    .overlay(
                        Text("💚")
                            .font(.system(size: 200))
                            .scaleEffect(heartScale)
                            .opacity(heartOpacity)
                    )
                    .allowsHitTesting(false)
            }
        }
        .navigationTitle("")
    }

    private func tapHeart() {
        if !session.isSignedIn && !userHasTapped {
            userHasTapped = true
            totalTaps += 1
        }

        // Animate regardless (visual feedback even if count doesn't change)
        showBigHeart = true
        heartScale = 0.5
        heartOpacity = 0.8

        withAnimation(.easeOut(duration: 0.4)) {
            heartScale = 4.0
            heartOpacity = 0.9
        }

        withAnimation(.easeIn(duration: 0.8).delay(0.4)) {
            heartOpacity = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.3) {
            showBigHeart = false
            heartScale = 1.0
        }
    }
}
