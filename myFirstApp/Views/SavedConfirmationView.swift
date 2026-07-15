//
//  SavedConfirmationView.swift
//  myFirstApp
//
//  Shown right after saving a hook. Lists everything saved so far.
//

import SwiftUI

struct SavedConfirmationView: View {
    @EnvironmentObject private var store: HookStore
    @Environment(\.dismiss) private var dismiss

    private let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(HPColor.forest)
                    Text("Hook Saved")
                        .font(HPFont.heading)
                }
                .padding(.top, 24)

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
                        .foregroundColor(HPColor.forest)
                }
            }
        }
    }
}

private struct HookThumbnail: View {
    let hook: Hook

    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 10)
                .fill(HPColor.forestLight)
                .frame(height: 80)
                .overlay(
                    Image(systemName: iconName)
                        .font(.title2)
                        .foregroundColor(HPColor.forest)
                )
            Text(hook.source == .existing ? "Existing" : "Test")
                .font(HPFont.caption)
                .foregroundColor(HPColor.textSecondary)
        }
    }

    private var iconName: String {
        switch hook.kind {
        case .link: return "link"
        case .text: return "text.alignleft"
        case .visual: return "photo"
        }
    }
}

#Preview {
    SavedConfirmationView()
        .environmentObject(HookStore())
}
