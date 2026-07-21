//
//  AddExistingHookView.swift
//  myFirstApp
//
//  "Add" flow: paste a link with metrics. Claim flow is now on the
//  detail view (integrated into explore). Saved V1 is backed up.
//

import SwiftUI

struct AddExistingHookView: View {
    @EnvironmentObject private var session: UserSession
    @EnvironmentObject private var store: HookStore
    @Environment(\.dismiss) private var dismiss

    @State private var linkURL: String = ""
    @State private var views: String = ""
    @State private var likes: String = ""
    @State private var shares: String = ""
    @State private var comments: String = ""
    @State private var saves: String = ""
    @State private var reposts: String = ""
    @State private var navigateToExplore = false
    @State private var selectedTopics: Set<String> = []

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Paste content link")
                    .font(HPFont.heading)
                    .foregroundColor(.white)

                TextField("", text: $linkURL, prompt: Text("Enter link here").foregroundColor(.gray))
                    .font(HPFont.body)
                    .foregroundColor(HPColor.backgroundDark)
                    .tint(HPColor.backgroundDark)
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .keyboardType(.URL)
                    .textInputAutocapitalization(.never)

                Text("Topics")
                    .font(HPFont.heading)
                    .foregroundColor(.white)
                Text("Pick at least one so people can find it when filtering.")
                    .font(HPFont.caption)
                    .foregroundColor(.white.opacity(0.7))
                topicChips

                Text("Performance metrics")
                    .font(HPFont.heading)
                    .foregroundColor(.white)

                metricField("Views", text: $views, icon: "eye")
                metricField("Shares", text: $shares, icon: "arrowshape.turn.up.right.fill")
                metricField("Likes", text: $likes, icon: "heart.fill")
                metricField("Saves", text: $saves, icon: "bookmark.fill")
                metricField("Reposts", text: $reposts, icon: "arrow.2.squarepath")
                metricField("Comments", text: $comments, icon: "bubble.left.fill")

                Button("SAVE") { save() }
                    .buttonStyle(HPSecondaryButtonStyle())
                    .disabled(!isValid)
                    .opacity(isValid ? 1 : 0.5)
            }
            .padding()
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) } }
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
        .navigationDestination(isPresented: $navigateToExplore) {
            ResearchGridView()
        }
    }

    private var topicChips: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 110), spacing: 8)], spacing: 8) {
            ForEach(HookTopics.all, id: \.self) { topic in
                let isOn = selectedTopics.contains(topic)
                Button {
                    if isOn { selectedTopics.remove(topic) } else { selectedTopics.insert(topic) }
                } label: {
                    Text(topic)
                        .font(HPFont.caption)
                        .foregroundColor(isOn ? HPColor.backgroundDark : .white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isOn ? Color.white : Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func metricField(_ label: String, text: Binding<String>, icon: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundColor(.white).frame(width: 24)
            Text(label).font(HPFont.body).foregroundColor(.white).frame(width: 90, alignment: .leading)
            TextField("0", text: text)
                .font(HPFont.body).padding(10).background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8)).keyboardType(.numberPad)
        }
    }

    /// Parses "249,166", " 22182 ", "3.3K" etc. into an Int.
    private func parseMetric(_ raw: String) -> Int? {
        var s = raw.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: ",", with: "")
            .lowercased()
        var multiplier = 1.0
        if s.hasSuffix("k") { multiplier = 1_000; s.removeLast() }
        else if s.hasSuffix("m") { multiplier = 1_000_000; s.removeLast() }
        guard let value = Double(s) else { return nil }
        return Int(value * multiplier)
    }

    private var isValid: Bool {
        !linkURL.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedTopics.isEmpty &&
        [views, shares, likes, saves, reposts, comments].allSatisfy { parseMetric($0) != nil }
    }

    private func save() {
        let metrics = HookMetrics(
            views: parseMetric(views) ?? 0, shares: parseMetric(shares) ?? 0,
            likes: parseMetric(likes) ?? 0, saves: parseMetric(saves) ?? 0,
            reposts: parseMetric(reposts) ?? 0, comments: parseMetric(comments) ?? 0
        )
        let hook = Hook(
            id: UUID(), source: .existing, kind: .link,
            linkURL: linkURL, textContent: nil,
            imageFileName: nil, videoFileName: nil,
            metrics: metrics, createdAt: Date(), datePosted: nil,
            authorDisplayName: session.displayName,
            aiSummary: nil, skipRate: nil, claimedBy: nil,
            topics: HookTopics.all.filter { selectedTopics.contains($0) }
        )
        store.add(hook)
        navigateToExplore = true
    }
}
