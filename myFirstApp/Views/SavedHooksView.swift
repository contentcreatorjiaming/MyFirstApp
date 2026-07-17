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
        VStack(spacing: 0) {
            if !session.isSignedIn {
                ZStack {
                    HPGradientBackground()
                    VStack {
                        Spacer()
                        VStack(spacing: 0) {
                            Text("hook").font(HPFont.screenTitle)
                            Text("playground").font(HPFont.screenTitle)
                        }.foregroundColor(.white)
                        Spacer().frame(height: 36)
                        HStack(spacing: 14) {
                            NavigationLink {
                                SignInGateView()
                            } label: {
                                Text("SIGN IN")
                            }
                            .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue))

                            NavigationLink {
                                SignInGateView()
                            } label: {
                                Text("SIGN UP")
                            }
                            .buttonStyle(HPButtonStyle(color: HPColor.pastelPink))
                        }
                        Spacer()
                    }
                }
            } else {
                Picker("", selection: $selectedTab) {
                    Text("Saved").tag(0)
                    Text("Stayed").tag(1)
                    Text("Swiped").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.top, 8)

                ScrollView {
                    switch selectedTab {
                    case 0: savedList
                    case 1: reactionList(type: .stay)
                    case 2: reactionList(type: .swipe)
                    default: EmptyView()
                    }
                }
            }
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) } }
        .navigationBarTitleDisplayMode(.inline)
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
    }

    // MARK: - Saved from explore

    private var savedList: some View {
        let saved = store.hooks.filter { bookmarks.isSaved($0.id) }
        return Group {
            if saved.isEmpty {
                emptyState("No saved hooks yet", sub: "Bookmark hooks from Explore to see them here.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(saved) { hook in
                        NavigationLink { HookDetailView(hook: hook) } label: {
                            hookCard(hook, subtitle: hook.source == .existing ? "from explore" : "your test hook")
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 16).padding(.top, 8)
            }
        }
    }

    // MARK: - Stayed / Swiped

    private func reactionList(type: ReactionType) -> some View {
        // Get ALL user reactions, take latest per hookID, then filter by type
        let allUserReactions = reactionStore.reactions.filter {
            $0.authorDisplayName == session.displayName
        }
        var latestByHook: [UUID: Reaction] = [:]
        for r in allUserReactions {
            latestByHook[r.hookID] = r // last one wins
        }
        let matching = latestByHook.values.filter { $0.type == type }
        let label = type == .stay ? "stayed for" : "swiped past"

        return Group {
            if matching.isEmpty {
                emptyState("No hooks \(label) yet", sub: "Use Swipe or Stay to rate test hooks.")
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(Array(matching), id: \.id) { reaction in
                        if let hook = store.hooks.first(where: { $0.id == reaction.hookID }) {
                            NavigationLink { HookDetailView(hook: hook) } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    hookCard(hook, subtitle: "you \(label) this")
                                    if let fb = reaction.feedback, !fb.isEmpty {
                                        Text("Your note: \(fb)")
                                            .font(HPFont.caption)
                                            .foregroundColor(HPColor.backgroundDark.opacity(0.6))
                                            .padding(.horizontal, 14)
                                            .padding(.bottom, 8)
                                    }
                                }
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
                Text(hook.textContent ?? "added by \(hook.authorDisplayName)")
                    .font(HPFont.body)
                    .foregroundColor(HPColor.backgroundDark)
                    .lineLimit(2)
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
