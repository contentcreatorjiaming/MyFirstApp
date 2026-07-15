//
//  SeedData.swift
//  myFirstApp
//
//  Pre-loads 20 real Instagram hooks with real performance metrics.
//  Clears old seed data and re-seeds with v3 format.
//

import Foundation

enum SeedData {
    static let seededKey = "hasSeededHooks_v5"

    static func seedIfNeeded(store: HookStore) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        // Clear any old seeded hooks to prevent duplicates
        store.clearExistingSeeded()
        for hook in hooks {
            store.add(hook)
        }
        UserDefaults.standard.set(true, forKey: seededKey)

        // Also seed some mock test hooks
        let testHooks = [
            testHook("What if you could predict which hooks go viral before posting?", by: "maya.hooks"),
            testHook("3 seconds. That's all you get to stop the scroll.", by: "scrollstopper"),
            testHook("I tested 50 hooks and only 3 worked. Here's why.", by: "hookmaster"),
            testHook("The hook isn't the first line. It's the first feeling.", by: "contentjay"),
            testHook("Nobody talks about what happens after the hook lands.", by: "viral.vee"),
        ]
        for hook in testHooks {
            store.add(hook)
        }
    }

    /// Seeds mock community reactions with feedback on test hooks.
    static func seedTestFeedback(store: HookStore, reactionStore: ReactionStore) {
        let testHooks = store.hooks.filter { $0.source == .testNew }
        guard !testHooks.isEmpty else { return }
        // Only seed once
        let feedbackKey = "hasSeededTestFeedback_v2"
        guard !UserDefaults.standard.bool(forKey: feedbackKey) else { return }

        let names = ["alex_creates", "maya.hooks", "contentjay", "reelqueen", "viral.vee", "hookmaster"]
        let feedbacks: [(ReactionType, String)] = [
            (.stay, "This makes me want to see what comes next"),
            (.swipe, "Too vague — give me a reason to care in the first 2 words"),
            (.stay, "Strong curiosity gap, I'd watch the whole thing"),
            (.swipe, "Feels like every other hook I've seen today"),
            (.stay, "The confidence in this hook is what sells it"),
            (.swipe, "Needs a visual to match the energy of the text"),
            (.stay, "Short and punchy — exactly what works"),
            (.swipe, "Would scroll past, but only because I've seen similar"),
            (.stay, "This would stop my scroll for sure"),
            (.swipe, "Try leading with a number or a bold claim"),
        ]

        for hook in testHooks {
            let count = Int.random(in: 2...4)
            for i in 0..<count {
                let fb = feedbacks[Int.random(in: 0..<feedbacks.count)]
                let reaction = Reaction(
                    id: UUID(), hookID: hook.id, type: fb.0,
                    feedback: fb.1,
                    authorDisplayName: names[i % names.count],
                    createdAt: Date().addingTimeInterval(-Double.random(in: 3600...86400 * 3))
                )
                reactionStore.add(reaction)
            }
        }
        UserDefaults.standard.set(true, forKey: feedbackKey)
    }

    private static func testHook(_ text: String, by author: String) -> Hook {
        Hook(
            id: UUID(), source: .testNew, kind: .text,
            linkURL: nil, textContent: text, imageFileName: nil, videoFileName: nil,
            metrics: nil, createdAt: d(7, 14, 2026), datePosted: nil,
            authorDisplayName: author,
            aiSummary: nil, skipRate: nil, claimedBy: nil
        )
    }

    private static func d(_ m: Int, _ day: Int, _ y: Int) -> Date {
        var c = DateComponents(); c.month = m; c.day = day; c.year = y
        return Calendar.current.date(from: c) ?? Date()
    }

    private static let added = d(7, 15, 2026)
    private static let creators = [
        "sarah.creates", "alexhooks", "contentjay", "reelqueen",
        "viral.vee", "hookmaster", "scrollstopper", "maya.hooks",
        "creator.sam", "brandbuilder", "trendwatch", "socialsavvy",
        "reelmaven", "growthguru", "engagepro", "hooklab",
        "viralcraft", "contentace", "reelgenius", "insightful.ig"
    ]

    private static let hooks: [Hook] = [
        hook("https://www.instagram.com/p/DJCwLz1NPAH/", v:524709,sh:3791,l:36927,sv:3344,r:116,c:16, posted:d(4,29,2025), i:0,
             ai: "Creator shares a personal story comparing learning front flips to understanding B2B SaaS — uses physical movement as a metaphor for business pivots. High engagement suggests the unexpected analogy resonated."),
        hook("https://www.instagram.com/p/DZ3EcN3Mu8h/", v:223242,sh:2134,l:10382,sv:347,r:871,c:14, posted:d(6,21,2026), i:1,
             ai: "Quick lifestyle reel showing a day-in-the-life format with text overlay hooks. The creator uses jump cuts and trending audio to maintain pacing throughout."),
        hook("https://www.instagram.com/p/DWXUU6CjlMR/", v:235838,sh:2340,l:16805,sv:3406,r:1386,c:173, posted:d(3,26,2026), i:2,
             ai: "Educational content breaking down a complex topic into digestible steps. Uses on-screen text with a talking-head format. High save rate indicates actionable takeaways."),
        hook("https://www.instagram.com/p/DZheyxGsZad/", v:327284,sh:2630,l:19400,sv:4586,r:1306,c:143, posted:d(6,16,2026), i:3,
             ai: "Transformation-style reel with a before/after reveal. The hook teases the result upfront, creating a curiosity gap that keeps viewers watching for the process."),
        hook("https://www.instagram.com/p/DWRg8sJj2Lt/", v:339577,sh:4925,l:33768,sv:7066,r:1378,c:87, posted:d(3,24,2026), i:4,
             ai: "Storytelling reel using the 'what I learned' framework — personal experience packaged as universal advice. Strong share rate suggests high relatability."),
        hook("https://www.instagram.com/reel/DZjQy7ZRRNd/", v:15318,sh:75,l:1028,sv:85,r:0,c:7, posted:d(6,27,2026), i:5,
             ai: "Niche content targeting a specific audience with insider knowledge. Lower view count but solid engagement rate — the hook speaks directly to people who get it."),
        hook("https://www.instagram.com/reel/DZhB829OqDy/", v:787986,sh:7154,l:63804,sv:5283,r:0,c:94, posted:d(6,27,2026), i:6,
             ai: "Visually striking reel with a POV format — puts the viewer in the creator's shoes. Uses quick transitions and a dramatic reveal that drives the high like count."),
        hook("https://www.instagram.com/reel/DZjF7xuxYCG/", v:17676,sh:167,l:488,sv:51,r:0,c:6, posted:d(6,27,2026), i:7,
             ai: "Short-form tutorial with a single actionable tip. Minimal production — just screen recording with voiceover. The simplicity works for the niche audience."),
        hook("https://www.instagram.com/reel/DZjHIjVxR7p/", v:1238062,sh:37400,l:47298,sv:3343,r:0,c:135, posted:d(6,27,2026), i:8,
             ai: "Controversial take on a trending topic — the hook makes a bold claim that splits the audience. The massive share count shows people wanted others to see this and react."),
        hook("https://www.instagram.com/reel/DZhCX8JOhMh/", v:82436,sh:793,l:6054,sv:938,r:0,c:42, posted:d(6,20,2026), i:9,
             ai: "Behind-the-scenes content showing a creative process. The hook promises a satisfying result, and the pacing builds anticipation through the middle of the reel."),
        hook("https://www.instagram.com/reel/DZkoGd8R5Up/", v:1987423,sh:10700,l:122289,sv:5671,r:4596,c:313, posted:d(6,14,2026), i:10,
             ai: "Highly shareable content using humor and a relatable situation. The hook sets up an expectation that gets subverted — classic comedy structure adapted for short-form."),
        hook("https://www.instagram.com/reel/DaJOqs1ho8t/", v:1059654,sh:217,l:5299,sv:345,r:131,c:133, posted:d(6,26,2026), i:11,
             ai: "Long-form storytelling reel with a gripping personal narrative. High view count but lower shares suggest people watched fully but it felt too personal to share."),
        hook("https://www.instagram.com/reel/DTGfvJqCTTK/", v:19083465,sh:57800,l:580024,sv:50500,r:5013,c:502, posted:d(1,4,2026), i:12,
             ai: "Mega-viral reel with a universally relatable hook. Uses text-on-screen with trending audio and a punchline that lands perfectly. The 19M views confirm mass appeal."),
        hook("https://www.instagram.com/reel/DZ8LlFXvBTl/", v:2608160,sh:29400,l:124977,sv:14600,r:4232,c:531, posted:d(6,24,2026), i:13,
             ai: "High-value educational content with a list format — '5 things you're doing wrong.' The hook calls out a common mistake, and the save count shows people bookmarked it for later."),
        hook("https://www.instagram.com/reel/DYFgGM8R2Rt/", v:2737967,sh:86600,l:217102,sv:42300,r:13700,c:2332, posted:d(5,8,2026), i:14,
             ai: "Emotionally charged content with a vulnerability hook — creator shares something personal that most people relate to but don't talk about. The 86K shares reflect deep resonance."),
        hook("https://www.instagram.com/p/DaBC5Ett8dg/", v:19788,sh:224,l:298,sv:37,r:7,c:112, posted:d(7,2,2026), i:15,
             ai: "Discussion-starter post with a provocative question or hot take. Low views but high comment-to-view ratio — this hook sparks conversation more than passive consumption."),
        hook("https://www.instagram.com/p/DTs7__TkbBJ/", v:6938340,sh:247000,l:302037,sv:25100,r:7855,c:610, posted:d(1,20,2026), i:16,
             ai: "Massively viral carousel or reel using a 'you vs. them' comparison format. The 247K shares make this one of the most forwarded hooks in this collection — pure relatability."),
        hook("https://www.instagram.com/p/DYhYBz8Rbsd/", v:892919,sh:8094,l:82620,sv:4780,r:10200,c:121, posted:d(5,19,2026), i:17,
             ai: "Aesthetic content with a mood-setting hook — the visual quality does the heavy lifting. High like count suggests people appreciated the craft and visual storytelling."),
        hook("https://www.instagram.com/p/DYHyZnQTbll/", v:737816,sh:22200,l:65502,sv:3341,r:2157,c:131, posted:d(5,10,2026), i:18,
             ai: "Motivational content using a contrast hook — shows where the creator was vs. where they are now. The share rate suggests people sent this to friends who needed the message."),
        hook("https://www.instagram.com/p/DZZ5jmSv1HN/", v:7937281,sh:295000,l:408732,sv:30700,r:25000,c:2199, posted:d(6,10,2026), i:19,
             ai: "Second-most viral in the collection — uses a 'wait for it' structure with an unexpected payoff. The 295K shares and 408K likes indicate content that makes people tag their friends."),
    ]

    private static func hook(_ url: String, v: Int, sh: Int, l: Int, sv: Int, r: Int, c: Int, posted: Date, i: Int, ai: String) -> Hook {
        Hook(
            id: UUID(), source: .existing, kind: .link,
            linkURL: url, textContent: nil, imageFileName: nil, videoFileName: nil,
            metrics: HookMetrics(views: v, shares: sh, likes: l, saves: sv, reposts: r, comments: c),
            createdAt: added, datePosted: posted,
            authorDisplayName: "jiaming",
            aiSummary: ai, skipRate: nil, claimedBy: nil
        )
    }
}
