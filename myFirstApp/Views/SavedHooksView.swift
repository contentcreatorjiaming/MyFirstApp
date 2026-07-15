//
//  SavedHooksView.swift
//  myFirstApp
//
//  Shows only hooks the user has bookmarked.
//

import SwiftUI

struct SavedHooksView: View {
    @EnvironmentObject private var store: HookStore
    @EnvironmentObject private var bookmarks: BookmarkStore

    private var savedHooks: [Hook] {
        store.hooks.filter { bookmarks.isSaved($0.id) }
    }

    var body: some View {
        ScrollView {
            if savedHooks.isEmpty {
                VStack(spacing: 16) {
                    Spacer()
                    Image(systemName: "bookmark")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.6))
                    Text("No saved hooks yet")
                        .font(HPFont.heading)
                        .foregroundColor(.white)
                    Text("Tap the bookmark icon on any hook\nto save it here.")
                        .font(HPFont.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .frame(maxWidth: .infinity, minHeight: 400)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(savedHooks) { hook in
                        NavigationLink {
                            HookDetailView(hook: hook)
                        } label: {
                            SavedHookCard(hook: hook)
                        }
                        .buttonStyle(.plain)
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

private struct SavedHookCard: View {
    let hook: Hook

    var body: some View {
        HStack(spacing: 14) {
            // Icon
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: iconName)
                        .font(.title3)
                        .foregroundColor(HPColor.backgroundDark)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(displayText)
                    .font(HPFont.body)
                    .foregroundColor(HPColor.backgroundDark)
                    .lineLimit(2)
                Text(hook.source == .existing ? "from explore" : "your test hook")
                    .font(HPFont.caption)
                    .foregroundColor(HPColor.backgroundDark.opacity(0.5))
            }

            Spacer()
            BookmarkButton(hookID: hook.id)
        }
        .padding(14)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var displayText: String {
        if let text = hook.textContent, !text.isEmpty { return text }
        if let url = hook.linkURL {
            return url.replacingOccurrences(of: "https://www.instagram.com/", with: "instagram.com/")
        }
        return hook.kind == .video ? "Video Hook" : "Hook"
    }

    private var iconName: String {
        switch hook.kind {
        case .link: return "camera.on.rectangle"
        case .text: return "text.alignleft"
        case .visual: return "photo"
        case .video: return "video"
        }
    }
}
