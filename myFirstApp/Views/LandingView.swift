//
//  LandingView.swift
//  myFirstApp
//
//  Landing: tappable "hook playground" title with Research/Create buttons
//  visible. Tapping title expands the full nav menu.
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject private var session: UserSession
    @State private var menuOpen = false

    // Flip to true to bring back the ballpit background version.
    private let useBallpit = false

    var body: some View {
        NavigationStack {
            ZStack {
                HPGradientBackground()
                if useBallpit {
                    BallpitBackground()
                } else {
                    PlaygroundAnimation(
                        showSeesaw: !(menuOpen && session.isSignedIn),
                        seesawY: menuOpen ? 0.72 : 0.57
                    )
                }

                VStack(spacing: 0) {
                    if menuOpen {
                        expandedLayout
                    } else {
                        collapsedLayout
                    }
                }
                .animation(.spring(response: 0.45, dampingFraction: 0.8), value: menuOpen)
            }
        }
    }

    // MARK: - Collapsed: title + two buttons

    private var collapsedLayout: some View {
        VStack(spacing: 36) {
            Spacer()

            Button {
                menuOpen = true
            } label: {
                VStack(spacing: 0) {
                    Text("hook")
                        .font(HPFont.heroTitle)
                    Text("playground")
                        .font(HPFont.heroTitle)
                }
                .foregroundColor(.white)
            }
            .buttonStyle(.plain)

            // Research + Create buttons
            HStack(spacing: 16) {
                NavigationLink {
                    ResearchGridView()
                } label: {
                    Text("EXPLORE")
                }
                .buttonStyle(HPButtonStyle(color: HPColor.pastelPink))

                NavigationLink {
                    SignInGateView()
                } label: {
                    Text("CREATE")
                }
                .buttonStyle(HPButtonStyle(color: HPColor.pastelBlue))
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
    }

    // MARK: - Expanded: small title at top, full menu

    private var expandedLayout: some View {
        VStack(spacing: 0) {
            if session.isSignedIn {
                Text("\(session.displayName)'s")
                    .font(HPFont.brandRegular(size: 28))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.top, 55)
            }

            Button {
                menuOpen = false
            } label: {
                VStack(spacing: 0) {
                    Text("hook")
                        .font(HPFont.heroTitleSmall)
                    Text("playground")
                        .font(HPFont.heroTitleSmall)
                }
                .foregroundColor(.white.opacity(0.85))
            }
            .buttonStyle(.plain)
            .padding(.top, session.isSignedIn ? 4 : 60)

            Spacer()

            VStack(spacing: 28) {
                NavigationLink { ResearchGridView() } label: { menuLabel("EXPLORE") }
                NavigationLink { SignInGateView() } label: { menuLabel("CREATE") }
                NavigationLink { TestHooksPageView() } label: { menuLabel("STAY OR SWIPE") }
                NavigationLink { SavedHooksView() } label: { menuLabel("SAVED HOOKS") }
                NavigationLink { FeedbackView() } label: { menuLabel("FEEDBACK") }

                if session.isSignedIn {
                    Button {
                        session.signOut()
                        menuOpen = false
                    } label: { menuLabel("SIGN OUT") }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .bottom)))

            Spacer()
            Spacer()
        }
    }

    private func menuLabel(_ text: String) -> some View {
        Text(text)
            .font(HPFont.menuItem)
            .foregroundColor(.white)
            .tracking(2)
    }
}

#Preview {
    LandingView()
        .environmentObject(UserSession())
        .environmentObject(HookStore())
        .environmentObject(BookmarkStore())
        .environmentObject(ReactionStore())
}
