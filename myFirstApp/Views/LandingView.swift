//
//  LandingView.swift
//  myFirstApp
//
//  Landing screen: tappable "hook playground" title that expands into
//  a navigation menu (Research / Create / Saved Hooks).
//

import SwiftUI

struct LandingView: View {
    @EnvironmentObject private var session: UserSession
    @State private var menuOpen = false

    var body: some View {
        NavigationStack {
            ZStack {
                HPGradientBackground()

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

    // MARK: - Collapsed: big centered title, tap to open

    private var collapsedLayout: some View {
        VStack {
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

            Spacer()
            Spacer()
        }
    }

    // MARK: - Expanded: small title at top, menu below

    private var expandedLayout: some View {
        VStack(spacing: 0) {
            // Small title at top — tap to collapse
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
            .padding(.top, 60)

            Spacer()

            // Menu options
            VStack(spacing: 28) {
                NavigationLink {
                    ResearchGridView()
                } label: {
                    menuLabel("RESEARCH")
                }

                NavigationLink {
                    SignInGateView()
                } label: {
                    menuLabel("CREATE")
                }

                NavigationLink {
                    SavedHooksView()
                } label: {
                    menuLabel("SAVED HOOKS")
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
