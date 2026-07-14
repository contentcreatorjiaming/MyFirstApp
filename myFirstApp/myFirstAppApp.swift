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

    var body: some Scene {
        WindowGroup {
            LandingView()
                .environmentObject(session)
                .environmentObject(hookStore)
        }
    }
}
