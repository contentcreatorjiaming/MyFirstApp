//
//  SavedConfirmationView.swift
//  myFirstApp
//
//  Simple confirmation shown right after saving a hook. Also lists everything
//  saved so far as a sanity-check grid — this stands in for the real "Saved
//  Hooks" list, which is out of scope for this pass.
//

import SwiftUI

struct SavedConfirmationView: View {
    @EnvironmentObject private var store: HookStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        NavigationStack {
            VStack {
                Text("Saved ✓")
                    .font(.title2.bold())
                    .padding(.top)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(store.hooks) { hook in
                            HookThumbnail(hook: hook)
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

private struct HookThumbnail: View {
    let hook: Hook

    var body: some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 80)
                .overlay(Text(iconText).font(.title2))
            Text(hook.source == .existing ? "Existing" : "Test")
                .font(.caption2)
        }
    }

    private var iconText: String {
        switch hook.kind {
        case .link: return "🔗"
        case .text: return "📝"
        case .visual: return "🖼️"
        }
    }
}

#Preview {
    SavedConfirmationView()
        .environmentObject(HookStore())
}
