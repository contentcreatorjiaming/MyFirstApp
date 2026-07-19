//
//  HookDetailView.swift
//  myFirstApp
//
//  Full detail view for a single hook. Shows content, metrics,
//  and reaction bar (only for test hooks, not existing reels).
//

import SwiftUI

struct HookDetailView: View {
    let hook: Hook
    @EnvironmentObject private var store: HookStore
    @EnvironmentObject private var session: UserSession
    @EnvironmentObject private var reactionStore: ReactionStore
    @State private var isEditing = false
    @State private var editText: String = ""
    @State private var showClaimInput = false
    @State private var skipRateInput: String = ""
    @State private var showSignInForClaim = false
    @State private var showMenu = false
    @State private var isEditingSummary = false
    @State private var summaryEditText: String = ""
    @State private var showSignInForSummary = false

    private var isOwnHook: Bool {
        session.isSignedIn && hook.authorDisplayName == session.displayName
    }

    /// Live copy from the store so in-place edits (text, AI summary) refresh.
    private var liveHook: Hook {
        store.hooks.first(where: { $0.id == hook.id }) ?? hook
    }

    private var displayedSummary: String? {
        if let s = liveHook.aiSummary { return s }
        if liveHook.metrics != nil { return AIInsightEngine.generateInsight(for: liveHook) }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                // Edit option for own hooks
                if isOwnHook && hook.kind == .text {
                    if isEditing {
                        VStack(spacing: 10) {
                            TextEditor(text: $editText)
                                .font(HPFont.body)
                                .frame(height: 80)
                                .padding(4)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Button("Save Edit") {
                                store.updateText(hookID: hook.id, newText: editText)
                                isEditing = false
                            }
                            .buttonStyle(HPSecondaryButtonStyle())
                        }
                    } else {
                        Button {
                            editText = liveHook.textContent ?? ""
                            isEditing = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .font(HPFont.caption)
                                .foregroundColor(HPColor.backgroundDark)
                        }
                    }
                }

                // Link + Claim for existing hooks
                if hook.source == .existing {
                    contentSection
                    claimSection
                } else {
                    contentSection
                }

                if let metrics = hook.metrics {
                    metricsSection(metrics)
                }

                // AI Summary — editable by signed-in users
                if let summary = displayedSummary {
                    aiSummarySection(summary)
                }

                // Static reaction counts for test hooks (not interactive)
                if hook.source == .testNew {
                    Divider()
                    staticReactionCounts
                    communityFeedbackSection
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("")
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button { showMenu = true } label: {
                    HookPlaygroundTitle(size: 18, twoLines: true)
                }
            }
        }
        .fullScreenCover(isPresented: $showMenu) {
            NavigationStack {
                NavMenuOverlay(isPresented: $showMenu)
            }
        }
    }

    // MARK: - Header with bookmark inline

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Added by \(hook.authorDisplayName)")
                    .font(HPFont.subheading)
                    .foregroundColor(.white)
                Text("Added on \(hook.createdAt, style: .date)")
                    .font(HPFont.caption)
                    .foregroundColor(HPColor.textSecondary)
                if let posted = hook.datePosted {
                    Text("Originally posted \(posted, style: .date)")
                        .font(HPFont.caption)
                        .foregroundColor(HPColor.textSecondary)
                }
            }
            Spacer()
            if hook.source == .existing {
                BookmarkButton(hookID: hook.id)
            }
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        switch hook.kind {
        case .text:
            Text(liveHook.textContent ?? "")
                .font(HPFont.body)
                .foregroundColor(HPColor.backgroundDark)
                .multilineTextAlignment(.leading)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        case .visual:
            if let filename = hook.imageFileName,
               let uiImage = UIImage(contentsOfFile: store.imageURL(for: filename).path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        case .link:
            Button {
                if let urlStr = hook.linkURL, let url = URL(string: urlStr) {
                    UIApplication.shared.open(url)
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "link")
                        .foregroundColor(HPColor.backgroundDark)
                    Text(hook.linkURL ?? "")
                        .font(HPFont.body)
                        .foregroundColor(HPColor.backgroundDark)
                        .lineLimit(2)
                        .underline()
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        case .video:
            if let filename = hook.videoFileName {
                VideoPreviewView(url: store.videoURL(for: filename))
                    .frame(height: 250)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }

    // MARK: - Metrics

    private func metricsSection(_ metrics: HookMetrics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("Ordered by what impacts your views the most, per instagram's own ranking")
                .font(HPFont.caption)
                .foregroundColor(.white.opacity(0.7))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                metricCard("Views", value: metrics.views, icon: "eye", rank: 1)
                metricCard("Shares", value: metrics.shares, icon: "arrowshape.turn.up.right.fill", rank: 2)
                metricCard("Likes", value: metrics.likes, icon: "heart.fill", rank: 3)
                metricCard("Saves", value: metrics.saves, icon: "bookmark.fill", rank: 4)
                metricCard("Reposts", value: metrics.reposts, icon: "arrow.2.squarepath", rank: 5)
                metricCard("Comments", value: metrics.comments, icon: "bubble.left.fill", rank: 6)
            }
        }
    }

    private func metricCard(_ label: String, value: Int, icon: String, rank: Int) -> some View {
        VStack(spacing: 6) {
            Text("\(rank)")
                .font(HPFont.caption)
                .foregroundColor(HPColor.backgroundDark.opacity(0.4))
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(HPColor.backgroundDark)
            Text(formatNumber(value))
                .font(HPFont.metric)
                .foregroundColor(HPColor.backgroundDark)
            Text(label)
                .font(HPFont.metricLabel)
                .foregroundColor(HPColor.backgroundDark.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n) / 1_000) }
        return "\(n)"
    }

    // MARK: - AI Summary

    private func aiSummarySection(_ summary: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("AI Summary")
                        .font(HPFont.heading)
                        .foregroundColor(.white)
                    Text("Read this with a grain of salt; AI summary of what reel is about might not be 100% accurate. But that's where you can help!")
                        .font(HPFont.caption)
                        .foregroundColor(.white.opacity(0.75))
                }
                Spacer()
                if !isEditingSummary {
                    Button {
                        if session.isSignedIn {
                            summaryEditText = summary
                            isEditingSummary = true
                        } else {
                            showSignInForSummary = true
                        }
                    } label: {
                        Label("Edit", systemImage: "pencil")
                            .font(HPFont.caption)
                            .foregroundColor(.white)
                    }
                }
            }

            if isEditingSummary {
                TextEditor(text: $summaryEditText)
                    .font(HPFont.body)
                    .frame(height: 120)
                    .padding(4)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Button("Save Edit") {
                    store.updateAISummary(hookID: hook.id, newSummary: summaryEditText)
                    isEditingSummary = false
                }
                .buttonStyle(HPSecondaryButtonStyle())
            } else {
                Text(summary)
                    .font(HPFont.body)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .fullScreenCover(isPresented: $showSignInForSummary) {
            NavigationStack {
                SignInGateView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") { showSignInForSummary = false }
                                .foregroundColor(.white)
                        }
                    }
            }
        }
    }

    // MARK: - Static reaction counts (non-interactive)

    private var staticReactionCounts: some View {
        HStack(spacing: 20) {
            VStack(spacing: 4) {
                Text("STAY").font(HPFont.subheading)
                Text("\(reactionStore.stayCount(for: hook.id))").font(HPFont.caption)
            }
            .foregroundColor(HPColor.backgroundDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(spacing: 4) {
                Text("SWIPE").font(HPFont.subheading)
                Text("\(reactionStore.swipeCount(for: hook.id))").font(HPFont.caption)
            }
            .foregroundColor(HPColor.backgroundDark)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var communityFeedbackSection: some View {
        let entries = reactionStore.feedbackEntries(for: hook.id)
        let originals = entries.filter { !($0.feedback?.hasPrefix("↳") ?? false) }
        let replies = entries.filter { $0.feedback?.hasPrefix("↳") ?? false }

        return Group {
            if !originals.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Community Feedback")
                        .font(HPFont.heading)
                        .foregroundColor(.white)
                    ForEach(originals) { entry in
                        VStack(alignment: .leading, spacing: 0) {
                            // Original feedback
                            HStack(alignment: .top, spacing: 8) {
                                Text(entry.type == .stay ? "✓" : "✗")
                                    .font(HPFont.subheading)
                                    .foregroundColor(HPColor.backgroundDark)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(entry.authorDisplayName)
                                        .font(HPFont.caption)
                                        .foregroundColor(HPColor.backgroundDark)
                                    Text(entry.feedback ?? "")
                                        .font(HPFont.body)
                                        .foregroundColor(HPColor.textDark)
                                        .multilineTextAlignment(.leading)
                                }
                                Spacer()
                            }
                            .padding(10)

                            // Threaded replies
                            let threadReplies = replies.filter {
                                $0.feedback?.contains("@\(entry.authorDisplayName)") ?? false
                            }
                            ForEach(threadReplies) { reply in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("↳")
                                        .font(HPFont.caption)
                                        .foregroundColor(HPColor.backgroundDark.opacity(0.5))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(reply.authorDisplayName)
                                            .font(HPFont.caption)
                                            .foregroundColor(HPColor.backgroundDark.opacity(0.7))
                                        Text(reply.feedback?.replacingOccurrences(of: "↳ @\(entry.authorDisplayName): ", with: "") ?? "")
                                            .font(HPFont.caption)
                                            .foregroundColor(HPColor.textDark)
                                            .multilineTextAlignment(.leading)
                                    }
                                }
                                .padding(.leading, 30)
                                .padding(.trailing, 10)
                                .padding(.bottom, 6)
                            }

                            // Reply button
                            if session.isSignedIn {
                                ReplyButton(hookID: hook.id, parentAuthor: entry.authorDisplayName)
                                    .padding(.horizontal, 10)
                                    .padding(.bottom, 8)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }

    /// "26.5" stays 26.5, "42" stays 42 — no rounding to whole numbers.
    private func formatRate(_ rate: Double) -> String {
        rate.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", rate)
            : String(format: "%.1f", rate)
    }

    private var claimSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let claimed = hook.claimedBy {
                Text("Claimed by \(claimed)")
                    .font(HPFont.caption)
                    .foregroundColor(.white.opacity(0.7))

                if let rate = hook.skipRate {
                    HStack(spacing: 10) {
                        VStack(spacing: 6) {
                            Image(systemName: "chart.line.downtrend.xyaxis")
                                .font(.body)
                                .foregroundColor(HPColor.backgroundDark)
                            Text("\(formatRate(rate))%")
                                .font(HPFont.metric)
                                .foregroundColor(HPColor.backgroundDark)
                            Text("Skip Rate")
                                .font(HPFont.metricLabel)
                                .foregroundColor(HPColor.backgroundDark.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        Spacer().frame(maxWidth: .infinity)
                        Spacer().frame(maxWidth: .infinity)
                    }
                }
            } else {
                if showClaimInput {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Enter your skip rate:")
                            .font(HPFont.body).foregroundColor(.white)
                        HStack(spacing: 8) {
                            TextField("e.g. 42", text: $skipRateInput)
                                .font(HPFont.body).padding(10).background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .keyboardType(.decimalPad).frame(width: 100)
                            Text("%").font(HPFont.body).foregroundColor(.white)
                            Button("Save") {
                                if let rate = Double(skipRateInput) {
                                    store.claimHook(hookID: hook.id, by: session.displayName, skipRate: rate)
                                    showClaimInput = false
                                }
                            }
                            .buttonStyle(HPButtonStyle(color: HPColor.backgroundDark))
                        }
                        Text("Currently, Instagram considers skip rate the most important metric to retention")
                            .font(HPFont.caption)
                            .foregroundColor(.white)
                    }
                } else {
                    Button {
                        if session.isSignedIn {
                            showClaimInput = true
                        } else {
                            showSignInForClaim = true
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "hand.raised")
                            Text("This is my reel — add skip rate")
                                .font(HPFont.body)
                        }
                        .foregroundColor(HPColor.backgroundDark)
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .fullScreenCover(isPresented: $showSignInForClaim) {
                        NavigationStack {
                            SignInGateView()
                                .toolbar {
                                    ToolbarItem(placement: .topBarLeading) {
                                        Button("Cancel") { showSignInForClaim = false }
                                            .foregroundColor(.white)
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HookDetailView(hook: Hook(
            id: UUID(), source: .existing, kind: .text,
            linkURL: nil, textContent: "POV: you discovered the one productivity hack that works",
            imageFileName: nil, videoFileName: nil,
            metrics: HookMetrics(views: 145000, shares: 1300, likes: 8200, saves: 3100, reposts: 0, comments: 420),
            createdAt: Date(), datePosted: nil, authorDisplayName: "creator_jane",
            aiSummary: nil, skipRate: nil, claimedBy: nil
        ))
        .environmentObject(HookStore())
        .environmentObject(ReactionStore())
        .environmentObject(BookmarkStore())
        .environmentObject(UserSession())
    }
}
