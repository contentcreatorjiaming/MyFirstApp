//
//  ResearchGridView.swift
//  myFirstApp
//
//  Instagram-explore-style grid of all hooks in the library. Tapping a
//  hook opens the detail view with full content and metrics.
//

import SwiftUI

struct ResearchGridView: View {
    @EnvironmentObject private var store: HookStore

    private let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2)
    ]

    var body: some View {
        ScrollView {
            if store.hooks.isEmpty {
                emptyState
            } else {
                LazyVGrid(columns: columns, spacing: 2) {
                    ForEach(store.hooks) { hook in
                        NavigationLink {
                            HookDetailView(hook: hook)
                        } label: {
                            HookGridCell(hook: hook)
                        }
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .navigationTitle("Research")
        .navigationBarTitleDisplayMode(.inline)
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No hooks yet")
                .font(HPFont.heading)
                .foregroundColor(.secondary)
            Text("Create a hook first, or check back\nwhen seed data is loaded.")
                .font(HPFont.subheading)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            Spacer()
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}

#Preview {
    NavigationStack {
        ResearchGridView()
            .environmentObject(HookStore())
    }
}
