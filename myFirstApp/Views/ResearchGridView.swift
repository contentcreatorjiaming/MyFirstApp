//
//  ResearchGridView.swift
//  myFirstApp
//
//  Browsable library of existing hooks (explore page).
//

import SwiftUI

enum MetricSort: String, CaseIterable, Identifiable {
    case views = "Views"
    case shares = "Shares"
    case likes = "Likes"
    case saves = "Saves"
    case reposts = "Reposts"
    case comments = "Comments"

    var id: String { rawValue }

    func value(for metrics: HookMetrics) -> Int {
        switch self {
        case .views: return metrics.views
        case .shares: return metrics.shares
        case .likes: return metrics.likes
        case .saves: return metrics.saves
        case .reposts: return metrics.reposts
        case .comments: return metrics.comments
        }
    }
}

struct ResearchGridView: View {
    @EnvironmentObject private var store: HookStore
    @State private var sortMetric: MetricSort?

    private var existingHooks: [Hook] {
        // Newest first so freshly added hooks land at the top; seeded
        // hooks share a createdAt so a stable tie-break keeps their order.
        let base = store.hooks.filter { $0.source == .existing }
            .enumerated()
            .sorted { a, b in
                if a.element.createdAt == b.element.createdAt { return a.offset < b.offset }
                return a.element.createdAt > b.element.createdAt
            }
            .map(\.element)
        guard let metric = sortMetric else { return base }
        return base.sorted {
            metric.value(for: $0.metrics ?? HookMetrics(views: 0, shares: 0, likes: 0, saves: 0, reposts: 0, comments: 0)) >
            metric.value(for: $1.metrics ?? HookMetrics(views: 0, shares: 0, likes: 0, saves: 0, reposts: 0, comments: 0))
        }
    }

    var body: some View {
        ScrollView {
            sortFilter

            if existingHooks.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Text("No hooks yet")
                        .font(HPFont.heading)
                        .foregroundColor(.white)
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 400)
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
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) } }
        .navigationBarTitleDisplayMode(.inline)
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
    }

    // MARK: - Sort dropdown

    private var sortFilter: some View {
        HStack {
            Menu {
                ForEach(MetricSort.allCases) { metric in
                    Button(metric.rawValue) { sortMetric = metric }
                }
                if sortMetric != nil {
                    Divider()
                    Button("Clear sort") { sortMetric = nil }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.up.arrow.down")
                    Text(sortMetric.map { "Sorted by \($0.rawValue)" } ?? "Sort by metric")
                        .font(HPFont.caption)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                }
                .foregroundColor(HPColor.backgroundDark)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}


private struct ResearchCard: View {
    let hook: Hook

    var body: some View {
        NavigationLink {
            HookDetailView(hook: hook)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                // 2x3 performance grid
                if let m = hook.metrics {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 6),
                        GridItem(.flexible(), spacing: 6),
                        GridItem(.flexible(), spacing: 6)
                    ], spacing: 6) {
                        miniMetric("Views", value: m.views)
                        miniMetric("Shares", value: m.shares)
                        miniMetric("Likes", value: m.likes)
                        miniMetric("Saves", value: m.saves)
                        miniMetric("Reposts", value: m.reposts)
                        miniMetric("Comments", value: m.comments)
                    }
                }

                ZStack {
                    HStack {
                        Text("Instagram Reel")
                            .font(HPFont.caption)
                            .foregroundColor(HPColor.backgroundDark.opacity(0.6))
                        Spacer()
                        HStack(spacing: 8) {
                            BookmarkButton(hookID: hook.id, tint: HPColor.backgroundDark)
                            Text("see more →")
                                .font(HPFont.caption)
                                .foregroundColor(HPColor.backgroundDark)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(HPColor.background.opacity(0.4))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    Text("added by \(hook.authorDisplayName)")
                        .font(HPFont.caption)
                        .foregroundColor(HPColor.backgroundDark.opacity(0.6))
                }
            }
            .padding(14)
            .background(Color.white.opacity(0.92))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func miniMetric(_ label: String, value: Int) -> some View {
        VStack(spacing: 2) {
            Text(formatNumber(value))
                .font(HPFont.brandRegular(size: 14))
                .foregroundColor(HPColor.backgroundDark)
            Text(label)
                .font(HPFont.brandRegular(size: 9))
                .foregroundColor(HPColor.backgroundDark.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(HPColor.background.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
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
            .environmentObject(UserSession())
    }
}
