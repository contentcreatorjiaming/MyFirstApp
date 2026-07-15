//
//  TestNewHookView.swift
//  myFirstApp
//
//  "Test New" flow: user submits a brand-new, unposted hook idea (text or
//  visual only — no link, since there's no live content to link to yet)
//  for eventual community feedback. No metrics: it hasn't been posted.
//

import SwiftUI
import PhotosUI

struct TestNewHookView: View {
    @EnvironmentObject private var session: UserSession
    @EnvironmentObject private var store: HookStore

    @State private var kind: HookKind = .text
    @State private var textContent: String = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var imageData: Data?
    @State private var showSavedConfirmation = false

    private let textCharacterLimit = 2200

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Picker("Hook type", selection: $kind) {
                    Text("Text").tag(HookKind.text)
                    Text("Visual").tag(HookKind.visual)
                }
                .pickerStyle(.segmented)

                contentField

                Text("No metrics needed — this hook hasn't been posted yet. Save it to get community feedback before you post.")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Button("SAVE") { save() }
                    .buttonStyle(HPButtonStyle(color: HPColor.backgroundDark, fullWidth: true))
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding()
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 16) } }
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
        .sheet(isPresented: $showSavedConfirmation) {
            SavedConfirmationView()
        }
    }

    @ViewBuilder
    private var contentField: some View {
        switch kind {
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
        case .link:
            EmptyView() // not offered for Test New — no live content to link to
        }
    }

    private var isValid: Bool {
        switch kind {
        case .text: return !textContent.trimmingCharacters(in: .whitespaces).isEmpty
        case .visual: return imageData != nil
        case .link: return false
        }
    }

    private func save() {
        var imageFileName: String?
        if kind == .visual, let imageData {
            imageFileName = store.saveImage(imageData)
        }

        let hook = Hook(
            id: UUID(),
            source: .testNew,
            kind: kind,
            linkURL: nil,
            textContent: kind == .text ? textContent : nil,
            imageFileName: imageFileName,
            metrics: nil,
            createdAt: Date(),
            authorDisplayName: session.displayName
        )
        store.add(hook)
        showSavedConfirmation = true
    }
}

#Preview {
    NavigationStack {
        TestNewHookView()
            .environmentObject(UserSession())
            .environmentObject(HookStore())
    }
}
