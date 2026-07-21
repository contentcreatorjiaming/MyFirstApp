//
//  myFirstAppApp.swift
//  myFirstApp
//
//  Created by Jiaming Lou on 7/12/26.
//

import SwiftUI

@main
struct myFirstAppApp: App {
    @StateObject private var session = UserSession()
    @StateObject private var hookStore = HookStore()
    @StateObject private var reactionStore = ReactionStore()
    @StateObject private var bookmarks = BookmarkStore()

    init() {
        FontRegistration.registerCustomFonts()
    }

    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(session)
                .environmentObject(hookStore)
                .environmentObject(reactionStore)
                .environmentObject(bookmarks)
                .onAppear {
                    // One-time fresh start: wipe every test hook, reaction, and
                    // saved hook so the account behaves like a brand-new user.
                    // Keeps the login itself; community seed data repopulates below.
                    if !UserDefaults.standard.bool(forKey: "didFreshReset_v1") {
                        hookStore.removeTestHooks()
                        reactionStore.clearAll()
                        bookmarks.clearAll()
                        UserDefaults.standard.set(true, forKey: "didFreshReset_v1")
                        // Let community feedback reseed onto the fresh test hooks.
                        UserDefaults.standard.removeObject(forKey: "hasSeededTestFeedback_v3")
                    }
                    SeedData.seedIfNeeded(store: hookStore)
                    reactionStore.seedMockReactions(for: hookStore.hooks.map(\.id))
                    SeedData.seedTestFeedback(store: hookStore, reactionStore: reactionStore)
                }
        }
    }
}
