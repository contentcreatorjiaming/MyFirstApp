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
                HStack(spacing: 10) {
                    Image(systemName: "camera.on.rectangle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(HPColor.pastelPink)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Instagram Reel")
                            .font(HPFont.subheading)
                            .foregroundColor(HPColor.textDark)
                        if let m = hook.metrics {
                            Text(formatNumber(m.views) + " views")
                                .font(HPFont.caption)
                                .foregroundColor(HPColor.backgroundDark)
                        }
                    }
                    Spacer()
                }
                .padding(12)
                .background(HPColor.background.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))

                HStack {
                    if let url = hook.linkURL {
                        Text(url.replacingOccurrences(of: "https://www.instagram.com/", with: "instagram.com/"))
                            .font(HPFont.caption)
                            .foregroundColor(HPColor.backgroundDark)
                            .lineLimit(1)
                    }
                    Spacer()
                    Text("more data →")
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
