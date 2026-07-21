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

struct NavMenuOverlay: View {
    @Binding var isPresented: Bool
    @EnvironmentObject private var session: UserSession

    var body: some View {
        NavigationStack {
            ZStack {
                HPGradientBackground()
                PlaygroundAnimation(showSeesaw: false)

                VStack(spacing: 0) {
                    // Small title — tap to close
                    Button {
                        isPresented = false
                    } label: {
                        VStack(spacing: 0) {
                            if session.isSignedIn {
                                PoppingUsername(name: session.displayName)
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
                            TestHooksPageView()
                        } label: {
                            menuLabel("SWIPE OR STAY")
                        }

                        NavigationLink {
                            TestNewHookView()
                        } label: {
                            menuLabel("TEST MY HOOK")
                        }

                        NavigationLink {
                            ResearchGridView()
                        } label: {
                            menuLabel("EXPLORE")
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
        .signInToast()
    }

    private func menuLabel(_ text: String) -> some View {
        Text(text)
            .font(HPFont.menuItem)
            .foregroundColor(.white)
            .tracking(2)
    }
}

/// A global "you're in!" flash that appears then disappears the moment auth
/// succeeds — mirrors the "Sent!" toast in the swipe flow. Lives on a
/// persistent container (LandingView, the nav menu) rather than the sign-in
/// screen itself, since that screen is swapped out the instant sign-in lands.
struct SignInToast: ViewModifier {
    @EnvironmentObject private var session: UserSession
    // Local, self-contained animation state. Crucially the toast is a ZStack
    // sibling of `content` (not an .overlay/.animation ON it) — putting an
    // implicit animation on a NavigationStack made sign-in re-renders
    // spuriously activate a menu link and jump the user to Saved Hooks.
    @State private var show = false

    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                Text("you're in!")
                    .font(HPFont.brand(size: 28))
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 14)
                    .background(HPColor.backgroundDark.opacity(0.8))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }
        }
        .onChange(of: session.justSignedIn) { _, isShowing in
            guard isShowing else { return }
            // Consume the signal immediately so the flag never lingers.
            session.justSignedIn = false
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { show = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.easeOut(duration: 0.3)) { show = false }
            }
        }
    }
}

extension View {
    /// Flashes "you're in!" over this view whenever a sign-in/up succeeds.
    func signInToast() -> some View { modifier(SignInToast()) }
}

/// The signed-in user's name that pops in above the title (scales up with a
/// springy overshoot, then settles) — shown when the menu opens after auth.
struct PoppingUsername: View {
    let name: String
    @State private var appeared = false

    var body: some View {
        Text("\(name)'s")
            .font(HPFont.brandRegular(size: 28))
            .foregroundColor(.white.opacity(0.7))
            .scaleEffect(appeared ? 1 : 0.3)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                appeared = false
                withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                    appeared = true
                }
            }
    }
}
