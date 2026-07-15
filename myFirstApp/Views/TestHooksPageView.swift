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

    private var testHooks: [Hook] {
        store.hooks.filter { $0.source == .testNew }
    }

    var body: some View {
        ZStack {
            HPGradientBackground()

            if testHooks.isEmpty {
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
                    .font(HPFont.heading)
                    .foregroundColor(.white)
                    .transition(.opacity)
            }
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) } }
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

    private var completionState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.white)
            Text("You've reviewed all hooks!")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("\(testHooks.count) hooks rated")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.7))
            Button("Start Over") {
                currentIndex = 0
            }
            .buttonStyle(HPSecondaryButtonStyle())
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
            }
        }
        .padding()
    }
}
