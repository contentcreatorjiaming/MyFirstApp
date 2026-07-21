//
//  IGStyleIcon.swift
//  myFirstApp
//
//  Custom Instagram-lookalike icon: green rounded square with
//  camera lens circle and flash dot. Not trademarked.
//

import SwiftUI

struct IGStyleIcon: View {
    var size: CGFloat = 30
    var color: Color = HPColor.backgroundDark

    var body: some View {
        ZStack {
            // Rounded square body
            RoundedRectangle(cornerRadius: size * 0.28)
                .stroke(color, lineWidth: size * 0.08)
                .frame(width: size, height: size)

            // Lens circle
            Circle()
                .stroke(color, lineWidth: size * 0.07)
                .frame(width: size * 0.42, height: size * 0.42)

            // Flash dot (top-right)
            Circle()
                .fill(color)
                .frame(width: size * 0.1, height: size * 0.1)
                .offset(x: size * 0.24, y: -size * 0.24)
        }
        .frame(width: size, height: size)
    }
}

#Preview {
    HStack(spacing: 20) {
        IGStyleIcon(size: 24)
        IGStyleIcon(size: 40)
        IGStyleIcon(size: 60, color: .white)
    }
    .padding()
    .background(HPColor.background)
}
