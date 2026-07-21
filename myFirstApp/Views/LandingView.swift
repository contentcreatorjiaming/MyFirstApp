//
//  LandingView.swift
//  myFirstApp
//
//  Landing: tappable "hook playground" title with Research/Create buttons
//  visible. Tapping title expands the full nav menu.
//

import Combine
import SwiftUI

struct LandingView: View {
    @EnvironmentObject private var session: UserSession
    @EnvironmentObject private var store: HookStore
    @State private var menuOpen = false

    /// User-submitted hooks that feed the homepage floating cards.
    private var deckHooks: [Hook] {
        store.hooks.filter { $0.source == .testNew && $0.textContent != nil }
    }

    /// Explore reels (with metrics) that feed the floating metric card.
    private var exploreReels: [Hook] {
        store.hooks.filter { $0.source == .existing }
    }

    // Flip to true to bring back the ballpit background version.
    private let useBallpit = false

    var body: some View {
        NavigationStack {
            ZStack {
                HPGradientBackground()
                if useBallpit {
                    BallpitBackground()
                } else {
                    // No seesaw on the homepage — it sat right where the
                    // floating cards go, so the two collided.
                    PlaygroundAnimation(showSeesaw: false, seesawY: 0.64, homeVariant: true)
                }

                // Floating collage of hook cards + metric boxes, in the
                // clear band between the title and the bottom equipment.
                if !menuOpen && !deckHooks.isEmpty {
                    FloatingShowcase(hooks: deckHooks, reels: exploreReels)
                        .transition(.opacity)
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
            .signInToast()
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

            Text("test your hooks with creators like you")
                .font(HPFont.body)
                .foregroundColor(.white.opacity(0.85))
                .padding(.top, -20)

            Text("tap title for menu")
                .font(HPFont.caption)
                .foregroundColor(.white.opacity(0.7))

            Spacer()
            Spacer()
            Spacer()
        }
    }

    // MARK: - Expanded: small title at top, full menu

    private var expandedLayout: some View {
        VStack(spacing: 0) {
            if session.isSignedIn {
                PoppingUsername(name: session.displayName)
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
                NavigationLink { TestHooksPageView() } label: { menuLabel("SWIPE OR STAY") }
                NavigationLink { TestNewHookView() } label: { menuLabel("TEST MY HOOK") }
                NavigationLink { ResearchGridView() } label: { menuLabel("EXPLORE") }
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

/// Homepage collage: a couple of user-hook cards and stat boxes scattered
/// across the clear middle band, each gently bobbing so the screen feels alive.
/// The two hook cards crossfade through every user hook on a timer.
private struct FloatingShowcase: View {
    let hooks: [Hook]        // community/user test hooks
    let reels: [Hook]        // explore reels (with metrics)

    @State private var tick = 0
    @State private var hookIndex = 0
    @State private var skipIndex = 0
    @State private var reelIndex = 0
    // Alternates between the hook card and the stat pair. The skip-rate box and
    // metric card change together (they read as one unit), on the off-beat from
    // the hook card so there's always motion somewhere on screen.
    private let timer = Timer.publish(every: 1.4, on: .main, in: .common).autoconnect()

    private let skipRates: [Double] = [18, 26.5, 33, 41, 47, 52, 29, 61]

    private var hookA: Hook { hooks[hookIndex % hooks.count] }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Top row: SWIPE — hook — STAY
                FloatingBob(delay: 1.1) { iconBox("xmark", "SWIPE") }
                    .rotationEffect(.degrees(-6))
                    .position(x: w * 0.15, y: h * 0.55)

                FloatingBob(delay: 0.0) { hookCard(hookA, slot: "A") }
                    .rotationEffect(.degrees(-2))
                    .position(x: w * 0.50, y: h * 0.55)

                FloatingBob(delay: 0.7) { iconBox("checkmark", "STAY") }
                    .rotationEffect(.degrees(6))
                    .position(x: w * 0.85, y: h * 0.55)

                // Bottom row: changing skip-rate box — changing explore metric card
                FloatingBob(delay: 0.5) { skipRateBox }
                    .rotationEffect(.degrees(-5))
                    .position(x: w * 0.24, y: h * 0.71)

                if !reels.isEmpty {
                    FloatingBob(delay: 0.9) { exploreMetricCard }
                        .rotationEffect(.degrees(4))
                        .position(x: w * 0.66, y: h * 0.71)
                }
            }
        }
        .onReceive(timer) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                if tick.isMultiple(of: 2) {
                    if hooks.count > 1 { hookIndex += 1 }
                } else {
                    // Skip-rate box and metric card change in sync.
                    skipIndex += 1
                    reelIndex += 1
                }
            }
            tick += 1
        }
    }

    // MARK: - Changing cards

    private var skipRateBox: some View {
        let rate = skipRates[skipIndex % skipRates.count]
        let text = rate.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f%%", rate)
            : String(format: "%.1f%%", rate)
        return VStack(spacing: 2) {
            Text(text)
                .font(HPFont.brand(size: 22))
                .foregroundColor(HPColor.backgroundDark)
            Text("SKIP RATE")
                .font(HPFont.metricLabel)
                .foregroundColor(HPColor.backgroundDark.opacity(0.6))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
        .id("skip-\(skipIndex % skipRates.count)")
        .transition(.opacity)
    }

    /// A compact version of the Explore card's 2×3 metric grid, cycling reels.
    private var exploreMetricCard: some View {
        let hook = reels[reelIndex % reels.count]
        let m = hook.metrics ?? HookMetrics(views: 0, shares: 0, likes: 0, saves: 0, reposts: 0, comments: 0)
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 5), count: 3), spacing: 5) {
            mini("Views", m.views)
            mini("Shares", m.shares)
            mini("Likes", m.likes)
            mini("Saves", m.saves)
            mini("Reposts", m.reposts)
            mini("Comments", m.comments)
        }
        .padding(10)
        .frame(width: 188)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
        .id("reel-\(reelIndex % reels.count)")
        .transition(.opacity)
    }

    private func mini(_ label: String, _ value: Int) -> some View {
        VStack(spacing: 1) {
            Text(formatNumber(value))
                .font(HPFont.brandRegular(size: 12))
                .foregroundColor(HPColor.backgroundDark)
            Text(label)
                .font(HPFont.brandRegular(size: 8))
                .foregroundColor(HPColor.backgroundDark.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 5)
        .background(HPColor.background.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func formatNumber(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n) / 1_000) }
        return "\(n)"
    }

    // `slot` keeps each card's identity local to its position so the crossfade
    // happens in place instead of the views appearing to jump between slots.
    private func hookCard(_ hook: Hook, slot: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(hook.textContent ?? "")
                .font(HPFont.subheading)
                .foregroundColor(HPColor.backgroundDark)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            Text("by \(hook.authorDisplayName)")
                .font(HPFont.metricLabel)
                .foregroundColor(HPColor.backgroundDark.opacity(0.55))
        }
        .padding(14)
        .frame(width: 168, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
        .id("\(slot)-\(hook.id)")
        .transition(.opacity)
    }

    /// Icon + label box (checkmark = STAY, x = SWIPE).
    private func iconBox(_ icon: String, _ label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2.bold())
                .foregroundColor(HPColor.backgroundDark)
            Text(label)
                .font(HPFont.metricLabel)
                .foregroundColor(HPColor.backgroundDark.opacity(0.6))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
    }

    /// SAVED VARIANT — used by the "count boxes" homepage version. Kept so the
    /// TESTED / TO EXPLORE stat boxes can be restored (see FloatingShowcase).
    private func metricBox(_ label: String, _ value: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(HPFont.brand(size: 22))
                .foregroundColor(HPColor.backgroundDark)
            Text(label)
                .font(HPFont.metricLabel)
                .foregroundColor(HPColor.backgroundDark.opacity(0.6))
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.10), radius: 6, x: 0, y: 3)
    }
}

/// Wraps content in a slow, looping vertical bob for a "floating" feel.
private struct FloatingBob<Content: View>: View {
    let delay: Double
    let content: Content
    @State private var up = false

    init(delay: Double, @ViewBuilder content: () -> Content) {
        self.delay = delay
        self.content = content()
    }

    var body: some View {
        content
            .offset(y: up ? -7 : 7)
            .onAppear {
                withAnimation(.easeInOut(duration: 2.4).repeatForever(autoreverses: true).delay(delay)) {
                    up = true
                }
            }
    }
}

#Preview {
    LandingView()
        .environmentObject(UserSession())
        .environmentObject(HookStore())
        .environmentObject(BookmarkStore())
        .environmentObject(ReactionStore())
}
