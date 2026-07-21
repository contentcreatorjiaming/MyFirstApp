//
//  myFirstAppTests.swift
//  myFirstAppTests
//
//  Created by Jiaming Lou on 7/14/26.
//

import Foundation
import Testing
@testable import myFirstApp

struct myFirstAppTests {

    @Test func landingViewInitializes() async throws {
        // Smoke test: confirms the root view can be constructed without crashing.
        _ = LandingView()
    }

    @Test func hookStoreSavesAndReloadsAHook() async throws {
        let store = await HookStore()
        let hook = Hook(
            id: UUID(), source: .testNew, kind: .text,
            linkURL: nil, textContent: "test hook",
            imageFileName: nil, videoFileName: nil,
            metrics: nil, createdAt: Date(), datePosted: nil,
            authorDisplayName: "tester",
            aiSummary: nil, skipRate: nil, claimedBy: nil
        )
        await store.add(hook)
        let saved = await store.hooks
        #expect(saved.contains(where: { $0.id == hook.id }))
    }

    @Test func aiInsightGeneratesTextForExistingHook() async throws {
        let hook = Hook(
            id: UUID(), source: .existing, kind: .link,
            linkURL: "https://example.com", textContent: nil,
            imageFileName: nil, videoFileName: nil,
            metrics: HookMetrics(views: 1000000, shares: 50000, likes: 200000, saves: 30000, reposts: 5000, comments: 1000),
            createdAt: Date(), datePosted: nil,
            authorDisplayName: "test",
            aiSummary: nil, skipRate: nil, claimedBy: nil
        )
        let insight = AIInsightEngine.generateInsight(for: hook)
        #expect(!insight.isEmpty)
        #expect(insight.contains("1.0M"))
    }

    @Test func aiInsightHandlesNoMetrics() async throws {
        let hook = Hook(
            id: UUID(), source: .testNew, kind: .text,
            linkURL: nil, textContent: "test",
            imageFileName: nil, videoFileName: nil,
            metrics: nil, createdAt: Date(), datePosted: nil,
            authorDisplayName: "test",
            aiSummary: nil, skipRate: nil, claimedBy: nil
        )
        let insight = AIInsightEngine.generateInsight(for: hook)
        #expect(insight.contains("hasn't been posted"))
    }

    @Test func bookmarkStoreToggles() async throws {
        let store = await BookmarkStore()
        let id = UUID()
        await store.toggle(id)
        #expect(await store.isSaved(id))
        await store.toggle(id)
        #expect(await !store.isSaved(id))
    }

    @Test func latestReactionPerHookWins() async throws {
        // Core dedup rule: re-reacting to the same hook replaces the old verdict.
        let hookID = UUID()
        let older = Reaction(id: UUID(), hookID: hookID, type: .swipe,
                             feedback: nil, authorDisplayName: "ivy",
                             createdAt: Date().addingTimeInterval(-60))
        let newer = Reaction(id: UUID(), hookID: hookID, type: .stay,
                             feedback: nil, authorDisplayName: "ivy",
                             createdAt: Date())
        let result = ReactionStore.latestReactions(perHookFrom: [older, newer], by: "ivy")
        #expect(result.count == 1)
        #expect(result.first?.type == .stay)
    }

    @Test func latestReactionsOnlyCountsTheGivenAuthor() async throws {
        // Another creator's reaction to the same hook must not leak into my tabs.
        let hookID = UUID()
        let mine = Reaction(id: UUID(), hookID: hookID, type: .stay,
                            feedback: nil, authorDisplayName: "ivy",
                            createdAt: Date())
        let theirs = Reaction(id: UUID(), hookID: hookID, type: .swipe,
                              feedback: nil, authorDisplayName: "someone_else",
                              createdAt: Date())
        let result = ReactionStore.latestReactions(perHookFrom: [mine, theirs], by: "ivy")
        #expect(result.count == 1)
        #expect(result.first?.authorDisplayName == "ivy")
    }

}
