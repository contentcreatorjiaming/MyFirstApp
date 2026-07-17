//
//  GlobalNavMenu.swift
//  myFirstApp
//
//  Tappable "hook playground" title that can be placed on any screen.
//  Tapping it opens a full-screen overlay with navigation options.
//

import SwiftUI

struct HookPlaygroundTitle: View {
    @EnvironmentObject private var session: UserSession
    @State private var showMenu = false
    var size: CGFloat = 20
    var twoLines: Bool = false

    var body: some View {
        Button {
            showMenu = true
        } label: {
            if twoLines {
                VStack(spacing: 0) {
                    Text("hook").font(HPFont.brand(size: size))
                    Text("playground").font(HPFont.brand(size: size))
                }
                .foregroundColor(.white)
            } else {
                Text("hook playground")
                    .font(HPFont.brand(size: size))
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .fullScreenCover(isPresented: $showMenu) {
            NavMenuOverlay(isPresented: $showMenu)
        }
    }
}

private struct NavMenuOverlay: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var session: UserSession

    var body: some View {
        NavigationStack {
            ZStack {
                HPGradientBackground()

                VStack(spacing: 0) {
                    // Small title — tap to close
                    Button {
                        isPresented = false
                    } label: {
                        VStack(spacing: 0) {
                            if session.isSignedIn {
                                Text("\(session.displayName)'s")
                                    .font(HPFont.brandRegular(size: 28))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            Text("hook")
                                .font(HPFont.heroTitleSmall)
                            Text("playground")
                                .font(HPFont.heroTitleSmall)
                        }
                        .foregroundColor(.white.opacity(0.85))
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 60)

                    Spacer()

                    VStack(spacing: 28) {
                        NavigationLink {
                            ResearchGridView()
                        } label: {
                            menuLabel("EXPLORE")
                        }

                        NavigationLink {
                            SignInGateView()
                        } label: {
                            menuLabel("CREATE")
                        }

                        if session.isSignedIn {
                            NavigationLink {
                                TestHooksPageView()
                            } label: {
                                menuLabel("SWIPE OR STAY")
                            }
                        }

                        NavigationLink {
                            SavedHooksView()
                        } label: {
                            menuLabel("SAVED HOOKS")
                        }

                        NavigationLink {
                            FeedbackView()
                        } label: {
                            menuLabel("FEEDBACK")
                        }

                        if session.isSignedIn {
                            Button {
                                session.signOut()
                                isPresented = false
                            } label: {
                                menuLabel("SIGN OUT")
                            }
                        }
                    }

                    Spacer()
                    Spacer()
                }
            }
        }
    }

    private func menuLabel(_ text: String) -> some View {
        Text(text)
            .font(HPFont.menuItem)
            .foregroundColor(.white)
            .tracking(2)
    }
}
