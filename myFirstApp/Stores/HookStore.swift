//
//  HookStore.swift
//  myFirstApp
//
//  Local, on-device persistence for hooks. Deliberately shaped like a real
//  backend response (Codable structs, stable IDs, timestamps) so swapping
//  this for a real API later is a data-layer change, not a rewrite.
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class HookStore: ObservableObject {
    @Published private(set) var hooks: [Hook] = []

    private let fileURL: URL
    private let imagesDirectory: URL
    private let videosDirectory: URL

    init() {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        fileURL = documents.appendingPathComponent("hooks.json")
        imagesDirectory = documents.appendingPathComponent("HookImages", isDirectory: true)
        videosDirectory = documents.appendingPathComponent("HookVideos", isDirectory: true)
        try? FileManager.default.createDirectory(at: imagesDirectory, withIntermediateDirectories: true)
        try? FileManager.default.createDirectory(at: videosDirectory, withIntermediateDirectories: true)
        load()
    }

    /// Appends a new hook (from Create/Test) and persists immediately —
    /// this store has no in-memory-only mode, so every write is durable.
    func add(_ hook: Hook) {
        hooks.append(hook)
        save()
    }

    /// Wipes only the seeded `.existing` demo hooks, leaving anything the
    /// user created themselves untouched. Used when reseeding a newer
    /// content version (see SeedData's `hasSeededHooks_vN` versioning).
    func clearExistingSeeded() {
        hooks.removeAll(where: { $0.source == .existing })
        save()
    }

    /// Removes every test hook (community + user-submitted). Used by the
    /// one-time fresh-start reset.
    func removeTestHooks() {
        hooks.removeAll(where: { $0.source == .testNew })
        save()
    }

    /// Removes test hooks authored by the given names — used to clear old
    /// community seed hooks before reseeding so they never duplicate.
    func removeTestHooks(byAuthors authors: Set<String>) {
        hooks.removeAll(where: { $0.source == .testNew && authors.contains($0.authorDisplayName) })
        save()
    }

    /// Lets a creator edit their own hook's text after posting it for testing.
    func updateText(hookID: UUID, newText: String) {
        if let index = hooks.firstIndex(where: { $0.id == hookID }) {
            hooks[index].textContent = newText
            save()
        }
    }

    /// Overwrites the AI-generated insight summary shown on a hook's detail page.
    func updateAISummary(hookID: UUID, newSummary: String) {
        if let index = hooks.firstIndex(where: { $0.id == hookID }) {
            hooks[index].aiSummary = newSummary
            save()
        }
    }

    /// Attaches a real-world outcome (who posted it, what its actual skip
    /// rate turned out to be) to a hook that was tested in the playground
    /// first — this is what closes the loop between prediction and result.
    func claimHook(hookID: UUID, by username: String, skipRate: Double) {
        if let index = hooks.firstIndex(where: { $0.id == hookID }) {
            hooks[index].claimedBy = username
            hooks[index].skipRate = skipRate
            save()
        }
    }

    /// Saves a UIImage's data into the app's documents directory and returns
    /// the filename to store on the Hook. Keeps images out of the JSON blob.
    func saveImage(_ data: Data) -> String {
        let filename = "\(UUID().uuidString).jpg"
        let url = imagesDirectory.appendingPathComponent(filename)
        try? data.write(to: url)
        return filename
    }

    func imageURL(for filename: String) -> URL {
        imagesDirectory.appendingPathComponent(filename)
    }

    func saveVideo(_ sourceURL: URL) -> String {
        let filename = "\(UUID().uuidString).mov"
        let dest = videosDirectory.appendingPathComponent(filename)
        try? FileManager.default.copyItem(at: sourceURL, to: dest)
        return filename
    }

    func videoURL(for filename: String) -> URL {
        videosDirectory.appendingPathComponent(filename)
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(hooks)
            try data.write(to: fileURL)
        } catch {
            print("HookStore save failed: \(error)")
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        do {
            hooks = try JSONDecoder().decode([Hook].self, from: data)
        } catch {
            print("HookStore load failed: \(error)")
        }
    }
}
