//
//  UserSession.swift
//  myFirstApp
//
//  Mock local auth — stores username + password on device.
//  Sign up auto-creates. Sign in checks password match.
//  Swappable for real auth (Firebase/Supabase) later.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class UserSession: ObservableObject {
    @AppStorage("displayName") var displayName: String = ""
    @AppStorage("userPassword") private var storedPassword: String = ""

    var isSignedIn: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    enum AuthError: String {
        case wrongPassword = "Incorrect password. Try again."
        case emptyFields = "Please fill in both fields."
    }

    /// Sign up: creates a new local account.
    func signUp(username: String, password: String) -> AuthError? {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !pass.isEmpty else { return .emptyFields }
        displayName = name
        storedPassword = pass
        return nil
    }

    /// Sign in: checks password against stored credentials.
    func signIn(username: String, password: String) -> AuthError? {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !pass.isEmpty else { return .emptyFields }

        if !displayName.isEmpty && name == displayName {
            // Existing user — check password
            if pass != storedPassword { return .wrongPassword }
            return nil
        }
        // New user signing in = treat as sign up
        displayName = name
        storedPassword = pass
        return nil
    }

    /// Legacy convenience for backward compatibility.
    func signIn(displayName name: String) {
        displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func signOut() {
        displayName = ""
        storedPassword = ""
    }
}
