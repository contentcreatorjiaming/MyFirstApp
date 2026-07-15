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
            cellBackground
                .frame(minHeight: 120)
                .clipped()
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
                HPColor.backgroundDark.opacity(0.15)
                Text(hook.textContent ?? "")
                    .font(.caption2)
                    .lineLimit(4)
                    .padding(8)
                    .foregroundColor(.primary)
            }
        case .link:
            ZStack {
                HPColor.pastelBlue.opacity(0.12)
                VStack(spacing: 4) {
                    Image(systemName: "link")
                        .font(.title3)
                    Text(hook.linkURL ?? "")
                        .font(.system(size: 9))
                        .lineLimit(2)
                        .foregroundColor(HPColor.pastelBlue)
                        .padding(.horizontal, 6)
                }
            }
        case .video:
            ZStack {
                HPColor.pastelPink.opacity(0.15)
                Image(systemName: "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(HPColor.pastelPink)
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
        case .video: return "🎬"
        }
    }
}
