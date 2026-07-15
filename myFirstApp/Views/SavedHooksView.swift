//
//  SavedHooksView.swift
//  myFirstApp
//
//  Shows only hooks the user has bookmarked. Same grid layout as Research
//  but filtered to saved items only. Accessible from the landing screen.
//

import SwiftUI

struct SavedHooksView: View {
    @EnvironmentObject private var store: HookStore
    @EnvironmentObject private var bookmarks: BookmarkStore

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    private var savedHooks: [Hook] {
        store.hooks.filter { bookmarks.isSaved($0.id) }
    }

    var body: some View {
        ScrollView {
            if savedHooks.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(savedHooks) { hook in
                        NavigationLink {
                            HookDetailView(hook: hook)
                        } label: {
                            HookGridCell(hook: hook)
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .navigationTitle("Saved Hooks")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("🔖")
                .font(.system(size: 48))
            Text("No saved hooks yet")
                .font(HPFont.heading)
                .foregroundColor(.secondary)
            Text("Tap the bookmark icon on any hook\nto save it here for later.")
                .font(HPFont.subheading)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}

#Preview {
    NavigationStack {
        SavedHooksView()
            .environmentObject(HookStore())
            .environmentObject(BookmarkStore())
    }
}
