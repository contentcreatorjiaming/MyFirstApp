//
//  ResearchGridView.swift
//  myFirstApp
//
//  Browsable library of existing hooks (explore page).
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

                HStack {
                    Text("added by \(hook.authorDisplayName)")
                        .font(HPFont.caption)
                        .foregroundColor(HPColor.backgroundDark.opacity(0.6))
                    Spacer()
                    Text("see more →")
                        .font(HPFont.caption)
                        .foregroundColor(HPColor.backgroundDark)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(HPColor.background.opacity(0.4))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
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
