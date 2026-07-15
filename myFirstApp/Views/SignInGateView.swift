//
//  SignInGateView.swift
//  myFirstApp
//
//  Auth gate: Sign In / Sign Up → username + password form.
//

import SwiftUI

struct SignInGateView: View {
    @EnvironmentObject private var session: UserSession
    @State private var showMenuAfterSignIn = false

    var body: some View {
        Group {
            if session.isSignedIn && !showMenuAfterSignIn {
                CreateHubView()
            } else if session.isSignedIn && showMenuAfterSignIn {
                // Just signed in — show menu
                CreateHubView()
                    .onAppear { showMenuAfterSignIn = false }
            } else {
                AuthChoiceView(onSignIn: { showMenuAfterSignIn = true })
            }
        }
    }
}

private struct AuthChoiceView: View {
    var onSignIn: () -> Void = {}
    @State private var showForm = false
    @State private var isSignUp = false

    var body: some View {
        ZStack {
            HPGradientBackground()

            if showForm {
                AuthFormView(isSignUp: isSignUp, onSignIn: onSignIn)
            } else {
                VStack(spacing: 36) {
                    VStack(spacing: 0) {
                        Text("hook")
                            .font(HPFont.screenTitle)
                        Text("playground")
                            .font(HPFont.screenTitle)
                    }
                    .foregroundColor(.white)

                    HStack(spacing: 14) {
                        Button("SIGN IN") {
                            isSignUp = false
                            showForm = true
                        }
                        .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue))

                        Button("SIGN UP") {
                            isSignUp = true
                            showForm = true
                        }
                        .buttonStyle(HPButtonStyle(color: HPColor.pastelPink))
                    }
                }
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showForm)
    }
}

private struct AuthFormView: View {
    let isSignUp: Bool
    var onSignIn: () -> Void = {}
    @EnvironmentObject private var session: UserSession
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 0) {
                Text("hook")
                    .font(HPFont.heroTitleSmall)
                Text("playground")
                    .font(HPFont.heroTitleSmall)
            }
            .foregroundColor(.white)

            Text(isSignUp ? "Create your account" : "Welcome back")
                .font(HPFont.heading)
                .foregroundColor(.white)

            VStack(spacing: 14) {
                // Username
                HStack {
                    Text("Username")
                        .font(HPFont.body)
                        .foregroundColor(.white)
                        .frame(width: 85, alignment: .leading)
                    TextField("your name", text: $username)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .textInputAutocapitalization(.never)
                }

                // Password
                HStack {
                    Text("Password")
                        .font(HPFont.body)
                        .foregroundColor(.white)
                        .frame(width: 85, alignment: .leading)
                    SecureField("password", text: $password)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.horizontal, 24)

            if let error = errorMessage {
                Text(error)
                    .font(HPFont.caption)
                    .foregroundColor(.yellow)
                    .padding(.horizontal)
            }

            Button("CONTINUE") {
                submit()
            }
            .buttonStyle(HPButtonStyle(color: HPColor.ink))
            .disabled(username.isEmpty || password.isEmpty)
            .opacity(username.isEmpty || password.isEmpty ? 0.5 : 1)

            // Divider
            HStack {
                Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.3))
                Text("or").font(HPFont.caption).foregroundColor(.white.opacity(0.6))
                Rectangle().frame(height: 1).foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 40)

            Button {
                // Mock Google sign-in — just creates an account
                session.signIn(displayName: "Google User")
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "globe")
                    Text("Sign in with Google")
                        .font(HPFont.body)
                }
            }
            .buttonStyle(HPSecondaryButtonStyle())
            .padding(.horizontal, 40)
        }
    }

    private func submit() {
        let result: UserSession.AuthError?
        if isSignUp {
            result = session.signUp(username: username, password: password)
        } else {
            result = session.signIn(username: username, password: password)
        }
        if let err = result {
            errorMessage = err.rawValue
        }
    }
}

#Preview {
    SignInGateView()
        .environmentObject(UserSession())
}
