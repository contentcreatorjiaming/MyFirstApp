//
//  SignInGateView.swift
//  myFirstApp
//

import SwiftUI

struct SignInGateView: View {
    @EnvironmentObject private var session: UserSession
    @State private var showMainMenu = false

    var body: some View {
        Group {
            if session.isSignedIn {
                CreateHubView()
            } else {
                AuthChoiceView()
            }
        }
        .onChange(of: session.isSignedIn) { _, signedIn in
            if signedIn { showMainMenu = true }
        }
        .fullScreenCover(isPresented: $showMainMenu) {
            NavMenuOverlay(isPresented: $showMainMenu)
        }
    }
}

private struct AuthChoiceView: View {
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
                    VStack(spacing: 0) {
                        Text("hook").font(HPFont.heroTitle)
                        Text("playground").font(HPFont.heroTitle)
                    }.foregroundColor(.white)
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
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            VStack(spacing: 0) {
                Text("hook").font(HPFont.heroTitleSmall)
                Text("playground").font(HPFont.heroTitleSmall)
            }.foregroundColor(.white)
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
            if let error = errorMessage {
                Text(error).font(HPFont.caption).foregroundColor(.yellow).padding(.horizontal)
            }
            Button("CONTINUE") { submit() }
                .buttonStyle(HPButtonStyle(color: HPColor.ink))
                .disabled(username.isEmpty || password.isEmpty)
                .opacity(username.isEmpty || password.isEmpty ? 0.5 : 1)
            Spacer()
        }
    }

    private func submit() {
        let result: UserSession.AuthError?
        if isSignUp {
            result = session.signUp(username: username, password: password)
        } else {
            result = session.signIn(username: username, password: password)
        }
        if let err = result { errorMessage = err.rawValue }
    }
}
