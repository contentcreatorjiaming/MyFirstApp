//
//  ReactionBarView.swift
//  myFirstApp
//
//  The Stay/Swipe quick-reaction bar with optional written feedback.
//  Appears on HookDetailView. Users tap Stay or Swipe (one-time per hook),
//  then can optionally leave written feedback explaining their reaction.
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
            // Quick reaction buttons
            reactionButtons

            // Optional feedback input (shown after tapping Stay or Swipe)
            if showFeedbackField {
                feedbackSection
            }

            // Existing feedback from community
            let entries = reactionStore.feedbackEntries(for: hookID)
            if !entries.isEmpty {
                communityFeedback(entries)
            }
        }
    }

    // MARK: - Subviews

    private var reactionButtons: some View {
        HStack(spacing: 20) {
            reactionButton(
                type: .stay,
                label: "STAY",
                icon: "👀",
                count: reactionStore.stayCount(for: hookID),
                color: .green
            )
            reactionButton(
                type: .swipe,
                label: "SWIPE",
                icon: "👋",
                count: reactionStore.swipeCount(for: hookID),
                color: .red
            )
        }
    }

    private func reactionButton(type: ReactionType, label: String, icon: String, count: Int, color: Color) -> some View {
        Button {
            guard session.isSignedIn, !alreadyReacted else { return }
            let reaction = Reaction(
                id: UUID(),
                hookID: hookID,
                type: type,
                feedback: nil,
                authorDisplayName: session.displayName,
                createdAt: Date()
            )
            reactionStore.add(reaction)
            justReacted = type
            showFeedbackField = true
        } label: {
            VStack(spacing: 6) {
                Text(icon).font(.title2)
                Text(label)
                    .font(.system(size: 13, weight: .bold))
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                alreadyReacted || justReacted != nil
                    ? Color(.systemGray5)
                    : color.opacity(0.12)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(alreadyReacted || justReacted != nil)
        .buttonStyle(.plain)
    }

    private var feedbackSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Why? (optional)")
                .font(HPFont.subheading)
                .foregroundColor(.secondary)
            HStack {
                TextField("What would you improve?", text: $feedbackText)
                    .textFieldStyle(.roundedBorder)
                Button("Send") {
                    submitFeedback()
                }
                .buttonStyle(HPButtonStyle(color: HPColor.ink))
                .disabled(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(feedbackText.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
            }
        }
    }

    private func communityFeedback(_ entries: [Reaction]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Community Feedback")
                .font(HPFont.heading)
            ForEach(entries) { entry in
                HStack(alignment: .top, spacing: 8) {
                    Text(entry.type == .stay ? "👀" : "👋")
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.authorDisplayName)
                            .font(.caption.bold())
                        Text(entry.feedback ?? "")
                            .font(HPFont.subheading)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
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
