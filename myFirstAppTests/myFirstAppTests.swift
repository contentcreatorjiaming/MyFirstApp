//
//  myFirstAppTests.swift
//  myFirstAppTests
//
//  Created by Jiaming Lou on 7/14/26.
//

import Testing
@testable import myFirstApp

struct myFirstAppTests {

    @Test func contentViewInitializes() async throws {
        // Smoke test: confirms the root view can be constructed without crashing.
        // As real features/state land, replace this with tests of actual logic.
        _ = ContentView()
    }

}
