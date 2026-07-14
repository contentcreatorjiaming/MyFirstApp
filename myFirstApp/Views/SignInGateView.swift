//
//  SignInGateView.swift
//  myFirstApp
//
//  Mock sign-in/sign-up gate. Captures a display name locally.
//

import SwiftUI

struct SignInGateView: View {
    @EnvironmentObject private var session: UserSession
    @State private var nameInput: String = ""

    var body: some View {
        Group {
            if session.isSignedIn {
                CreateHubView()
            } else {
                ZStack {
                    HPGradientBackground()

                    VStack(spacing: 28) {
                        Text("hook\nplayground")
                            .font(HPFont.screenTitle)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("What should we call you?")
                                .foregroundColor(.white.opacity(0.85))
                                .font(HPFont.subheading)
                            TextField("Display name", text: $nameInput)
                                .padding(14)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .padding(.horizontal, 32)

                        Button("CONTINUE") {
                            session.signIn(displayName: nameInput)
                        }
                        .buttonStyle(HPButtonStyle(color: HPColor.ink))
                        .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                        .opacity(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.5 : 1)
                    }
                }
            }
        }
    }
}

#Preview {
    SignInGateView()
        .environmentObject(UserSession())
}
