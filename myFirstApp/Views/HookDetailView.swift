//
//  HookDetailView.swift
//  myFirstApp
//
//  Full detail view for a single hook. Shows the complete hook content
//  and real performance metrics (for existing hooks). The Stay/Swipe/
//  Feedback reaction bar will be added in a follow-up feature pass.
//

import SwiftUI

struct HookDetailView: View {
    let hook: Hook
    @EnvironmentObject private var store: HookStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header: author + source badge + date
                headerSection

                // Full hook content
                contentSection

                // Metrics (only for existing hooks with real data)
                if let metrics = hook.metrics {
                    metricsSection(metrics)
                } else {
                    Text("This hook hasn't been posted yet — no performance data available.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }

                // Reaction bar — Stay / Swipe + optional feedback
                Divider()
                ReactionBarView(hookID: hook.id)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Hook Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
                    .font(.headline)
                Text(hook.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Text(hook.source == .existing ? "PROVEN" : "TESTING")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(hook.source == .existing ? Color.green : Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 6))
        }
    }

    @ViewBuilder
    private var contentSection: some View {
        switch hook.kind {
        case .text:
            Text(hook.textContent ?? "")
                .font(.body)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        case .visual:
            if let filename = hook.imageFileName,
               let uiImage = UIImage(contentsOfFile: store.imageURL(for: filename).path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        case .link:
            HStack {
                Text("🔗")
                Text(hook.linkURL ?? "")
                    .font(.body)
                    .foregroundColor(.blue)
                    .lineLimit(2)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func metricsSection(_ metrics: HookMetrics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Performance")
                .font(.headline)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                metricCard("Views", value: metrics.views, icon: "👁️")
                metricCard("Likes", value: metrics.likes, icon: "❤️")
                metricCard("Shares", value: metrics.shares, icon: "🔁")
                metricCard("Comments", value: metrics.comments, icon: "💬")
                metricCard("Saves", value: metrics.saves, icon: "🔖")
            }
        }
    }

    private func metricCard(_ label: String, value: Int, icon: String) -> some View {
        VStack(spacing: 4) {
            Text(icon)
                .font(.title3)
            Text(formatNumber(value))
                .font(.headline)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
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
    }
}
