//
//  AddExistingHookView.swift
//  myFirstApp
//
//  "Add Existing" flow: user submits a hook pulled from real, already-posted
//  content, along with its real performance metrics.
//

import SwiftUI
import PhotosUI

struct AddExistingHookView: View {
    @EnvironmentObject private var session: UserSession
    @EnvironmentObject private var store: HookStore

    @State private var kind: HookKind = .link
    @State private var linkURL: String = ""
    @State private var textContent: String = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?

    @State private var views: String = ""
    @State private var likes: String = ""
    @State private var shares: String = ""
    @State private var comments: String = ""
    @State private var saves: String = ""

    @State private var showSavedConfirmation = false

    // Matches Instagram's caption character limit as the wireframe notes.
    private let textCharacterLimit = 2200

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("Hook type", selection: $kind) {
                    Text("Link").tag(HookKind.link)
                    Text("Text").tag(HookKind.text)
                    Text("Visual").tag(HookKind.visual)
                }
                .pickerStyle(.segmented)

                contentField

                Text("Real performance metrics")
                    .font(HPFont.heading)

                metricField("Views", text: $views, icon: "eye")
                metricField("Likes", text: $likes, icon: "heart.fill")
                metricField("Shares", text: $shares, icon: "arrowshape.turn.up.right.fill")
                metricField("Comments", text: $comments, icon: "bubble.left.fill")
                metricField("Saves", text: $saves, icon: "bookmark.fill")

                Button("SAVE") { save() }
                    .buttonStyle(HPButtonStyle(color: HPColor.backgroundDark, fullWidth: true))
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
            }
            .padding()
        }
        .navigationTitle("Add Existing")
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
        .sheet(isPresented: $showSavedConfirmation) {
            SavedConfirmationView()
        }
    }

    @ViewBuilder
    private var contentField: some View {
        switch kind {
        case .link:
            TextField("Paste link", text: $linkURL)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.URL)
                .textInputAutocapitalization(.never)
        case .text:
            VStack(alignment: .trailing, spacing: 4) {
                TextEditor(text: $textContent)
                    .frame(height: 100)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.4)))
                    .onChange(of: textContent) { _, newValue in
                        if newValue.count > textCharacterLimit {
                            textContent = String(newValue.prefix(textCharacterLimit))
                        }
                    }
                Text("\(textContent.count)/\(textCharacterLimit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        case .visual:
            VStack(alignment: .leading, spacing: 8) {
                PhotosPicker("Upload image", selection: $photoItem, matching: .images)
                    .onChange(of: photoItem) { _, newItem in
                        Task {
                            if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                imageData = data
                            }
                        }
                    }
                if let imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 200)
                }
            }
        }
    }

    private func metricField(_ label: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(HPColor.backgroundDark)
                .frame(width: 24)
            Text(label)
                .font(HPFont.subheading)
                .frame(width: 90, alignment: .leading)
            TextField("0", text: text)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
        }
    }

    private var isValid: Bool {
        switch kind {
        case .link: guard !linkURL.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        case .text: guard !textContent.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        case .visual: guard imageData != nil else { return false }
        }
        return [views, likes, shares, comments, saves].allSatisfy { Int($0) != nil }
    }

    private func save() {
        var imageFileName: String?
        if kind == .visual, let imageData {
            imageFileName = store.saveImage(imageData)
        }

        let metrics = HookMetrics(
            views: Int(views) ?? 0,
            likes: Int(likes) ?? 0,
            shares: Int(shares) ?? 0,
            comments: Int(comments) ?? 0,
            saves: Int(saves) ?? 0
        )

        let hook = Hook(
            id: UUID(),
            source: .existing,
            kind: kind,
            linkURL: kind == .link ? linkURL : nil,
            textContent: kind == .text ? textContent : nil,
            imageFileName: imageFileName,
            metrics: metrics,
            createdAt: Date(),
            authorDisplayName: session.displayName
        )
        store.add(hook)
        showSavedConfirmation = true
    }
}

#Preview {
    NavigationStack {
        AddExistingHookView()
            .environmentObject(UserSession())
            .environmentObject(HookStore())
    }
}
