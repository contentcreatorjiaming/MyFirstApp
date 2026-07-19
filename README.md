# Hook Playground 🛝

**Test your hooks with creators like you — before you post.**

Hook Playground is an iOS app where beginner content creators test their video
hooks on a community of fellow creators — collecting swipe reactions and
threaded feedback before they post — so a hook's first real audience isn't the
one that decides whether their video flops.

## The problem

The first three seconds of a video decide everything, but new creators have no
way to know whether a hook works until it's already public. Established
creators follow formats that already work for them or have teams; beginners 
guess, alone.

## What the app does

- **Explore** — browse real Instagram reels and filter by publicly available metrics (views, likes, saves, shares, reposts - whichever metric the user wants to improve). Save  and an insight summary per hook.
- **Create** - 
- **Swipe to react** — Stay ("I'd keep watching") or Swipe ("I'd scroll past")
  on other creators' hooks, with a full-screen completion celebration.
- **Community feedback** — optional written feedback on every reaction, with
  nested reply threads so conversations happen inside the feedback.
- **Test your own** — submit a hook and watch reactions and ratings come in.
- **Saved / Stayed / Swiped tabs** — bookmarks plus a per-user history where
  only your latest reaction per hook counts.

## Architecture

SwiftUI, component-based, organized by responsibility:

- `Models/` — value types (`Hook`, `Reaction` with a `ReactionType` of
  `.stay` / `.swipe`).
- `Stores/` — `ObservableObject` state: `HookStore`, `ReactionStore`,
  `BookmarkStore`, `UserSession`, plus `SeedData` (versioned seeding, currently
  `hasSeededHooks_v6`) and `AIInsightEngine` (generates metric-aware insight
  text for hooks).
- `Views/` — one view per screen/component, including a hand-built
  `PlaygroundAnimation` (SwiftUI `Path` + stroke-trim line drawings of a
  slide, swings, monkey bars, and seesaw — no image assets).
- `Theme/` — design tokens (`HPColor`, `HPFont`) and runtime registration of
  the Fredoka variable font via `CTFontManagerRegisterFontsForURL`.

**Key algorithm:** `ReactionStore.latestReactions(perHookFrom:by:)`
deduplicates a user's reactions so only their most recent verdict per hook
counts — a pure, unit-tested function that powers the Stayed/Swiped tabs.

**Data & privacy:** everything is stored locally on device (JSON in the app's
documents directory + `UserDefaults`). No accounts leave the phone, no
tracking, no third-party services.

## Design system

Pastel-green gradient background, dark-green text, pink `#F7A1C4` and blue
`#009FFD` accents, Fredoka type, a custom Instagram-style app icon, and
micro-interactions throughout (heart swell on feedback, "Sent!" pill on
swipe, 🎉 completion screen). Accessibility labels on icon-only and
reaction controls support VoiceOver.

## Build & run

1. Open `myFirstApp.xcodeproj` in Xcode.
2. Run on the iPhone 17 simulator (or any iOS 17+ device).
3. Demo account (demo only, local to device): username `jiaming`,
   password `123` — or sign up with anything.

Run tests: `xcodebuild test -scheme myFirstApp -destination
'platform=iOS Simulator,name=iPhone 17'` (Swift Testing framework).

## How it was built

I (Jiaming) own the product: the concept, every feature decision, the visual
design direction, the real reel content, and review of every build. I built
it in collaboration with Claude (Anthropic's AI model), which served as my
engineering partner — writing the SwiftUI code, running builds and tests on
my Mac, and managing a feature-branch Git workflow — directed by my
annotated screenshot specs. The reel insight summaries are pre-generated
from real captions I provided, not live AI calls.

## What's next

Live AI hook analysis alongside human feedback, creator matching by niche,
and cross-platform hook testing.
