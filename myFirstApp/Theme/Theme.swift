//
//  Theme.swift
//  myFirstApp
//
//  Central design system: colors, typography, and shared styling constants.
//

import SwiftUI

// MARK: - Colors

enum HPColor {
    // Primary brand — pastel green used as the global background
    static let background = Color(red: 0.56, green: 0.82, blue: 0.67)      // pastel green
    static let backgroundDark = Color(red: 0.13, green: 0.55, blue: 0.40)  // deeper green for text on white

    // Action button pair — alternate positions per screen
    static let pastelBlue = Color(red: 0.0, green: 0.624, blue: 0.992)      // #009FFD
    static let pastelPink = Color(red: 0.969, green: 0.631, blue: 0.769)     // #F7A1C4

    // Secondary buttons
    static let secondaryBg = Color.white
    static let secondaryText = Color(red: 0.56, green: 0.82, blue: 0.67)   // matches background green

    // Accents
    static let amber = Color(red: 1.0, green: 0.75, blue: 0.0)
    static let ink = Color(red: 0.12, green: 0.12, blue: 0.14)

    // Neutrals
    static let cardBg = Color.white.opacity(0.92)
    static let subtleBg = Color.white.opacity(0.85)
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.8)
    static let textDark = Color(red: 0.12, green: 0.12, blue: 0.14)
}

// MARK: - Typography

enum HPFont {
    static func brand(size: CGFloat) -> Font {
        .custom("Fredoka", size: size).bold()
    }
    static func brandRegular(size: CGFloat) -> Font {
        .custom("Fredoka", size: size)
    }
    // Titles — bold Fredoka
    static let heroTitle = brand(size: 52)
    static let heroTitleSmall = brand(size: 28)
    static let screenTitle = brand(size: 36)

    // Body/UI text — regular Fredoka
    static let heading = brandRegular(size: 20)
    static let subheading = brandRegular(size: 16)
    static let menuItem = brandRegular(size: 18)
    static let body = brandRegular(size: 15)
    static let caption = brandRegular(size: 12)
    static let metric = brandRegular(size: 22)
    static let metricLabel = brandRegular(size: 11)
    static let badge = brandRegular(size: 10)
}

// MARK: - Primary button (pastel blue or pink)

struct HPButtonStyle: ButtonStyle {
    let color: Color
    var fullWidth: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HPFont.subheading)
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

// MARK: - Secondary button (white bg, green text)

struct HPSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(HPFont.subheading)
            .foregroundColor(HPColor.backgroundDark)
            .padding(.horizontal, 24)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Pastel green background (replaces gradient)

struct HPGradientBackground: View {
    var body: some View {
        HPColor.background
            .ignoresSafeArea()
    }
}
