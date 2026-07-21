//
//  SeedData.swift
//  myFirstApp
//
//  Pre-loads 20 real Instagram hooks with real performance metrics.
//  Clears old seed data and re-seeds with v3 format.
//

import Foundation

enum SeedData {
    static let seededKey = "hasSeededHooks_v11"

    /// Authors of the built-in community test hooks — used to clear old copies
    /// before reseeding so version bumps never leave duplicates behind.
    /// Includes retired authors too, so old seeds still get swept on upgrade.
    static let communityTestAuthors: Set<String> = [
        // retired (kept for cleanup of earlier seeds)
        "scrollstopper", "contentjay", "viral.vee", "everydaymuse", "quietmornings",
        // current 18 (3 per topic)
        "dailygrind", "motivation.mia", "risecreator",           // Motivation
        "memelord.ml", "chronicallyonline", "unhinged.edits",     // Humor
        "hookmaster", "careerclimb", "worklifewin",               // Career
        "curious.carl", "buildinpublic", "techunlocked",          // Tech
        "softhearted", "datedecoded", "lovenotesig",              // Relationships
        "softlifesel", "slowliving.co", "cozycornerco",           // Lifestyle
        "maya.hooks"
    ]

    static func seedIfNeeded(store: HookStore) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        // Clear old seeded hooks (reels + community test hooks) so reseeding
        // never duplicates them. User-submitted test hooks are left alone.
        store.clearExistingSeeded()
        store.removeTestHooks(byAuthors: communityTestAuthors)
        for hook in hooks {
            store.add(hook)
        }
        UserDefaults.standard.set(true, forKey: seededKey)

