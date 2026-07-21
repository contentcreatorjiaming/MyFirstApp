//
//  Reaction.swift
//  myFirstApp
//
//  Represents a single user reaction to a hook: a quick binary signal
//  (Stay or Swipe) plus optional written feedback explaining why.
//

import Foundation

enum ReactionType: String, Codable {
    case stay    // "this would make me keep watching"
    case swipe   // "I'd scroll past this"
}

struct Reaction: Identifiable, Codable, Equatable {
    let id: UUID
    let hookID: UUID
    let type: ReactionType
    var feedback: String?       // optional written explanation
    let authorDisplayName: String
    let createdAt: Date
}
