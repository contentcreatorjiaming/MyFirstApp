//
//  TestHooksPageView.swift
//  myFirstApp
//
//  Shows only test hooks (user-submitted, untested ideas). Tapping
//  a hook opens the detail view with Stay/Swipe reactions.
//

import SwiftUI

struct TestHooksPageView: View {
    @EnvironmentObject private var store: HookStore
    @EnvironmentObject private var bookmarks: BookmarkStore

    private var testHooks: [Hook] {
        store.hooks.filter { $0.source == .testNew }
    }

    var body: some View {
        ScrollView {
            if testHooks.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 14) {
                    ForEach(testHooks) { hook in
                        NavigationLink {
                            HookDetailView(hook: hook)
                        } label: {
                            TestHookCard(hook: hook)
                        }
                        .buttonStyle(.plain)
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
            Image(systemName: "flask")
                .font(.system(size: 40))
                .foregroundColor(.white.opacity(0.6))
            Text("No test hooks yet")
                .font(HPFont.heading)
                .foregroundColor(.white)
            Text("Submit a hook via Create → Test\nto see it here.")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}

private struct TestHookCard: View {
    let hook: Hook

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let text = hook.textContent {
                Text(text)
                    .font(HPFont.body)
                    .foregroundColor(HPColor.backgroundDark)
                    .lineLimit(3)
            } else if hook.kind == .video {
                HStack(spacing: 8) {
                    Image(systemName: "video.fill")
                        .foregroundColor(HPColor.pastelPink)
                    Text("Video Hook")
                        .font(HPFont.subheading)
                        .foregroundColor(HPColor.backgroundDark)
                }
            }

            HStack {
                Text("by \(hook.authorDisplayName)")
                    .font(HPFont.caption)
                    .foregroundColor(HPColor.backgroundDark.opacity(0.6))
                Spacer()
                BookmarkButton(hookID: hook.id)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
