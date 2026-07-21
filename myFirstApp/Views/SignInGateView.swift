//
//  SignInGateView.swift
//  myFirstApp
//

import SwiftUI

struct SignInGateView: View {
    @EnvironmentObject private var session: UserSession
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if session.isSignedIn {
                // Neutral backdrop — this cover dismisses the instant auth
                // succeeds, dropping the user back on the page they gated from.
                HPGradientBackground()
            } else {
                AuthGateScreen()
            }
        }
        .onChange(of: session.isSignedIn) { _, signedIn in
            if signedIn { dismiss() }
        }
    }
}

/// The sign in / sign up screen (playground background, tappable title,
/// SIGN IN / SIGN UP chooser → form). Used both standalone (inside a gated
/// tab, where authenticating swaps the tab content in place) and by
/// `SignInGateView` (which shows the menu afterward).
struct AuthGateScreen: View {
    @State private var showForm = false
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            HPGradientBackground()
            if !showForm {
                PlaygroundAnimation()
            }
            if showForm {
                AuthFormView(isSignUp: isSignUp)
            } else {
                // Mirrors the homepage layout exactly
                VStack(spacing: 36) {
                    Spacer()
                    // Tappable title — opens the nav menu, like every other screen.
                    HookPlaygroundTitle(size: 52, twoLines: true)
                    Text("test your hooks with creators like you")
                        .font(HPFont.body)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.top, -20)
                    HStack(spacing: 16) {
                        Button("SIGN IN") { isSignUp = false; showForm = true }
                            .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue))
                        Button("SIGN UP") { isSignUp = true; showForm = true }
                            .buttonStyle(HPButtonStyle(color: HPColor.pastelPink))
                    }
                    .padding(.horizontal, 32)
                    Spacer()
                    Spacer()
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showForm)
    }
}

private struct AuthFormView: View {
    let isSignUp: Bool
    @EnvironmentObject private var session: UserSession
    @State private var username = ""
    @State private var password = ""
    @State private var selectedTopics: Set<String> = []
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 40)
                // Tappable title — opens the nav menu, like every other screen.
                HookPlaygroundTitle(size: 28, twoLines: true)
                Text(isSignUp ? "Create your account" : "Welcome back")
                    .font(HPFont.heading).foregroundColor(.white)
                VStack(spacing: 14) {
                    HStack {
                        Text("Username").font(HPFont.body).foregroundColor(.white).frame(width: 85, alignment: .leading)
                        TextField("your name", text: $username)
                            .padding(12).background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .textInputAutocapitalization(.never)
                    }
                    HStack {
                        Text("Password").font(HPFont.body).foregroundColor(.white).frame(width: 85, alignment: .leading)
                        SecureField("password", text: $password)
                            .padding(12).background(Color.white)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }.padding(.horizontal, 24)

                if isSignUp {
                    VStack(spacing: 8) {
                        Text("What are you into?")
                            .font(HPFont.body).foregroundColor(.white)
                        Text("Pick the topics you want to see in Swipe or Stay.")
                            .font(HPFont.caption).foregroundColor(.white.opacity(0.75))
                            .multilineTextAlignment(.center)
                        TopicSelectGrid(selected: $selectedTopics)
                    }.padding(.horizontal, 24)
                }

                if let error = errorMessage {
                    Text(error).font(HPFont.caption).foregroundColor(.black).padding(.horizontal)
                }
                Button("CONTINUE") { submit() }
                    .buttonStyle(HPButtonStyle(color: HPColor.ink))
                    .disabled(username.isEmpty || password.isEmpty)
                    .opacity(username.isEmpty || password.isEmpty ? 0.5 : 1)
                Spacer(minLength: 40)
            }
            .frame(maxWidth: .infinity)
        }
        .scrollDismissesKeyboard(.interactively)
    }

    private func submit() {
        let result: UserSession.AuthError?
        if isSignUp {
            result = session.signUp(username: username, password: password)
        } else {
            result = session.signIn(username: username, password: password)
        }
        if let err = result { errorMessage = err.rawValue; return }
        // Save interests on a fresh sign-up so Swipe or Stay can filter.
        if isSignUp { session.setInterestedTopics(Array(selectedTopics)) }
    }
}
