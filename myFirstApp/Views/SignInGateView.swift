//
//  SignInGateView.swift
//  myFirstApp
//

import SwiftUI

struct SignInGateView: View {
    @EnvironmentObject private var session: UserSession

    var body: some View {
        Group {
            if session.isSignedIn {
                CreateHubView()
            } else {
                AuthChoiceView()
            }
        }
    }
}

private struct AuthChoiceView: View {
    @State private var showForm = false
    @State private var isSignUp = false
    
    var body: some View {
        ZStack {
            HPGradientBackground()
        }
    }
}
            if showForm {
                AuthFormView(isSignUp: isSignUp)
            } else {
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        Text("hook").font(HPFont.screenTitle)
                        Text("playground").font(HPFont.screenTitle)
                    }.foregroundColor(.white)
                    Spacer().frame(height: 36)
                    HStack(spacing: 14) {
                        Button("SIGN IN") { isSignUp = false; showForm = true }
                            .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue))
                        Button("SIGN UP") { isSignUp = true; showForm = true }
                            .buttonStyle(HPButtonStyle(color: HPColor.pastelPink))
                    }
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
