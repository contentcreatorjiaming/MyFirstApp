//
//  Hook.swift
//  myFirstApp
//
//  Model representing a single hook, either an existing one pulled from
//  real content (with real performance metrics) or a new untested idea
//  submitted for community feedback.
//

import Foundation

enum HookKind: String, Codable, CaseIterable {
    case link
    case text
    case visual
    case video
}

enum HookSource: String, Codable {
    case existing   // pulled from real, already-posted content, with real metrics
    case testNew    // a fresh idea, not yet posted, no metrics
}

struct HookMetrics: Codable, Equatable {
    var views: Int
    var shares: Int
    var likes: Int
    var saves: Int
    var reposts: Int
    var comments: Int
}

struct Hook: Identifiable, Codable, Equatable {
    let id: UUID
    var source: HookSource
    var kind: HookKind

    // Content — only the field matching `kind` is expected to be populated.
    var linkURL: String?
    var textContent: String?
    var imageFileName: String?   // filename within the app's documents/HookImages dir
    var videoFileName: String?   // filename within the app's documents/HookVideos dir

    var metrics: HookMetrics?
    var createdAt: Date
    var datePosted: Date?
    var authorDisplayName: String
    var aiSummary: String?
    var skipRate: Double?
    var claimedBy: String?
}
