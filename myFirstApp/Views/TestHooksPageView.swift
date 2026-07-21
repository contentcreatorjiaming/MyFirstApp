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

    /// Snapshot of the hooks the user can rate, taken on appear so the deck
    /// doesn't shift under the user mid-session as reactions are recorded.
    @State private var queue: [Hook] = []
    @State private var queueReady = false

    private var testHooks: [Hook] {
        store.hooks.filter { $0.source == .testNew }
    }

    /// Hooks the signed-in user is allowed to rate — never their own, and
    /// only those matching a topic they said they're interested in. Filtering
    /// the hook list (rather than iterating per topic) means a hook tagged with
    /// several matching topics still surfaces exactly once.
    private var ratableHooks: [Hook] {
        let interests = Set(session.interestedTopics)
        return testHooks.filter { hook in
            guard hook.authorDisplayName != session.displayName else { return false }
            guard !interests.isEmpty else { return true }   // no preference → show all
            return !Set(hook.topics ?? []).isDisjoint(with: interests)
        }
    }

    var body: some View {
        ZStack {
            AuroraBackground()

            if !session.isSignedIn {
                AuthGateScreen()
            } else if ratableHooks.isEmpty {
                emptyState
            } else if !queueReady {
                Color.clear
            } else if queue.isEmpty || currentIndex >= queue.count {
                completionState
            } else if showFeedback {
                feedbackPrompt
            } else {
                SwipeCardView(
                    hook: queue[currentIndex],
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
        .onAppear { rebuildQueue() }
        .onChange(of: session.displayName) { _, _ in rebuildQueue() }
    }

    /// Deal only cards the user hasn't rated yet and that aren't their own.
    private func rebuildQueue() {
        queue = ratableHooks.filter {
            !reactionStore.hasReacted(hookID: $0.id, author: session.displayName)
        }
        currentIndex = 0
        showFeedback = false
        queueReady = true
    }

    // MARK: - React

    private func react(_ type: ReactionType) {
        guard session.isSignedIn else { return }
        let hook = queue[currentIndex]

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
            Text("No hooks to rate yet")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("Check back when other creators\nsubmit new hooks to test.")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
    }

    private var completionState: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 60))
            Text("You've reviewed all hooks!")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("\(queue.count) hooks rated")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.7))
            Text("Your reactions just helped real creators sharpen their hooks.")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            HStack(spacing: 14) {
                NavigationLink { SavedHooksView() } label: { Text("SEE MY RATINGS") }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue, fullWidth: true))
                NavigationLink { TestNewHookView() } label: { Text("ADD MY OWN") }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelPink, fullWidth: true))
            }.padding(.horizontal, 20)
        }
    }

    private var feedbackPrompt: some View {
        VStack(spacing: 20) {
            Text(lastReactionType == .stay ? "You'd stay!" : "You'd swipe past")
                .font(HPFont.heading)
                .foregroundColor(.white)

            Text("Want to say why?")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.8))

            TextField("Leave an optional message", text: $feedbackText)
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

            Text("Swipe up to skip · Swipe down to send")
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
