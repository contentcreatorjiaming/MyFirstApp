//
//  ResearchGridView.swift
//  myFirstApp
//
//  Browsable library of hooks with link preview, metrics dropdown,
//  and bookmark toggle.
//

import SwiftUI

struct ResearchGridView: View {
    @EnvironmentObject private var store: HookStore

    private var existingHooks: [Hook] {
        store.hooks.filter { $0.source == .existing }
    }

    var body: some View {
        ScrollView {
            if existingHooks.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(existingHooks) { hook in
                        ResearchCard(hook: hook)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 16) } }
        .navigationBarTitleDisplayMode(.inline)
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No hooks yet")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("Create a hook first, or check back\nwhen seed data is loaded.")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}

// MARK: - Individual hook card

private struct ResearchCard: View {
    let hook: Hook
    @EnvironmentObject private var store: HookStore
    @State private var showAllMetrics = false
    @State private var selectedMetric: String = "Views"

    private let metricOptions = ["Views", "Likes", "Shares", "Saves", "Comments"]

    var body: some View {
        NavigationLink {
            HookDetailView(hook: hook)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // Preview area
                previewSection

                // Link + metrics row
                HStack(alignment: .center) {
                    // Link
                    if let url = hook.linkURL {
                        linkLabel(url)
                    } else if let text = hook.textContent {
                        Text(text)
                            .font(HPFont.caption)
                            .foregroundColor(HPColor.textDark)
                            .lineLimit(2)
                    }

                    Spacer()

                    // Metrics dropdown
                    if let metrics = hook.metrics {
                        metricsDropdown(metrics)
                    }
                }

                // Bookmark row
                HStack {
                    Spacer()
                    BookmarkButton(hookID: hook.id)
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Preview

    @ViewBuilder
    private var previewSection: some View {
        switch hook.kind {
        case .link:
            HStack(spacing: 10) {
                Image(systemName: "play.rectangle.fill")
                    .font(.system(size: 36))
                    .foregroundColor(HPColor.pastelPink)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Instagram Reel")
                        .font(HPFont.subheading)
                        .foregroundColor(HPColor.textDark)
                    if let metrics = hook.metrics {
                        Text(formatNumber(metrics.views) + " views")
                            .font(HPFont.caption)
                            .foregroundColor(HPColor.backgroundDark)
                    }
                }
                Spacer()
            }
            .padding(12)
            .background(HPColor.background.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        case .text:
            Text(hook.textContent ?? "")
                .font(HPFont.body)
                .foregroundColor(HPColor.textDark)
                .lineLimit(3)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(HPColor.background.opacity(0.2))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        case .visual:
            if let fn = hook.imageFileName,
               let img = UIImage(contentsOfFile: store.imageURL(for: fn).path) {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        case .video:
            HStack(spacing: 10) {
                Image(systemName: "video.fill")
                    .font(.title2)
                    .foregroundColor(HPColor.pastelBlue)
                Text("Video Hook")
                    .font(HPFont.subheading)
                    .foregroundColor(HPColor.textDark)
                Spacer()
            }
            .padding(12)
            .background(HPColor.background.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Link label

    private func linkLabel(_ url: String) -> some View {
        let shortURL = url
            .replacingOccurrences(of: "https://www.instagram.com/", with: "instagram.com/")
            .replacingOccurrences(of: "https://instagram.com/", with: "instagram.com/")

        return Button {
            if let link = URL(string: url) {
                UIApplication.shared.open(link)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right.square")
                    .font(.caption)
                Text(shortURL)
                    .font(HPFont.caption)
                    .lineLimit(1)
            }
            .foregroundColor(HPColor.pastelBlue)
        }
    }

    // MARK: - Metrics dropdown

    private func metricsDropdown(_ m: HookMetrics) -> some View {
        Menu {
            Button("Views: \(formatNumber(m.views))") { selectedMetric = "Views" }
            Button("Likes: \(formatNumber(m.likes))") { selectedMetric = "Likes" }
            Button("Shares: \(formatNumber(m.shares))") { selectedMetric = "Shares" }
            Button("Saves: \(formatNumber(m.saves))") { selectedMetric = "Saves" }
            Button("Comments: \(formatNumber(m.comments))") { selectedMetric = "Comments" }
        } label: {
            HStack(spacing: 4) {
                Text("\(selectedMetric): \(formatNumber(metricValue(m)))")
                    .font(HPFont.caption)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
            }
            .foregroundColor(HPColor.backgroundDark)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(HPColor.background.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func metricValue(_ m: HookMetrics) -> Int {
        switch selectedMetric {
        case "Likes": return m.likes
        case "Shares": return m.shares
        case "Saves": return m.saves
        case "Comments": return m.comments
        default: return m.views
        }
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n) / 1_000) }
        return "\(n)"
    }
}

#Preview {
    NavigationStack {
        ResearchGridView()
            .environmentObject(HookStore())
            .environmentObject(BookmarkStore())
    }
}
