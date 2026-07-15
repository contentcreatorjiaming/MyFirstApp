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
            id: UUID(),
            source: .testNew,
            kind: .text,
            linkURL: nil,
            textContent: "test hook",
            imageFileName: nil,
            videoFileName: nil,
            metrics: nil,
            createdAt: Date(),
            datePosted: nil,
            authorDisplayName: "tester",
            aiSummary: nil, skipRate: nil, claimedBy: nil
        )
        await store.add(hook)
        let saved = await store.hooks
        #expect(saved.contains(where: { $0.id == hook.id }))
    }

}
