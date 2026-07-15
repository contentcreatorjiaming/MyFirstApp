//
//  HookGridCell.swift
//  myFirstApp
//
//  A single cell in the Research grid. Shows a square thumbnail with
//  a visual preview of the hook content and a small overlay badge
//  indicating the hook type.
//

import SwiftUI

struct HookGridCell: View {
    let hook: Hook
    @EnvironmentObject private var store: HookStore

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            // Background — image if visual, colored card if text/link
            cellBackground
                .frame(minHeight: 120)
                .clipped()

            // Type badge + source indicator
            HStack(spacing: 4) {
                Text(typeIcon)
                    .font(.caption2)
                if hook.source == .testNew {
                    Text("TEST")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(HPColor.coral)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                }
            }
            .padding(6)
        }
        .overlay(alignment: .topTrailing) {
            BookmarkButton(hookID: hook.id)
                .padding(6)
        }
        .aspectRatio(1, contentMode: .fill)
    }

    @ViewBuilder
    private var cellBackground: some View {
        switch hook.kind {
        case .visual:
            if let filename = hook.imageFileName,
               let uiImage = UIImage(contentsOfFile: store.imageURL(for: filename).path) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        case .text:
            ZStack {
                HPColor.forest.opacity(0.15)
                Text(hook.textContent ?? "")
                    .font(.caption2)
                    .lineLimit(4)
                    .padding(8)
                    .foregroundColor(.primary)
            }
        case .link:
            ZStack {
                HPColor.sky.opacity(0.12)
                VStack(spacing: 4) {
                    Text("🔗")
                        .font(.title3)
                    Text(hook.linkURL ?? "")
                        .font(.system(size: 9))
                        .lineLimit(2)
                        .foregroundColor(HPColor.sky)
                        .padding(.horizontal, 6)
                }
            }
        }
    }

    private var placeholder: some View {
        Color.gray.opacity(0.2)
            .overlay(Text("🖼️").font(.title2))
    }

    private var typeIcon: String {
        switch hook.kind {
        case .link: return "🔗"
        case .text: return "📝"
        case .visual: return "🖼️"
        }
    }
}
