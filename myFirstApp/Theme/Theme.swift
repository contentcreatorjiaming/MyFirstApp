//
//  Theme.swift
//  myFirstApp
//
//  Central design system: colors, typography, and shared styling constants.
//  Every view pulls from here — no hardcoded colors or font sizes elsewhere.
//

import SwiftUI

// MARK: - Colors

enum HPColor {
    // Primary brand
    static let forest = Color(red: 0.13, green: 0.55, blue: 0.40)      // #21A667 — rich green
    static let forestDark = Color(red: 0.08, green: 0.40, blue: 0.28)   // deeper for gradients
    static let forestLight = Color(red: 0.85, green: 0.95, blue: 0.90)  // tinted backgrounds

    // Accents
    static let coral = Color(red: 0.95, green: 0.35, blue: 0.40)       // CTA / Create / swipe
    static let sky = Color(red: 0.25, green: 0.52, blue: 0.96)         // Research / links
    static let amber = Color(red: 1.0, green: 0.75, blue: 0.0)         // bookmarks / highlights
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.14)         // dark text / buttons

    // Neutrals
    static let cardBg = Color(.systemBackground)
    static let subtleBg = Color(.secondarySystemBackground)
    static let border = Color(.separator)
    static let textPrimary = Color(.label)
    static let textSecondary = Color(.secondaryLabel)
}

// MARK: - Typography

enum HPFont {
    static func brand(size: CGFloat) -> Font {
        .custom("Snell Roundhand", size: size)
    }
    static let heroTitle = brand(size: 44)
    static let screenTitle = brand(size: 32)
    static let heading = Font.system(size: 20, weight: .bold, design: .rounded)
    static let subheading = Font.system(size: 16, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 15, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .medium, design: .rounded)
    static let metric = Font.system(size: 22, weight: .bold, design: .rounded)
    static let metricLabel = Font.system(size: 11, weight: .medium, design: .rounded)
    static let badge = Font.system(size: 10, weight: .heavy, design: .rounded)
}

// MARK: - Shared button style (replaces HookButtonStyle)

struct HPButtonStyle: ButtonStyle {
    let color: Color
    var fullWidth: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(.white)
            .padding(.horizontal, fullWidth ? 0 : 24)
            .padding(.vertical, 14)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Gradient background used on branded screens

struct HPGradientBackground: View {
    var body: some View {
        LinearGradient(
            colors: [HPColor.forest, HPColor.forestDark],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
