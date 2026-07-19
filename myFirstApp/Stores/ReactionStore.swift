//
//  ReactionStore.swift
//  myFirstApp
//
//  Local persistence for reactions. Includes mock "community" reactions
//  so hooks don't look empty during demo. Tagged as mock so they can be
//  wiped before a real launch.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class ReactionStore: ObservableObject {
    @Published private(set) var reactions: [Reaction] = []

    private let fileURL: URL

    init() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = docs.appendingPathComponent("reactions.json")
        load()
    }

    func add(_ reaction: Reaction) {
        reactions.append(reaction)
        save()
    }

    /// Updates the feedback text on an existing reaction.
    func updateFeedback(for hookID: UUID, author: String, feedback: String) {
        if let index = reactions.lastIndex(where: {
            $0.hookID == hookID && $0.authorDisplayName == author
        }) {
            reactions[index].feedback = feedback
            save()
        }
    }

    /// Switches a user's reaction from one type to another.
    func switchReaction(hookID: UUID, author: String, to newType: ReactionType) {
        if let index = reactions.lastIndex(where: {
            $0.hookID == hookID && $0.authorDisplayName == author
        }) {
            reactions[index] = Reaction(
                id: reactions[index].id,
                hookID: hookID,
                type: newType,
                feedback: reactions[index].feedback,
                authorDisplayName: author,
                createdAt: reactions[index].createdAt
            )
            save()
        }
    }

    /// All reactions for a specific hook.
    func reactions(for hookID: UUID) -> [Reaction] {
        reactions.filter { $0.hookID == hookID }
    }

    /// Count of Stay reactions for a hook.
    func stayCount(for hookID: UUID) -> Int {
        reactions(for: hookID).filter { $0.type == .stay }.count
    }

    /// Count of Swipe reactions for a hook.
    func swipeCount(for hookID: UUID) -> Int {
        reactions(for: hookID).filter { $0.type == .swipe }.count
    }

    /// Written feedback entries for a hook.
    func feedbackEntries(for hookID: UUID) -> [Reaction] {
        reactions(for: hookID).filter { $0.feedback != nil && !$0.feedback!.isEmpty }
    }

    /// Whether a specific user has already reacted to this hook.
    func hasReacted(hookID: UUID, author: String) -> Bool {
        reactions(for: hookID).contains { $0.authorDisplayName == author }
    }

    /// Deduplicates reactions so only a user's most recent reaction per hook counts.
    /// Later entries in the array win, so re-reacting to a hook replaces the earlier
    /// verdict — this is the rule that keeps the Stayed/Swiped tabs honest.
    /// Pure function (no store state) so it is directly unit-testable.
    nonisolated static func latestReactions(perHookFrom reactions: [Reaction], by author: String) -> [Reaction] {
        var latestByHook: [UUID: Reaction] = [:]
        for r in reactions where r.authorDisplayName == author {
            latestByHook[r.hookID] = r
        }
        return Array(latestByHook.values)
    }

    /// Seeds mock community reactions for a set of hook IDs so the app
    /// doesn't look empty during demo. Only runs once (checks if reactions
    /// already exist for those hooks).
    func seedMockReactions(for hookIDs: [UUID]) {
        let existingHookIDs = Set(reactions.map { $0.hookID })
        let newIDs = hookIDs.filter { !existingHookIDs.contains($0) }
        guard !newIDs.isEmpty else { return }

        let mockNames = [
            "alex_creates", "maya.hooks", "contentjay",
            "reelqueen", "hookmaster99", "viralvee",
            "creator.sam", "scrollstopper"
        ]
        let mockFeedback = [
            "Strong opening — I'd definitely keep watching",
            "Too generic, needs a more specific angle",
            "The visual grabs attention immediately",
            "Good curiosity gap but the payoff better deliver",
            "Would work better as a question",
            "This is the kind of hook that stops the scroll",
            "Feels clickbaity — might hurt trust",
            "Love the contrast, makes me want to see the result",
            nil, nil, nil, nil  // not everyone leaves feedback
        ]

        for hookID in newIDs {
            let count = Int.random(in: 4...8)
            for i in 0..<count {
                let type: ReactionType = Bool.random() ? .stay : .swipe
                let reaction = Reaction(
                    id: UUID(),
                    hookID: hookID,
                    type: type,
                    feedback: mockFeedback.randomElement() ?? nil,
                    authorDisplayName: mockNames[i % mockNames.count],
                    createdAt: Date().addingTimeInterval(-Double.random(in: 3600...86400 * 7))
                )
                reactions.append(reaction)
            }
        }
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(reactions)
            try data.write(to: fileURL)
        } catch {
            print("ReactionStore save failed: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            reactions = try JSONDecoder().decode([Reaction].self, from: data)
        } catch {
            print("ReactionStore load failed: \(error)")
        }
    }
}
