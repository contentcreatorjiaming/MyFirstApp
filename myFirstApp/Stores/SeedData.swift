//
//  SeedData.swift
//  myFirstApp
//
//  Pre-loads 20 real Instagram hooks with real performance metrics
//  so the app has content from first launch. Only seeds once.
//

import Foundation

enum SeedData {
    static let seededKey = "hasSeededHooks_v1"

    static func seedIfNeeded(store: HookStore) {
        guard !UserDefaults.standard.bool(forKey: seededKey) else { return }
        for hook in hooks {
            store.add(hook)
        }
        UserDefaults.standard.set(true, forKey: seededKey)
    }

    private static let hooks: [Hook] = [
        hook("https://www.instagram.com/p/DJCwLz1NPAH/", v: 524709, s: 3791, l: 36927, sv: 3344, c: 16),
        hook("https://www.instagram.com/p/DZ3EcN3Mu8h/", v: 223242, s: 2134, l: 10382, sv: 347, c: 14),
        hook("https://www.instagram.com/p/DWXUU6CjlMR/", v: 235838, s: 2340, l: 16805, sv: 3406, c: 173),
        hook("https://www.instagram.com/p/DZheyxGsZad/", v: 327284, s: 2630, l: 19400, sv: 4586, c: 143),
        hook("https://www.instagram.com/p/DWRg8sJj2Lt/", v: 339577, s: 4925, l: 33768, sv: 7066, c: 87),
        hook("https://www.instagram.com/reel/DZjQy7ZRRNd/", v: 15318, s: 75, l: 1028, sv: 85, c: 7),
        hook("https://www.instagram.com/reel/DZhB829OqDy/", v: 787986, s: 7154, l: 63804, sv: 5283, c: 94),
        hook("https://www.instagram.com/reel/DZjF7xuxYCG/", v: 17676, s: 167, l: 488, sv: 51, c: 6),
        hook("https://www.instagram.com/reel/DZjHIjVxR7p/", v: 1238062, s: 37400, l: 47298, sv: 3343, c: 135),
        hook("https://www.instagram.com/reel/DZhCX8JOhMh/", v: 82436, s: 793, l: 6054, sv: 938, c: 42),
        hook("https://www.instagram.com/reel/DZkoGd8R5Up/", v: 1987423, s: 10700, l: 122289, sv: 5671, c: 313),
        hook("https://www.instagram.com/reel/DaJOqs1ho8t/", v: 1059654, s: 217, l: 5299, sv: 345, c: 133),
        hook("https://www.instagram.com/reel/DTGfvJqCTTK/", v: 19083465, s: 57800, l: 580024, sv: 50500, c: 502),
        hook("https://www.instagram.com/reel/DZ8LlFXvBTl/", v: 2608160, s: 29400, l: 124977, sv: 14600, c: 531),
        hook("https://www.instagram.com/reel/DYFgGM8R2Rt/", v: 2737967, s: 86600, l: 217102, sv: 42300, c: 2332),
        hook("https://www.instagram.com/p/DaBC5Ett8dg/", v: 19788, s: 224, l: 298, sv: 37, c: 112),
        hook("https://www.instagram.com/p/DTs7__TkbBJ/", v: 6938340, s: 247000, l: 302037, sv: 25100, c: 610),
        hook("https://www.instagram.com/p/DYhYBz8Rbsd/", v: 892919, s: 8094, l: 82620, sv: 4780, c: 121),
        hook("https://www.instagram.com/p/DYHyZnQTbll/", v: 737816, s: 22200, l: 65502, sv: 3341, c: 131),
        hook("https://www.instagram.com/p/DZZ5jmSv1HN/", v: 7937281, s: 295000, l: 408732, sv: 30700, c: 2199),
    ]

    private static func hook(_ url: String, v: Int, s: Int, l: Int, sv: Int, c: Int) -> Hook {
        Hook(
            id: UUID(),
            source: .existing,
            kind: .link,
            linkURL: url,
            textContent: nil,
            imageFileName: nil,
            videoFileName: nil,
            metrics: HookMetrics(views: v, likes: l, shares: s, comments: c, saves: sv),
            createdAt: Date(),
            authorDisplayName: "hook playground"
        )
    }
}
