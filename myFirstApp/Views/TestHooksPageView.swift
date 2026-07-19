//
//  TestHooksPageView.swift
//  myFirstApp
//
//  Tinder-style swipe experience for test hooks. Users swipe through
//  one hook at a time, with gradient background shifting as they drag.
//

import SwiftUI

struct TestHooksPageView: View {
    @EnvironmentObject private var store: HookStore
    @EnvironmentObject private var reactionStore: ReactionStore
    @EnvironmentObject private var session: UserSession

    @State private var currentIndex = 0
    @State private var showFeedback = false
    @State private var lastReactionType: ReactionType?
    @State private var lastHookID: UUID?
    @State private var feedbackText = ""
    @State private var showSentMessage = false
    @State private var feedbackDragOffset: CGFloat = 0

    private var testHooks: [Hook] {
        store.hooks.filter { $0.source == .testNew }
    }

    var body: some View {
        ZStack {
            HPGradientBackground()

            if !session.isSignedIn {
                signInPrompt
            } else if testHooks.isEmpty {
                emptyState
            } else if currentIndex >= testHooks.count {
                completionState
            } else if showFeedback {
                feedbackPrompt
            } else {
                SwipeCardView(
                    hook: testHooks[currentIndex],
                    onStay: { react(.stay) },
                    onSwipe: { react(.swipe) }
                )
            }

            // "Sent!" flash
            if showSentMessage {
                Text("Sent!")
                    .font(HPFont.brand(size: 28))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(HPColor.backgroundDark.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .navigationTitle("")
        
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.clear, for: .navigationBar)
    }

    // MARK: - React

    private func react(_ type: ReactionType) {
        guard session.isSignedIn else { return }
        let hook = testHooks[currentIndex]

        if reactionStore.hasReacted(hookID: hook.id, author: session.displayName) {
            reactionStore.switchReaction(hookID: hook.id, author: session.displayName, to: type)
        } else {
            reactionStore.add(Reaction(
                id: UUID(), hookID: hook.id, type: type,
                feedback: nil, authorDisplayName: session.displayName, createdAt: Date()
            ))
        }
        lastReactionType = type
        lastHookID = hook.id
        showFeedback = true
    }

    private func skipFeedback() {
        showFeedback = false
        feedbackText = ""
        feedbackDragOffset = 0
        currentIndex += 1
    }

    private func submitFeedback() {
        if let id = lastHookID, !feedbackText.trimmingCharacters(in: .whitespaces).isEmpty {
            reactionStore.updateFeedback(for: id, author: session.displayName, feedback: feedbackText)
        }
        showSentMessage = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            showSentMessage = false
            skipFeedback()
        }
    }

    // MARK: - States

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "flask")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            Text("No test hooks yet")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("Submit a hook via Create → Test\nto see it here.")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var signInPrompt: some View {
        VStack(spacing: 20) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 50))
                .foregroundColor(.white.opacity(0.6))
            Text("Sign in to play")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("Create an account to swipe on hooks\nand leave feedback.")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            NavigationLink {
                SignInGateView()
            } label: {
                Text("SIGN IN")
            }
            .buttonStyle(HPSecondaryButtonStyle())
        }
    }

    private var completionState: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 60))
            Text("You've reviewed all hooks!")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("\(testHooks.count) hooks rated")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.7))
            HStack(spacing: 14) {
                NavigationLink { SavedHooksView() } label: { Text("SEE MY RATINGS") }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue, fullWidth: true))
                NavigationLink { CreateHubView() } label: { Text("ADD MY OWN") }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelPink, fullWidth: true))
            }.padding(.horizontal, 20)
        }
    }

    private var feedbackPrompt: some View {
        VStack(spacing: 20) {
            Text(lastReactionType == .stay ? "You'd stay!" : "You'd swipe past")
                .font(HPFont.heading)
                .foregroundColor(.white)

            Text("Want to say why? (optional)")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.8))

            TextField("leave an optional message", text: $feedbackText)
                .font(HPFont.body)
                .padding(14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal, 32)

            HStack(spacing: 16) {
                Button("Skip") { skipFeedback() }
                    .buttonStyle(HPButtonStyle(color: HPColor.backgroundDark))
                Button("Send") { submitFeedback() }
                    .buttonStyle(HPButtonStyle(color: HPColor.backgroundDark))
                    .disabled(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }

            Text("swipe up to skip · swipe down to send")
                .font(HPFont.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .offset(y: feedbackDragOffset)
        .opacity(1 - min(abs(feedbackDragOffset) / 700, 0.6))
        .gesture(
            DragGesture(minimumDistance: 10)
                .onChanged { value in
                    // Vertical swipes only — the prompt tracks the finger.
                    guard abs(value.translation.height) > abs(value.translation.width) else { return }
                    feedbackDragOffset = value.translation.height
                }
                .onEnded { value in
                    let canSend = !feedbackText.trimmingCharacters(in: .whitespaces).isEmpty
                    if value.translation.height < -50 {
                        // Slide off the top, then skip
                        withAnimation(.easeIn(duration: 0.25)) { feedbackDragOffset = -900 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { skipFeedback() }
                    } else if value.translation.height > 50, canSend {
                        // Slide off the bottom, then send
                        withAnimation(.easeIn(duration: 0.25)) { feedbackDragOffset = 900 }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { submitFeedback() }
                    } else {
                        // Not far enough (or nothing to send) — spring back
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            feedbackDragOffset = 0
                        }
                    }
                }
        )
    }
}
