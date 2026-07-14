//
//  BookmarkButton.swift
//  myFirstApp
//
//  Reusable bookmark toggle — appears on grid cells and detail views.
//

import SwiftUI

struct BookmarkButton: View {
    let hookID: UUID
    @EnvironmentObject private var bookmarks: BookmarkStore

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.2)) {
                bookmarks.toggle(hookID)
            }
        } label: {
            Image(systemName: bookmarks.isSaved(hookID) ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundColor(bookmarks.isSaved(hookID) ? .yellow : .white)
                .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}
