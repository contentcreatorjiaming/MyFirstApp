//
//  ReactionBarView.swift
//  myFirstApp
//
//  Stay/Swipe quick-reaction bar with optional written feedback.
//

import SwiftUI

struct ReactionBarView: View {
    let hookID: UUID
    @EnvironmentObject private var reactionStore: ReactionStore
    @EnvironmentObject private var session: UserSession

    @State private var feedbackText: String = ""
    @State private var showFeedbackField = false
    @State private var justReacted: ReactionType?

    private var alreadyReacted: Bool {
        session.isSignedIn && reactionStore.hasReacted(hookID: hookID, author: session.displayName)
    }

    var body: some View {
        VStack(spacing: 16) {
            reactionButtons

            if showFeedbackField {
                feedbackSection
            }

            let entries = reactionStore.feedbackEntries(for: hookID)
            if !entries.isEmpty {
                communityFeedback(entries)
            }
        }
    }

    private var reactionButtons: some View {
        HStack(spacing: 20) {
            reactionButton(type: .stay, label: "STAY", count: reactionStore.stayCount(for: hookID))
            reactionButton(type: .swipe, label: "SWIPE", count: reactionStore.swipeCount(for: hookID))
        }
    }

    private func reactionButton(type: ReactionType, label: String, count: Int) -> some View {
        let isSelected = justReacted == type || (justReacted == nil && alreadyReacted && currentReaction == type)

        return Button {
            guard session.isSignedIn else { return }
            if alreadyReacted || justReacted != nil {
                // Toggle: switch to the other reaction
                reactionStore.switchReaction(hookID: hookID, author: session.displayName, to: type)
                justReacted = type
            } else {
                reactionStore.add(Reaction(
                    id: UUID(), hookID: hookID, type: type,
                    feedback: nil, authorDisplayName: session.displayName, createdAt: Date()
                ))
                justReacted = type
            }
            showFeedbackField = true
        } label: {
            VStack(spacing: 6) {
                Text(label).font(HPFont.subheading)
                Text("\(count)").font(HPFont.caption)
            }
            .foregroundColor(HPColor.backgroundDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isSelected ? HPColor.background.opacity(0.5) : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var currentReaction: ReactionType? {
        reactionStore.reactions(for: hookID)
            .first(where: { $0.authorDisplayName == session.displayName })?.type
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why?")
                .font(HPFont.subheading)
                .foregroundColor(.white)
            HStack {
                TextField("leave a message", text: $feedbackText)
                    .font(HPFont.body)
                    .padding(12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Button("Send") { submitFeedback() }
                    .buttonStyle(HPSecondaryButtonStyle())
                    .disabled(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty)
                    .opacity(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
    }

    private func communityFeedback(_ entries: [Reaction]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Community Feedback")
                .font(HPFont.heading)
                .foregroundColor(.white)
            ForEach(entries) { entry in
                HStack(alignment: .top, spacing: 8) {
                    Text(entry.type == .stay ? "Stay" : "Swipe")
                        .font(HPFont.caption)
                        .foregroundColor(HPColor.backgroundDark)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.authorDisplayName)
                            .font(HPFont.caption)
                            .foregroundColor(HPColor.backgroundDark)
                        Text(entry.feedback ?? "")
                            .font(HPFont.body)
                            .foregroundColor(HPColor.textDark)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.9))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }
        }
    }

    private func submitFeedback() {
        guard justReacted != nil else { return }
        let trimmed = feedbackText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        reactionStore.updateFeedback(for: hookID, author: session.displayName, feedback: trimmed)
        feedbackText = ""
        showFeedbackField = false
    }
}
