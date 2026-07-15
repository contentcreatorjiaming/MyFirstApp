//
//  AddExistingHookView.swift
//  myFirstApp
//
//  "Add Existing" flow: paste a link to existing content.
//  Link-only for now — paste a URL and enter the real metrics.
//

import SwiftUI

struct AddExistingHookView: View {
    @EnvironmentObject private var session: UserSession
    @EnvironmentObject private var store: HookStore

    @State private var linkURL: String = ""
    @State private var views: String = ""
    @State private var likes: String = ""
    @State private var shares: String = ""
    @State private var comments: String = ""
    @State private var saves: String = ""
    @State private var showSavedConfirmation = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Paste your content link")
                    .font(HPFont.heading)
                    .foregroundColor(.white)

                TextField("https://instagram.com/...", text: $linkURL)
                    .font(HPFont.body)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)

                Text("Performance metrics")
                    .font(HPFont.heading)
                    .foregroundColor(.white)

                metricField("Views", text: $views, icon: "eye")
                metricField("Likes", text: $likes, icon: "heart.fill")
                metricField("Shares", text: $shares, icon: "arrowshape.turn.up.right.fill")
                metricField("Comments", text: $comments, icon: "bubble.left.fill")
                metricField("Saves", text: $saves, icon: "bookmark.fill")

                Button("SAVE") { save() }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue, fullWidth: true))
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
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

    private func metricField(_ label: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
                .frame(width: 24)
            Text(label)
                .font(HPFont.body)
                .foregroundColor(.white)
                .frame(width: 90, alignment: .leading)
            TextField("0", text: text)
                .font(HPFont.body)
                .padding(10)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .keyboardType(.numberPad)
        }
    }

    private var isValid: Bool {
        !linkURL.trimmingCharacters(in: .whitespaces).isEmpty &&
        [views, likes, shares, comments, saves].allSatisfy { Int($0) != nil }
    }

    private func save() {
        let metrics = HookMetrics(
            views: Int(views) ?? 0, likes: Int(likes) ?? 0,
            shares: Int(shares) ?? 0, comments: Int(comments) ?? 0,
            saves: Int(saves) ?? 0
        )
        let hook = Hook(
            id: UUID(), source: .existing, kind: .link,
            linkURL: linkURL, textContent: nil,
            imageFileName: nil, videoFileName: nil,
            metrics: metrics, createdAt: Date(),
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
