//
//  SwipeCardView.swift
//  myFirstApp
//
//  Tinder-style swipeable card for test hooks. Swipe right = Stay,
//  swipe left = Swipe. Background gradient shifts as user drags.
//

import SwiftUI

struct SwipeCardView: View {
    let hook: Hook
    let onStay: () -> Void
    let onSwipe: () -> Void

    @State private var dragOffset: CGFloat = 0
    @State private var dismissed = false

    private let swipeThreshold: CGFloat = 120

    private var dragProgress: CGFloat {
        min(max(dragOffset / swipeThreshold, -1), 1)
    }

    var body: some View {
        ZStack {
            // Color-shifting gradient
            LinearGradient(
                colors: gradientColors,
                startPoint: .leading,
                endPoint: .trailing
            )
            .ignoresSafeArea()
            .animation(.easeOut(duration: 0.15), value: dragProgress)

            VStack(spacing: 20) {
                // Big centered title
                HookPlaygroundTitle(size: 32, twoLines: true)
                    .padding(.top, 20)

                // Direction indicator
                if abs(dragProgress) > 0.3 {
                    Text(dragProgress > 0 ? "STAY" : "SWIPE")
                        .font(HPFont.brand(size: 32))
                        .foregroundColor(.white)
                        .opacity(Double(abs(dragProgress)))
                        .transition(.opacity)
                }

                // The card
                cardContent
                    .offset(x: dragOffset)
                    .rotationEffect(.degrees(Double(dragOffset) / 20))
                    .gesture(swipeGesture)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: dragOffset)

                // Button row
                HStack(spacing: 40) {
                    Button {
                        dismissCard(direction: .left)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "xmark")
                                .font(.title)
                            Text("SWIPE")
                                .font(HPFont.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(HPColor.backgroundDark.opacity(0.8))
                        .clipShape(Circle())
                    }

                    Button {
                        dismissCard(direction: .right)
                    } label: {
                        VStack(spacing: 4) {
                            Image(systemName: "checkmark")
                                .font(.title)
                            Text("STAY")
                                .font(HPFont.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 80)
                        .background(HPColor.backgroundDark.opacity(0.8))
                        .clipShape(Circle())
                    }
                }
            }
            .padding()
        }
    }

    // MARK: - Card content

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let text = hook.textContent {
                Text(text)
                    .font(HPFont.heading)
                    .foregroundColor(HPColor.backgroundDark)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else if hook.kind == .video {
                HStack {
                    Image(systemName: "video.fill")
                        .font(.title)
                    Text("Video Hook")
                        .font(HPFont.heading)
                }
                .foregroundColor(HPColor.backgroundDark)
            }

            HStack {
                Text("by \(hook.authorDisplayName)")
                    .font(HPFont.caption)
                    .foregroundColor(HPColor.backgroundDark.opacity(0.6))
                Spacer()
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, minHeight: 200, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
    }

    // MARK: - Gradient

    // Transparent when idle so the aurora background shows through;
    // tints blue/pink as the user drags toward stay/swipe.
    private var gradientColors: [Color] {
        if dragProgress > 0.1 {
            return [Color.clear, HPColor.pastelBlue.opacity(Double(dragProgress) * 0.8)]
        } else if dragProgress < -0.1 {
            return [HPColor.pastelPink.opacity(Double(abs(dragProgress)) * 0.8), Color.clear]
        }
        return [Color.clear, Color.clear]
    }

    // MARK: - Gesture

    private var swipeGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation.width
            }
            .onEnded { value in
                if value.translation.width > swipeThreshold {
                    dismissCard(direction: .right)
                } else if value.translation.width < -swipeThreshold {
                    dismissCard(direction: .left)
                } else {
                    dragOffset = 0
                }
            }
    }

    private enum Direction { case left, right }

    private func dismissCard(direction: Direction) {
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = direction == .right ? 500 : -500
            dismissed = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if direction == .right {
                onStay()
            } else {
                onSwipe()
            }
        }
    }
}
