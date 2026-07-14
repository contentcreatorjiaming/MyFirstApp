//
//  LandingView.swift
//  myFirstApp
//
//  Entry point matching the wireframe's first screen: Research / Create.
//  Research is stubbed for now (out of scope for this pass) — tapping it
//  shows a "coming soon" placeholder rather than crashing or doing nothing.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject private var session: UserSession
    @State private var showResearchComingSoon = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.ignoresSafeArea()

                VStack(spacing: 40) {
                    Text("hook\nplayground")
                        .font(.custom("Snell Roundhand", size: 40))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)

                    HStack(spacing: 16) {
                        Button("RESEARCH") {
                            showResearchComingSoon = true
                        }
                        .buttonStyle(HookButtonStyle(color: .blue))

                        NavigationLink {
                            SignInGateView()
                        } label: {
                            Text("CREATE")
                        }
                        .buttonStyle(HookButtonStyle(color: .pink))
                    }
                }
            }
            .alert("Coming soon", isPresented: $showResearchComingSoon) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("The Research library is being built next — Create works today.")
            }
        }
    }
}

/// Shared pill-button style matching the wireframe's rounded rect buttons.
struct HookButtonStyle: ButtonStyle {
    let color: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

#Preview {
    LandingView()
        .environmentObject(UserSession())
}
