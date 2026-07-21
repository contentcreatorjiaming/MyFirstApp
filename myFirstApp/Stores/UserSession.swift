//
//  UserSession.swift
//  myFirstApp
//
//  Mock local auth — stores all accounts (username → password) on device
//  so signing up a new user never wipes an earlier one. Usernames are
//  unique: sign-up rejects taken names. Swappable for real auth later.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class UserSession: ObservableObject {
    @AppStorage("displayName") var displayName: String = ""
    // Legacy single-slot password — kept only to migrate the account that
    // was signed up before multi-account support existed.
    @AppStorage("userPassword") private var legacyPassword: String = ""

    /// Fires true for a beat right after a successful sign-in/up so a
    /// global "you're in!" toast can flash. Transient — never persisted.
    @Published var justSignedIn = false

    private let accountsKey = "userAccounts"
    private let topicsKey = "userInterestedTopics"   // [username: [topic]]

    private var accounts: [String: String] {
        get { UserDefaults.standard.dictionary(forKey: accountsKey) as? [String: String] ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: accountsKey) }
    }

    private var allInterestedTopics: [String: [String]] {
        get { (UserDefaults.standard.dictionary(forKey: topicsKey) as? [String: [String]]) ?? [:] }
        set { UserDefaults.standard.set(newValue, forKey: topicsKey) }
    }

    /// Topics the signed-in user picked at sign-up. Empty means "no
    /// preference" — Swipe or Stay then shows hooks from every topic.
    var interestedTopics: [String] {
        guard isSignedIn else { return [] }
        return allInterestedTopics[displayName] ?? []
    }

    /// Stores the current user's topic interests (used to filter Swipe/Stay).
    func setInterestedTopics(_ topics: [String]) {
        guard isSignedIn else { return }
        var all = allInterestedTopics
        all[displayName] = topics
        allInterestedTopics = all
        objectWillChange.send()
    }

    init() {
        migrateLegacyAccount()
    }

    /// Carries the pre-multi-account credentials into the accounts store.
    private func migrateLegacyAccount() {
        guard !displayName.isEmpty, !legacyPassword.isEmpty else { return }
        if accounts[displayName] == nil {
            var all = accounts
            all[displayName] = legacyPassword
            accounts = all
        }
    }

    /// The single source of truth every gated screen (bookmark, swipe,
    /// saved hooks) checks before allowing an action — sign-in state is
    /// derived, not stored separately, so it can never drift out of sync.
    var isSignedIn: Bool {
        !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    enum AuthError: String {
        case wrongPassword = "Incorrect password. Try again."
        case emptyFields = "Please fill in both fields."
        case usernameTaken = "That username is taken. Pick a different one."
    }

    /// Sign up: creates a new local account. Usernames must be unique.
    func signUp(username: String, password: String) -> AuthError? {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !pass.isEmpty else { return .emptyFields }
        guard accounts[name] == nil else { return .usernameTaken }
        var all = accounts
        all[name] = pass
        accounts = all
        displayName = name
        justSignedIn = true
        return nil
    }

    /// Sign in: checks password against the stored account. An unknown
    /// username is treated as a sign-up (matches the app's old behavior).
    func signIn(username: String, password: String) -> AuthError? {
        let name = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let pass = password.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !name.isEmpty, !pass.isEmpty else { return .emptyFields }

        if let stored = accounts[name] {
            if pass != stored { return .wrongPassword }
            displayName = name
            justSignedIn = true
            return nil
        }
        return signUp(username: name, password: pass)
    }

    /// Legacy convenience for backward compatibility.
    func signIn(displayName name: String) {
        displayName = name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Signs out without deleting any account — everyone can sign back in.
    func signOut() {
        displayName = ""
    }
}
