//
//  BookmarkStore.swift
//  myFirstApp
//
//  Tracks which hooks the current user has bookmarked/saved.
//  Simple set of hook IDs persisted locally via UserDefaults.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class BookmarkStore: ObservableObject {
    @Published private(set) var savedIDs: Set<UUID> = []

    private let key = "bookmarkedHookIDs"

    init() {
        load()
    }

    func isSaved(_ hookID: UUID) -> Bool {
        savedIDs.contains(hookID)
    }

    /// Saves a hook without toggling — used when a hook should be
    /// auto-added to the saved list (e.g. sent to Test).
    func add(_ hookID: UUID) {
        guard !savedIDs.contains(hookID) else { return }
        savedIDs.insert(hookID)
        save()
    }

    func toggle(_ hookID: UUID) {
        if savedIDs.contains(hookID) {
            savedIDs.remove(hookID)
        } else {
            savedIDs.insert(hookID)
        }
        save()
    }

    private func save() {
        let strings = savedIDs.map { $0.uuidString }
        UserDefaults.standard.set(strings, forKey: key)
    }

    private func load() {
        guard let strings = UserDefaults.standard.stringArray(forKey: key) else { return }
        savedIDs = Set(strings.compactMap { UUID(uuidString: $0) })
    }
}