        // Community test hooks shown in Swipe or Stay: 18 total, exactly 3 per
        // topic (one topic each), so every interest has a full, even deck.
        let testHooks = [
            // Motivation
            testHook("Stop waiting to feel ready. Post the thing.", by: "dailygrind", topics: ["Motivation"]),
            testHook("You're one video away from everything changing.", by: "motivation.mia", topics: ["Motivation"]),
            testHook("The algorithm rewards the brave, not the perfect.", by: "risecreator", topics: ["Motivation"]),
            // Humor
            testHook("My toxic trait is thinking I'll film this in one take.", by: "memelord.ml", topics: ["Humor"]),
            testHook("POV: you opened the app to post and it's 3 hours later.", by: "chronicallyonline", topics: ["Humor"]),
            testHook("I don't have a niche, I have a whole personality.", by: "unhinged.edits", topics: ["Humor"]),
            // Career
            testHook("I tested 50 hooks and only 3 worked. Here's why.", by: "hookmaster", topics: ["Career"]),
            testHook("The one resume tweak that tripled my callbacks.", by: "careerclimb", topics: ["Career"]),
            testHook("What nobody tells you about your first 90 days at a job.", by: "worklifewin", topics: ["Career"]),
            // Tech
            testHook("Can the speed of sound ever be faster than light?", by: "curious.carl", topics: ["Tech"]),
            testHook("The AI prompt that replaced half my workflow.", by: "buildinpublic", topics: ["Tech"]),
            testHook("Your phone is leaking your data — fix these 3 settings.", by: "techunlocked", topics: ["Tech"]),
            // Relationships
            testHook("The green flag everyone ignores when dating.", by: "softhearted", topics: ["Relationships"]),
            testHook("How to end a text convo without sounding dry.", by: "datedecoded", topics: ["Relationships"]),
            testHook("We don't do the silent treatment in a healthy relationship.", by: "lovenotesig", topics: ["Relationships"]),
            // Lifestyle
            testHook("I romanticized my life for 30 days. Here's what changed.", by: "softlifesel", topics: ["Lifestyle"]),
            testHook("POV: your morning routine is why your content flops.", by: "slowliving.co", topics: ["Lifestyle"]),
            testHook("The 15-minute reset that makes my whole apartment feel new.", by: "cozycornerco", topics: ["Lifestyle"]),
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
        let feedbackKey = "hasSeededTestFeedback_v4"
        guard !UserDefaults.standard.bool(forKey: feedbackKey) else { return }

        // Commenters are distinct from the hook authors, so no one comments on
        // their own hook.
        let commenters = [
            "alex_creates", "reelqueen", "nova.films", "the.editor", "jordanmakes",
            "sunnyclips", "pixel.pam", "framebyframe", "duetking", "sarah.creates"
        ]

        // 36 unique comments — two per hook, assigned in order, never reused.
        let comments: [(ReactionType, String)] = [
            (.stay, "The first line did all the work — I stopped instantly."),
            (.swipe, "Feels like an opener I've scrolled past a hundred times."),
            (.stay, "Real curiosity gap here, I need the payoff now."),
            (.swipe, "Give me a reason to care inside the first two words."),
            (.stay, "The specificity is what sells it — very scroll-stopping."),
            (.swipe, "Too broad. Narrow it to one person and it lands."),
            (.stay, "I'd send this to a friend before I even finished watching."),
            (.swipe, "The idea's there but the wording is doing it no favors."),
            (.stay, "Bold claim, and I actually believe you can back it up."),
            (.swipe, "Reads like a caption, not a hook — front-load the tension."),
            (.stay, "That's a pattern interrupt. My thumb genuinely paused."),
            (.swipe, "I get the vibe but there are no stakes for me to stay."),
            (.stay, "Short, punchy, and a little unhinged — love it."),
            (.swipe, "Would hit harder as a question than a statement."),
            (.stay, "The contrast makes me want the before and after."),
            (.swipe, "Nothing here tells me what I'm about to miss."),
            (.stay, "The kind of line I'd screenshot to steal the structure."),
            (.swipe, "Slightly clickbaity — might dent trust if it over-promises."),
            (.stay, "You had me at the setup. Perfect tension for a reel."),
            (.swipe, "The hook and the topic feel a little disconnected."),
            (.stay, "Instantly relatable. This is going to do numbers."),
            (.swipe, "Try cutting the first three words — it drags to start."),
            (.stay, "The confidence in this is exactly why it works."),
            (.swipe, "Clever, but not urgent — I'd keep scrolling."),
            (.stay, "That reframe is sneaky good. Didn't see it coming."),
            (.swipe, "Feels safe. Push it one notch more controversial."),
            (.stay, "Great emotional pull without being try-hard about it."),
            (.swipe, "The payoff better be huge, because the promise is big."),
            (.stay, "This whispers instead of shouts and it totally works."),
            (.swipe, "Needs a number or a name to feel concrete."),
            (.stay, "I felt seen in one sentence. That's the whole game."),
            (.swipe, "Good bones, but the last word kills the momentum."),
            (.stay, "Immediately makes me want to defend my own take."),
            (.swipe, "It's a statement I agree with, so no reason to stay."),
            (.stay, "The rhythm of this line is doing a lot of quiet work."),
            (.swipe, "Strong for the right audience, invisible to everyone else."),
        ]

        // 10 unique replies, threaded under the first comment of every other hook.
        let replies = [
            "Totally agree — this is exactly what stopped me too.",
            "Respectfully disagree, the hook did its job for me.",
            "Was literally about to comment the same thing.",
            "Fair point, I hadn't thought about it that way.",
            "Hard disagree — I think the vagueness is the appeal.",
            "This is the note that'll actually improve the next one.",
            "Ok but the payoff genuinely delivered for me.",
            "Saving this thread, great breakdown of why it works.",
            "Counterpoint: the audience for this isn't you or me.",
            "Yes!! Finally someone said it.",
        ]

        var commentIdx = 0
        var replyIdx = 0
        var nameIdx = 0

        for (hookIndex, hook) in testHooks.enumerated() {
            for i in 0..<2 {
                guard commentIdx < comments.count else { break }
                let (type, text) = comments[commentIdx]; commentIdx += 1
                let author = commenters[nameIdx % commenters.count]; nameIdx += 1
                reactionStore.add(Reaction(
                    id: UUID(), hookID: hook.id, type: type,
                    feedback: text, authorDisplayName: author,
                    createdAt: Date().addingTimeInterval(-Double.random(in: 3600...86400 * 3))
                ))

                // One unique reply under the first comment of every other hook.
                if i == 0, hookIndex % 2 == 0, replyIdx < replies.count {
                    let replier = commenters[nameIdx % commenters.count]; nameIdx += 1
                    reactionStore.add(Reaction(
                        id: UUID(), hookID: hook.id, type: type,
                        feedback: "↳ @\(author): \(replies[replyIdx])",
                        authorDisplayName: replier,
                        createdAt: Date().addingTimeInterval(-Double.random(in: 600...3600))
                    ))
                    replyIdx += 1
                }
            }
        }
        UserDefaults.standard.set(true, forKey: feedbackKey)
    }

