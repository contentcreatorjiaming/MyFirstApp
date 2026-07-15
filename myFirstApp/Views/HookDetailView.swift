//
//  HookDetailView.swift
//  myFirstApp
//
//  Full detail view for a single hook. Shows the complete hook content,
//  real performance metrics, and the community reaction bar.
//

import SwiftUI

struct HookDetailView: View {
    let hook: Hook
    @EnvironmentObject private var store: HookStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                contentSection

                if let metrics = hook.metrics {
                    metricsSection(metrics)
                } else {
                    untestedBadge
                }

                Divider()
                ReactionBarView(hookID: hook.id)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("")
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 16) }
            ToolbarItem(placement: .topBarTrailing) {
                BookmarkButton(hookID: hook.id)
            }
        }
    }

    // MARK: - Subviews

    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(hook.authorDisplayName)
                    .font(HPFont.subheading)
                Text(hook.createdAt, style: .date)
                    .font(HPFont.caption)
                    .foregroundColor(HPColor.textSecondary)
            }
            Spacer()
            Text(hook.source == .existing ? "PROVEN" : "TESTING")
                .font(HPFont.badge)
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(hook.source == .existing ? HPColor.backgroundDark : HPColor.pastelPink)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var untestedBadge: some View {
        HStack(spacing: 8) {
            Image(systemName: "flask")
                .foregroundColor(HPColor.pastelPink)
            Text("This hook hasn't been posted yet — no performance data. Submit it for community feedback!")
                .font(HPFont.caption)
                .foregroundColor(HPColor.textSecondary)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HPColor.pastelPink.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private var contentSection: some View {
        switch hook.kind {
        case .text:
            Text(hook.textContent ?? "")
                .font(HPFont.body)
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(HPColor.subtleBg)
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
            HStack(spacing: 10) {
                Image(systemName: "link")
                    .foregroundColor(HPColor.pastelBlue)
                Text(hook.linkURL ?? "")
                    .font(HPFont.body)
                    .foregroundColor(HPColor.pastelBlue)
                    .lineLimit(2)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(HPColor.pastelBlue.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }

    private func metricsSection(_ metrics: HookMetrics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance")
                .font(HPFont.heading)

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ], spacing: 10) {
                metricCard("Views", value: metrics.views, icon: "eye")
                metricCard("Likes", value: metrics.likes, icon: "heart.fill")
                metricCard("Shares", value: metrics.shares, icon: "arrowshape.turn.up.right.fill")
                metricCard("Comments", value: metrics.comments, icon: "bubble.left.fill")
                metricCard("Saves", value: metrics.saves, icon: "bookmark.fill")
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
                .foregroundColor(HPColor.textPrimary)
            Text(label)
                .font(HPFont.metricLabel)
                .foregroundColor(HPColor.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(HPColor.cardBg)
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
            id: UUID(),
            source: .existing,
            kind: .text,
            linkURL: nil,
            textContent: "POV: you just discovered the one productivity hack that actually works",
            imageFileName: nil,
            metrics: HookMetrics(views: 145000, likes: 8200, shares: 1300, comments: 420, saves: 3100),
            createdAt: Date(),
            authorDisplayName: "creator_jane"
        ))
        .environmentObject(HookStore())
        .environmentObject(ReactionStore())
        .environmentObject(BookmarkStore())
    }
}
