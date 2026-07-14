//
//  SignInGateView.swift
//  myFirstApp
//
//  Mock sign-in/sign-up gate. Since there's no real backend yet, this just
//  captures a display name locally — matches the wireframe's Sign In / Sign
//  Up screen, minus real credential handling.
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
                    Color.green.ignoresSafeArea()

                    VStack(spacing: 24) {
                        Text("hook\nplayground")
                            .font(.custom("Snell Roundhand", size: 32))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("What should we call you?")
                                .foregroundColor(.white)
                                .font(.subheadline)
                            TextField("Display name", text: $nameInput)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        .padding(.horizontal, 32)

                        Button("CONTINUE") {
                            session.signIn(displayName: nameInput)
                        }
                        .buttonStyle(HookButtonStyle(color: .black))
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
