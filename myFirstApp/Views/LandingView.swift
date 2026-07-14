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
                HPGradientBackground()

                VStack(spacing: 48) {
                    Spacer()

                    // Brand mark
                    VStack(spacing: 4) {
                        Text("hook")
                            .font(HPFont.heroTitle)
                        Text("playground")
                            .font(HPFont.heroTitle)
                    }
                    .foregroundColor(.white)

                    // Navigation buttons
                    VStack(spacing: 14) {
                        HStack(spacing: 14) {
                            NavigationLink {
                                ResearchGridView()
                            } label: {
                                Text("RESEARCH")
                            }
                            .buttonStyle(HPButtonStyle(color: HPColor.sky))

                            NavigationLink {
                                SignInGateView()
                            } label: {
                                Text("CREATE")
                            }
                            .buttonStyle(HPButtonStyle(color: HPColor.coral))
                        }

                        NavigationLink {
                            SavedHooksView()
                        } label: {
                            Text("SAVED HOOKS")
                        }
                        .buttonStyle(HPButtonStyle(color: HPColor.ink))
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    LandingView()
        .environmentObject(UserSession())
        .environmentObject(HookStore())
        .environmentObject(BookmarkStore())
}
