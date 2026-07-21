//
//  EditInterestsView.swift
//  myFirstApp
//
//  Lets a signed-in user change the topics they're interested in. The Swipe
//  or Stay deck reads these on appear, so saving here reshapes what they see.
//

import SwiftUI

struct EditInterestsView: View {
    @EnvironmentObject private var session: UserSession
    @Environment(\.dismiss) private var dismiss
    @State private var selected: Set<String> = []
    @State private var showSaved = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your interests")
                    .font(HPFont.heading).foregroundColor(.white)
                Text("Pick the topics you want to see in Swipe or Stay. Leave all off to see hooks from every topic.")
                    .font(HPFont.body).foregroundColor(.white.opacity(0.8))

                TopicSelectGrid(selected: $selected)

                Button("SAVE") {
                    session.setInterestedTopics(Array(selected))
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { showSaved = true }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) { dismiss() }
                }
                .buttonStyle(HPSecondaryButtonStyle())
                .padding(.top, 4)
            }
            .padding()
        }
        .navigationTitle("")
        .toolbar { ToolbarItem(placement: .principal) { HookPlaygroundTitle(size: 18, twoLines: true) } }
        .navigationBarTitleDisplayMode(.inline)
        .background(HPColor.background)
        .toolbarBackground(HPColor.background, for: .navigationBar)
        .onAppear { selected = Set(session.interestedTopics) }
        .overlay {
            if showSaved {
                Text("Saved!")
                    .font(HPFont.brand(size: 28))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(HPColor.backgroundDark.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }
}
