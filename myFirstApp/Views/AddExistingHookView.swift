//
//  AddExistingHookView.swift
//  myFirstApp
//
//  "Add" flow: user chooses between CLAIM (claim an existing reel as theirs)
//  or ADD (paste a new link with metrics). The original link+metrics form
//  is saved as AddExistingHookView_SAVED_V1.swift.bak for future reference.
//

import SwiftUI

struct AddExistingHookView: View {
    var body: some View {
        ZStack {
            HPGradientBackground()

            VStack(spacing: 36) {
                HookPlaygroundTitle(size: 28)

                HStack(spacing: 14) {
                    NavigationLink {
                        ClaimHookView()
                    } label: {
                        Text("CLAIM")
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue))

                    NavigationLink {
                        AddLinkHookView()
                    } label: {
                        Text("ADD")
                    }
                    .buttonStyle(HPButtonStyle(color: HPColor.pastelPink))
                }
                .padding(.horizontal, 32)
            }
        }
    }
}

// MARK: - Claim: select an existing reel from Explore and add skip rate

struct ClaimHookView: View {
    @EnvironmentObject private var store: HookStore
    @EnvironmentObject private var session: UserSession

    private var existingHooks: [Hook] {
        store.hooks.filter { $0.source == .existing }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Select a reel to claim as yours")
                    .font(HPFont.heading)
                    .foregroundColor(.white)

                Text("Link your Instagram and claim a reel from the library. Add your skip rate data.")
                    .font(HPFont.body)
                    .foregroundColor(.white.opacity(0.7))

                ForEach(existingHooks) { hook in
                    if let url = hook.linkURL {
                        ClaimCard(hook: hook, url: url)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 16) } }
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
    }
}

private struct ClaimCard: View {
    let hook: Hook
    let url: String
    @State private var claimed = false
    @State private var skipRate: String = ""

    private var shortURL: String {
        url.replacingOccurrences(of: "https://www.instagram.com/", with: "ig/")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(shortURL)
                .font(HPFont.caption)
                .foregroundColor(HPColor.backgroundDark)

            if let m = hook.metrics {
                Text("\(formatNumber(m.views)) views")
                    .font(HPFont.caption)
                    .foregroundColor(HPColor.backgroundDark.opacity(0.6))
            }

            if claimed {
                HStack {
                    Text("Skip rate %")
                        .font(HPFont.body)
                        .foregroundColor(HPColor.backgroundDark)
                    TextField("e.g. 42", text: $skipRate)
                        .font(HPFont.body)
                        .padding(8)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .keyboardType(.numberPad)
                        .frame(width: 80)
                }
            } else {
                Button("This is mine") {
                    claimed = true
                }
                .buttonStyle(HPSecondaryButtonStyle())
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.92))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n) / 1_000) }
        return "\(n)"
    }
}

// MARK: - Add: paste link + metrics (original flow)

struct AddLinkHookView: View {
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
                Text("Paste content link")
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
                    .buttonStyle(HPSecondaryButtonStyle())
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
            views: Int(views) ?? 0, shares: Int(shares) ?? 0,
            likes: Int(likes) ?? 0, saves: Int(saves) ?? 0,
            reposts: 0, comments: Int(comments) ?? 0
        )
        let hook = Hook(
            id: UUID(), source: .existing, kind: .link,
            linkURL: linkURL, textContent: nil,
            imageFileName: nil, videoFileName: nil,
            metrics: metrics, createdAt: Date(), datePosted: nil,
            authorDisplayName: session.displayName
        )
        store.add(hook)
        showSavedConfirmation = true
    }
}
