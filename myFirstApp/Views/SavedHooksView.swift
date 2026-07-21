//
//  SavedHooksView.swift
//  myFirstApp
//
//  Tabbed view: Saved (from explore), Stayed (from swipe), Swiped.
//

import SwiftUI

struct SavedHooksView: View {
    @EnvironmentObject private var store: HookStore
    @EnvironmentObject private var bookmarks: BookmarkStore
    @EnvironmentObject private var reactionStore: ReactionStore
    @EnvironmentObject private var session: UserSession

    @State private var selectedTab = 0

    init() {
        // Green text for segmented picker
        let green = UIColor(red: 0.13, green: 0.55, blue: 0.40, alpha: 1)
        UISegmentedControl.appearance().selectedSegmentTintColor = .white
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: green], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: green.withAlphaComponent(0.6)], for: .normal)
    }

    var body: some View {
        if !session.isSignedIn {
            // Standard sign in/up screen; authenticating swaps to the tabs
            // in place so the user lands on Saved Hooks.
            AuthGateScreen()
        } else {
            VStack(spacing: 0) {
                NavigationLink {
                    EditInterestsView()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "slider.horizontal.3")
                        Text("My Interests")
                            .font(HPFont.subheading)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                    }
                    .foregroundColor(HPColor.backgroundDark)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.white.opacity(0.92))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
                .padding(.top, 10)

                Picker("", selection: $selectedTab) {
                    Text("Saved").tag(0)
                    Text("Stayed").tag(1)
                    Text("Swiped").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 12)

                ScrollView {
                    switch selectedTab {
                    case 0: savedList
                    case 1: reactionList(type: .stay)
                    case 2: reactionList(type: .swipe)
                    default: EmptyView()
                    }
                }
            }
            .navigationTitle("")
            .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) } }
            .navigationBarTitleDisplayMode(.inline)
            .background(HPColor.background)
            .toolbarBackground(HPColor.background, for: .navigationBar)
        }
    }

    // MARK: - Saved from explore

    private var savedList: some View {
        // Includes both bookmarked explore hooks AND the user's own
        // tested hooks (auto-bookmarked on submit in TestNewHookView).
        // Dedupe identical entries (same text/video) so a hook that was
        // submitted more than once only appears a single time.
        var seenKeys = Set<String>()
        let saved = store.hooks
            .filter { bookmarks.isSaved($0.id) }
            .filter { hook in
                let key = hook.textContent ?? hook.videoFileName ?? hook.linkURL ?? hook.id.uuidString
                return seenKeys.insert(key).inserted
            }
        return Group {
            if saved.isEmpty {
                emptyState("No saved hooks yet", sub: "Bookmark the hooks that grab you — from creators across the playground.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(saved) { hook in
                        NavigationLink { HookDetailView(hook: hook) } label: {
                            hookCard(hook, subtitle: hook.source == .existing ? "From explore" : "Your test hook")
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 16).padding(.top, 8)
            }
        }
    }

    // MARK: - Stayed / Swiped

    private func reactionList(type: ReactionType) -> some View {
        // Latest reaction per hook wins — see ReactionStore.latestReactions.
        let matching = ReactionStore
            .latestReactions(perHookFrom: reactionStore.reactions, by: session.displayName)
            .filter { $0.type == type }
        let label = type == .stay ? "stayed for" : "swiped past"

        return Group {
            if matching.isEmpty {
                emptyState("No hooks \(label) yet", sub: "Swipe or Stay on other creators' hooks to help them test what works.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(matching), id: \.id) { reaction in
                        if let hook = store.hooks.first(where: { $0.id == reaction.hookID }) {
                            NavigationLink { HookDetailView(hook: hook) } label: {
                                hookCard(hook, subtitle: "You \(label) this")
                            }.buttonStyle(.plain)
                        }
                    }
                }.padding(.horizontal, 16).padding(.top, 8)
            }
        }
    }

    // MARK: - Shared card

    private func hookCard(_ hook: Hook, subtitle: String) -> some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.5))
                .frame(width: 50, height: 50)
                .overlay(
                    Group {
                        if subtitle.contains("stayed") {
                            Image(systemName: "checkmark")
                                .font(.title3.bold())
                                .foregroundColor(HPColor.backgroundDark)
                        } else if subtitle.contains("swiped") {
                            Image(systemName: "xmark")
                                .font(.title3.bold())
                                .foregroundColor(HPColor.backgroundDark)
                        } else if hook.kind == .link {
                            IGStyleIcon(size: 24, color: HPColor.backgroundDark)
                        } else {
                            Image(systemName: "text.alignleft")
                                .foregroundColor(HPColor.backgroundDark)
                        }
                    }
                )
            VStack(alignment: .leading, spacing: 4) {
                Text(hook.textContent ?? "Added by @\(hook.authorDisplayName)")
                    .font(HPFont.body)
                    .foregroundColor(HPColor.backgroundDark)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                Text(subtitle)
                    .font(HPFont.caption)
                    .foregroundColor(HPColor.backgroundDark.opacity(0.5))
            }
            Spacer()
        }
        .padding(14)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func emptyState(_ title: String, sub: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Text(title).font(HPFont.heading).foregroundColor(.white)
            Text(sub).font(HPFont.body).foregroundColor(.white.opacity(0.7)).multilineTextAlignment(.center)
            Spacer()
        }.frame(maxWidth: .infinity, minHeight: 300)
    }
}
