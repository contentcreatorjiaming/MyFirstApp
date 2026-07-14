//
//  UserSession.swift
//  myFirstApp
//
//  Mock, local-only "sign in" — captures a display name so the rest of the
//  app has an author identity to attach to hooks. No real auth/backend yet;
//  this is intentionally swappable for the real thing later.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class UserSession: ObservableObject {
    @AppStorage("displayName") var displayName: String = ""

    var isSignedIn: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func signIn(displayName: String) {
        self.displayName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func signOut() {
        displayName = ""
    }
}
