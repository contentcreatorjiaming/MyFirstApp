//
//  LandingView.swift
//  myFirstApp
//
//  Entry point matching the wireframe: Research / Create / Saved Hooks.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject private var session: UserSession

    var body: some View {
        NavigationStack {
            ZStack {
                Color.green.ignoresSafeArea()

                VStack(spacing: 40) {
                    Text("hook\nplayground")
                        .font(.custom("Snell Roundhand", size: 40))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)

                    VStack(spacing: 14) {
                        HStack(spacing: 16) {
                            NavigationLink {
                                ResearchGridView()
                            } label: {
                                Text("RESEARCH")
                            }
                            .buttonStyle(HookButtonStyle(color: .blue))

                            NavigationLink {
                                SignInGateView()
                            } label: {
                                Text("CREATE")
                            }
                            .buttonStyle(HookButtonStyle(color: .pink))
                        }

                        NavigationLink {
                            SavedHooksView()
                        } label: {
                            Text("SAVED HOOKS")
                        }
                        .buttonStyle(HookButtonStyle(color: .black))
                    }
                }
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
        .environmentObject(HookStore())
        .environmentObject(BookmarkStore())
}
