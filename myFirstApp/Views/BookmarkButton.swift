//
//  BookmarkButton.swift
//  myFirstApp
//

import SwiftUI

struct BookmarkButton: View {
    let hookID: UUID
    @EnvironmentObject private var bookmarks: BookmarkStore
    @EnvironmentObject private var session: UserSession
    @State private var showSignInAlert = false

    var body: some View {
        Button {
            if session.isSignedIn {
                withAnimation(.snappy(duration: 0.2)) {
                    bookmarks.toggle(hookID)
                }
            } else {
                showSignInAlert = true
            }
        } label: {
            Image(systemName: bookmarks.isSaved(hookID) ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .alert("Sign in required", isPresented: $showSignInAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Sign in to save hooks.")
        }
    }
}
