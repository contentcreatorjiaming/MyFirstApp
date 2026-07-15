//
//  AIInsightEngine.swift
//  myFirstApp
//
//  Generates AI-powered insights about hooks based on their engagement
//  metrics. Analyzes ratios, identifies patterns, and produces human-
//  readable summaries of what makes a hook perform well or poorly.
//

import Foundation

enum AIInsightEngine {

    /// Generates a 1-3 sentence insight about a hook's performance.
    static func generateInsight(for hook: Hook) -> String {
        guard let m = hook.metrics else {
            return "This hook hasn't been posted yet — submit it for community feedback to see how it lands."
        }

        let engagementRate = Double(m.likes + m.comments + m.shares + m.saves) / max(Double(m.views), 1) * 100
        let shareRate = Double(m.shares) / max(Double(m.views), 1) * 100
        let saveRate = Double(m.saves) / max(Double(m.views), 1) * 100
        let commentRate = Double(m.comments) / max(Double(m.views), 1) * 100

        var insights: [String] = []

        // View tier
        if m.views >= 10_000_000 {
            insights.append("This hook went mega-viral with \(formatNumber(m.views)) views — it clearly hit a universal nerve.")
        } else if m.views >= 1_000_000 {
            insights.append("Strong viral performance at \(formatNumber(m.views)) views — this hook resonated well beyond the creator's existing audience.")
        } else if m.views >= 100_000 {
            insights.append("Solid reach at \(formatNumber(m.views)) views — this hook caught algorithmic momentum.")
        } else {
            insights.append("Modest reach at \(formatNumber(m.views)) views — the hook may need a stronger opening or broader appeal.")
        }

        // Engagement pattern
        if shareRate > 2.0 {
            insights.append("The share rate is exceptional (\(String(format: "%.1f", shareRate))%) — people felt compelled to pass this along, which is the #1 signal Instagram's algorithm rewards.")
        } else if saveRate > 1.5 {
            insights.append("High save rate (\(String(format: "%.1f", saveRate))%) suggests this delivered real value people wanted to reference later.")
        } else if engagementRate > 8 {
            insights.append("Engagement rate of \(String(format: "%.1f", engagementRate))% is well above average — this hook created a strong emotional response.")
        } else if commentRate > 0.5 {
            insights.append("Above-average comment rate suggests this hook sparked conversation — likely used a polarizing or question-based format.")
        }

        // Strategy hint
        if shareRate > 1.5 && m.views > 500_000 {
            insights.append("Key takeaway: hooks that drive shares tend to use relatable situations, unexpected contrasts, or 'tag someone who' energy.")
        } else if saveRate > 1.0 {
            insights.append("Key takeaway: high saves indicate educational or actionable content — the hook likely promised specific, useful information.")
        } else if engagementRate < 3 && m.views > 100_000 {
            insights.append("Despite high views, engagement is low — the hook grabbed attention but the content may not have delivered on the promise.")
        }

        return insights.joined(separator: " ")
    }

    private static func formatNumber(_ n: Int) -> String {
        if n >= 1_000_000 { return String(format: "%.1fM", Double(n) / 1_000_000) }
        if n >= 1_000 { return String(format: "%.1fK", Double(n) / 1_000) }
        return "\(n)"
    }
}