    private static func testHook(_ text: String, by author: String, topics: [String]) -> Hook {
        Hook(
            id: UUID(), source: .testNew, kind: .text,
            linkURL: nil, textContent: text, imageFileName: nil, videoFileName: nil,
            metrics: nil, createdAt: d(7, 14, 2026), datePosted: nil,
            authorDisplayName: author,
            aiSummary: nil, skipRate: nil, claimedBy: nil, topics: topics
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
             ai: "Emotional moving-out reel — creator closes the door on their old home for the last time, reflecting on memories while stepping into a new chapter. Caption: 'Onto a new home and an even better version of me.'", t: ["Lifestyle"]),
        hook("https://www.instagram.com/p/DZ3EcN3Mu8h/", v:223242,sh:2134,l:10382,sv:347,r:871,c:14, posted:d(6,21,2026), i:1,
             ai: "Relatable growing-up moment — creator hits the realization that they're already an adult. Short, punchy caption ('damn, I'm already an adult') drives high reposts from people feeling the same way.", t: ["Humor", "Lifestyle"]),
        hook("https://www.instagram.com/p/DWXUU6CjlMR/", v:235838,sh:2340,l:16805,sv:3406,r:1386,c:173, posted:d(3,26,2026), i:2,
             ai: "Female founder motivation reel — 'I can, I will, I must!' message targeting women entrepreneurs. High save rate shows the audience bookmarked it for days they need a push.", t: ["Motivation"]),
        hook("https://www.instagram.com/p/DZheyxGsZad/", v:327284,sh:2630,l:19400,sv:4586,r:1306,c:143, posted:d(6,16,2026), i:3,
             ai: "Creator vulnerability post about feeling cringe putting yourself out there — until someone says 'you inspired me.' High saves suggest this resonated with aspiring creators who needed permission to keep going.", t: ["Motivation"]),
        hook("https://www.instagram.com/p/DWRg8sJj2Lt/", v:339577,sh:4925,l:33768,sv:7066,r:1378,c:87, posted:d(3,24,2026), i:4,
             ai: "Study motivation / grind culture reel — 'trust the process, the results are coming.' Heavily hashtagged for discoverability (#hardworkpaysoff #grindmode). The 7K saves show students bookmarking it for exam season motivation.", t: ["Motivation"]),
        hook("https://www.instagram.com/reel/DZjQy7ZRRNd/", v:15318,sh:75,l:1028,sv:85,r:0,c:7, posted:d(6,27,2026), i:5,
             ai: "Young professional flex — 'you know you're doing something right when you're the youngest in the room.' Niche audience (young entrepreneurs/career starters) but strong engagement rate for its size.", t: ["Career"]),
        hook("https://www.instagram.com/reel/DZhB829OqDy/", v:787986,sh:7154,l:63804,sv:5283,r:0,c:94, posted:d(6,27,2026), i:6,
             ai: "Mindset shift reel — 'having access to people smarter than you is a blessing, not a threat.' Reframes imposter syndrome as an advantage. The 63K likes show this hit a nerve with ambitious audiences.", t: ["Motivation", "Career"]),
        hook("https://www.instagram.com/reel/DZjF7xuxYCG/", v:17676,sh:167,l:488,sv:51,r:0,c:6, posted:d(6,27,2026), i:7,
             ai: "Job interview confidence reel — 'never going into a job interview nervous again because it's literally a free invitation to talk about how amazing I am.' Smaller reach but the boldness of the hook is its strength.", t: ["Career", "Humor"]),
        hook("https://www.instagram.com/reel/DZjHIjVxR7p/", v:1238062,sh:37400,l:47298,sv:3343,r:0,c:135, posted:d(6,27,2026), i:8,
             ai: "Satirical text hook reel — 'choose a major you love and you'll never have to work a day in your life because that field isn't hiring.' Punchline lands perfectly. Caption just says 'start a startup.' The 37K shares confirm this is peak relatable humor for college grads.", t: ["Humor", "Career"]),
        hook("https://www.instagram.com/reel/DZhCX8JOhMh/", v:82436,sh:793,l:6054,sv:938,r:0,c:42, posted:d(6,20,2026), i:9,
             ai: "Tech ambition reel — text hook lists every tech skill (programming, ML, UX, cybersecurity, cloud, data science) the creator wants to master. Caption: 'keep learning.' Resonates with tech learners overwhelmed by how much there is to know.", t: ["Tech", "Motivation"]),
        hook("https://www.instagram.com/reel/DZkoGd8R5Up/", v:1987423,sh:10700,l:122289,sv:5671,r:4596,c:313, posted:d(6,14,2026), i:10,
             ai: "Comedy POV skit — 'when your mom is only worried about the boys.' Creator plays it straight while the punchline reveals a coming-out moment. Caption: 'Technically I didn't lie to her 🤭🌈 #pridemonth.' Nearly 2M views from humor + pride content crossover.", t: ["Humor"]),
        hook("https://www.instagram.com/reel/DaJOqs1ho8t/", v:1059654,sh:217,l:5299,sv:345,r:131,c:133, posted:d(6,26,2026), i:11,
             ai: "Chicago gatekeeping humor — 'reminder: Lake Michigan is dangerous, don't swim in it.' Classic reverse-psychology locals use to keep tourists away from their favorite spots. Caption: 'Stay far away this summer.' High views but very low shares — locals don't want to share the secret.", t: ["Humor", "Lifestyle"]),
        hook("https://www.instagram.com/reel/DTGfvJqCTTK/", v:19083465,sh:57800,l:580024,sv:50500,r:5013,c:502, posted:d(1,4,2026), i:12,
             ai: "Heartfelt friendship reel — 'what do you mean it's inconvenient to have friends sleep on the couch? What a privilege it is to have friends who want to travel to see us.' Creator and partner made a vow to always welcome guests. 19M views and 580K likes — universally resonant message about valuing friendships.", t: ["Relationships"]),
        hook("https://www.instagram.com/reel/DZ8LlFXvBTl/", v:2608160,sh:29400,l:124977,sv:14600,r:4232,c:531, posted:d(6,24,2026), i:13,
             ai: "Relatable tech/AI humor — 'the move I pull up when AI can't help me.' Creator shows their fallback when ChatGPT fails them. 2.6M views and 14K saves — struck a chord with the AI-dependent generation.", t: ["Tech", "Humor"]),
        hook("https://www.instagram.com/reel/DYFgGM8R2Rt/", v:2737967,sh:86600,l:217102,sv:42300,r:13700,c:2332, posted:d(5,8,2026), i:14,
             ai: "Healthy relationship advice — text hook: 'things we don't do in a healthy relationship.' Lists 5 toxic habits to avoid: joking about breakups, tit-for-tat, no appreciation, name-calling, shutting down. The 86K shares and 42K saves show couples forwarding this to each other as a relationship standard.", t: ["Relationships"]),
        hook("https://www.instagram.com/p/DaBC5Ett8dg/", v:19788,sh:224,l:298,sv:37,r:7,c:112, posted:d(7,2,2026), i:15,
             ai: "Dev humor poll — 'Be honest, and you can include others not on this list but if you give me .zip just know that you're wrong.' Coding community inside joke. Low views but highest comment-to-view ratio in the collection — pure engagement bait for developers.", t: ["Tech", "Humor"]),
        hook("https://www.instagram.com/p/DTs7__TkbBJ/", v:6938340,sh:247000,l:302037,sv:25100,r:7855,c:610, posted:d(1,20,2026), i:16,
             ai: "Productivity/motivation reel — 'work smarter not harder this year.' Simple hook, massive execution. 247K shares and 7M views — the kind of universal message that gets forwarded to group chats and stories constantly.", t: ["Motivation", "Career"]),
        hook("https://www.instagram.com/p/DYhYBz8Rbsd/", v:892919,sh:8094,l:82620,sv:4780,r:10200,c:121, posted:d(5,19,2026), i:17,
             ai: "Reflective/nostalgic reel — 'We once chased big dreams, and now we cherish quiet moments, warm coffee, and peace of mind.' Aesthetic visuals with a calm energy. 82K likes from an audience that's shifted from hustle culture to peace-seeking.", t: ["Lifestyle"]),
        hook("https://www.instagram.com/p/DYHyZnQTbll/", v:737816,sh:22200,l:65502,sv:3341,r:2157,c:131, posted:d(5,10,2026), i:18,
             ai: "Job search humor — 'I am very open please hire me.' Raw, unfiltered desperation packaged as comedy. 22K shares confirm unemployed/job-seeking audiences forwarded this to friends in the same boat.", t: ["Career", "Humor"]),
        hook("https://www.instagram.com/p/DZZ5jmSv1HN/", v:7937281,sh:295000,l:408732,sv:30700,r:25000,c:2199, posted:d(6,10,2026), i:19,
             ai: "Expat life humor — text hook: 'when you want to quit everything and move abroad but you've already quit everything and moved abroad.' Caption: 'What to do now!!' 295K shares and 8M views — the expat community's most relatable moment, plus anyone who's fantasized about leaving it all behind.", t: ["Lifestyle", "Humor"]),
    ]

    private static func hook(_ url: String, v: Int, sh: Int, l: Int, sv: Int, r: Int, c: Int, posted: Date, i: Int, ai: String, t: [String]) -> Hook {
        Hook(
            id: UUID(), source: .existing, kind: .link,
            linkURL: url, textContent: nil, imageFileName: nil, videoFileName: nil,
            metrics: HookMetrics(views: v, shares: sh, likes: l, saves: sv, reposts: r, comments: c),
            createdAt: added, datePosted: posted,
            authorDisplayName: "jiaming",
            aiSummary: ai, skipRate: nil, claimedBy: nil, topics: t
        )
    }
}
