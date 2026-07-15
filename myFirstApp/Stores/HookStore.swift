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

    func add(_ hook: Hook) {
        hooks.append(hook)
        save()
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
