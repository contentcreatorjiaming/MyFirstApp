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

    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(session)
                .environmentObject(hookStore)
                .environmentObject(reactionStore)
                .environmentObject(bookmarks)
                .onAppear {
                    // Seed mock community reactions for existing hooks
                    reactionStore.seedMockReactions(for: hookStore.hooks.map(\.id))
                }
        }
    }
}
