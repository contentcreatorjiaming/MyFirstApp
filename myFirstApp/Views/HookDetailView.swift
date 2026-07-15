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
    @State private var isEditing = false
    @State private var editText: String = ""

    private var isOwnHook: Bool {
        session.isSignedIn && hook.authorDisplayName == session.displayName
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
                            editText = hook.textContent ?? ""
                            isEditing = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                                .font(HPFont.caption)
                                .foregroundColor(HPColor.backgroundDark)
                        }
                    }
                }

                contentSection

                if let metrics = hook.metrics {
                    metricsSection(metrics)
                }

                // Stay/Swipe only for test hooks, not existing reels
                if hook.source == .testNew {
                    Divider()
                    ReactionBarView(hookID: hook.id)
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
            ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) }
        }
    }

    // MARK: - Header with bookmark inline

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                Text("added by \(hook.authorDisplayName)")
                    .font(HPFont.subheading)
                    .foregroundColor(.white)
                Text("added on \(hook.createdAt, style: .date)")
                    .font(HPFont.caption)
                    .foregroundColor(HPColor.textSecondary)
                if let posted = hook.datePosted {
                    Text("originally posted \(posted, style: .date)")
                        .font(HPFont.caption)
                        .foregroundColor(HPColor.textSecondary)
                }
            }
            Spacer()
            BookmarkButton(hookID: hook.id)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentSection: some View {
        switch hook.kind {
        case .text:
            Text(hook.textContent ?? "")
                .font(HPFont.body)
                .foregroundColor(HPColor.backgroundDark)
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
            Text("ordered by what impacts your views the most, per instagram's own ranking")
                .font(HPFont.caption)
                .foregroundColor(.white.opacity(0.7))

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                metricCard("Views", value: metrics.views, icon: "eye")
                metricCard("Shares", value: metrics.shares, icon: "arrowshape.turn.up.right.fill")
                metricCard("Likes", value: metrics.likes, icon: "heart.fill")
                metricCard("Saves", value: metrics.saves, icon: "bookmark.fill")
                metricCard("Reposts", value: metrics.reposts, icon: "arrow.2.squarepath")
                metricCard("Comments", value: metrics.comments, icon: "bubble.left.fill")
            }
        }
    }

    private func metricCard(_ label: String, value: Int, icon: String) -> some View {
        VStack(spacing: 6) {
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
}

#Preview {
    NavigationStack {
        HookDetailView(hook: Hook(
            id: UUID(), source: .existing, kind: .text,
            linkURL: nil, textContent: "POV: you discovered the one productivity hack that works",
            imageFileName: nil, videoFileName: nil,
            metrics: HookMetrics(views: 145000, shares: 1300, likes: 8200, saves: 3100, reposts: 0, comments: 420),
            createdAt: Date(), datePosted: nil, authorDisplayName: "creator_jane"
        ))
        .environmentObject(HookStore())
        .environmentObject(ReactionStore())
        .environmentObject(BookmarkStore())
        .environmentObject(UserSession())
    }
}
