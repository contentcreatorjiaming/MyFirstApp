//
//  BookmarkButton.swift
//  myFirstApp
//

import SwiftUI

struct BookmarkButton: View {
    let hookID: UUID
    @EnvironmentObject private var bookmarks: BookmarkStore
    @EnvironmentObject private var session: UserSession
    @State private var showSignIn = false

    var body: some View {
        Button {
            if session.isSignedIn {
                withAnimation(.snappy(duration: 0.2)) {
                    bookmarks.toggle(hookID)
                }
            } else {
                showSignIn = true
            }
        } label: {
            Image(systemName: bookmarks.isSaved(hookID) ? "bookmark.fill" : "bookmark")
                .font(.title3)
                .foregroundColor(.white)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showSignIn) {
            NavigationStack {
                SignInGateView()
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") { showSignIn = false }
                                .foregroundColor(.white)
                        }
                    }
            }
        }
    }
}
