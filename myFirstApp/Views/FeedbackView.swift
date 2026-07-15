//
//  FeedbackView.swift
//  myFirstApp
//

import SwiftUI

struct FeedbackView: View {
    @AppStorage("totalHeartTaps") private var totalTaps: Int = 0
    @AppStorage("userHasTapped") private var userHasTapped: Bool = false
    @State private var showHeartSwell = false

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
                }
                .buttonStyle(.plain)

                Text("users tapped: \(totalTaps)")
                    .font(HPFont.subheading)
                    .foregroundColor(.white)

                Spacer()
            }
            .padding()

            // Heart swell animation
            if showHeartSwell {
                Text("💚")
                    .font(.system(size: 300))
                    .opacity(showHeartSwell ? 0 : 1)
                    .scaleEffect(showHeartSwell ? 3 : 0.5)
                    .animation(.easeOut(duration: 1.5), value: showHeartSwell)
            }
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) } }
    }

    private func tapHeart() {
        guard !userHasTapped else { return }
        userHasTapped = true
        totalTaps += 1
        showHeartSwell = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showHeartSwell = false
        }
    }
}
