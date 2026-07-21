# Hook Playground 🛝

> Test your hooks with other creators, not the algorithm — so it doesn't cost you the audience you're still building.

## The problem

No matter the platform, the only way to know whether a hook works is to risk losing the audience you're trying to grow. Instagram emphasizes that the first three seconds of a reel decide whether it gets pushed out to more people; if a viewer scrolls away, that reach is gone. Established creators can lean on years of performance data or a creative team to get hooks right before they go live. Emerging creators build through trial and error. Hook Playground lets creators test hooks without testing them on the audience.

## Where my app comes in and how it works

Hook Playground is a community-oriented testing space for emerging creators still experimenting with their brand and audience.

Upon signing up, creators choose the topics they're interested in, and they can always add or change topics later. Main features include:

- **Test your own** — submit a hook under one or more topics, and watch reactions and feedback come in from creators interested in that same topic.
- **Swipe or stay** — Stay ("I'd keep watching") or Swipe ("I'd scroll past") on hooks from your chosen topics only — each hook appears once, even if it spans multiple topics — with optional written feedback and nested reply threads on every reaction.
- **Saved library** — see everything you've swiped or stayed on, plus your own test hooks and saved reels from Explore.
- **Explore** — browse real Instagram reels for inspiration. Filter by topic or by the metric you want to improve (views, likes, saves, shares, reposts, comments). AI generates a summary of each hook's context and what made it work, which you can edit Wikipedia-style if it's off. You can also add reels to this page.

## Architecture

SwiftUI, organized by responsibility:

- **`Models/`** — value types (`Hook`, `Reaction` with a `ReactionType` of `.stay` / `.swipe`)
- **`Stores/`** — `ObservableObject` state: `HookStore`, `ReactionStore`, `BookmarkStore`, `UserSession`, plus `SeedData` (versioned seeding) and `AIInsightEngine` (rule-based insight generation from a hook's engagement metrics)
- **`Views/`** — one view per screen, including a hand-built `PlaygroundAnimation` — SwiftUI `Path` + stroke-trim line drawings of a slide, swings, monkey bars, and seesaw, with no image assets
- **`Theme/`** — design tokens (`HPColor`, `HPFont`) and runtime registration of the Fredoka variable font via `CTFontManagerRegisterFontsForURL`

**Key algorithm:** `ReactionStore.latestReactions(perHookFrom:by:)` deduplicates a user's reactions so only their most recent verdict per hook counts — a pure, unit-tested function that powers the Stayed/Swiped tabs.

**Tested:** 7 unit tests covering reaction deduplication, bookmarking, insight generation, and hook persistence, using Swift Testing.

**Data & privacy:** everything is stored locally on device (JSON in the app's documents directory + `UserDefaults`). No accounts leave the phone, no tracking, no third-party services.

## Design system

Pastel-green gradient background (`#8ED1AB`), alternating white and dark-green text (`#218C66`), pink (`#F7A1C4`) and blue (`#009FFD`) buttons and accents, Fredoka type, custom icons, and micro-interactions throughout (e.g. heart swell on feedback, "Sent!" pill on swipe, 🎉 completion screen). Accessibility labels on icon-only and reaction controls support VoiceOver. Explore's metrics are shown as numbers, not visuals — a deliberate choice to keep creators engaged with the data itself rather than scrolling passively.

## Build & run

1. Open `myFirstApp.xcodeproj` in Xcode.
2. Run on the iPhone 17 simulator (or any iOS 17+ device).
3. Demo account (`jiaming` / `123`) comes pre-loaded with existing hooks and reactions, so you can explore right away — or sign up with any new username for a fresh account.

Run tests:

```sh
xcodebuild test -scheme myFirstApp -destination 'platform=iOS Simulator,name=iPhone 17'
```

(Swift Testing framework.)

## How it was built

I own the product: the concept, every feature decision, the visual design direction, the real reel content, and I review every build. I wrote the code myself following KWK's curriculum, and brought in Claude when I hit something outside that curriculum — Claude Code ran builds and tests on my Mac, managed a feature-branch Git workflow, and generated the seed data (saving time versus writing it by hand), directed by my wireframes and annotated screenshot specs. The reel insight summaries are pre-generated from real captions I provided, not live AI calls.

## What's next

- Automatically pull publicly available performance data into Explore, instead of requiring manual entry.
- Expand the hook library beyond Instagram reels to other platforms (e.g. TikTok, LinkedIn) and other hook formats (text-only posts, not just video).
- Live AI hook analysis alongside human feedback, layered on top of the current rule-based insights.
