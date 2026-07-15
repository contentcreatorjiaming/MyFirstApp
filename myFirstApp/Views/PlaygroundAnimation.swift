//
//  PlaygroundAnimation.swift
//  myFirstApp
//
//  Faint animated playground scene: a phone slides down a slide,
//  crosses monkey bars, and bounces on a seesaw. Loops continuously.
//

import SwiftUI

struct PlaygroundAnimation: View {
    @State private var phase: CGFloat = 0

    private let duration: Double = 8.0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Slide
                Path { p in
                    p.move(to: CGPoint(x: w * 0.1, y: h * 0.35))
                    p.addLine(to: CGPoint(x: w * 0.35, y: h * 0.55))
                    // Slide legs
                    p.move(to: CGPoint(x: w * 0.1, y: h * 0.35))
                    p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.55))
                    p.move(to: CGPoint(x: w * 0.22, y: h * 0.35))
                    p.addLine(to: CGPoint(x: w * 0.22, y: h * 0.55))
                    // Ladder
                    p.move(to: CGPoint(x: w * 0.22, y: h * 0.38))
                    p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.38))
                    p.move(to: CGPoint(x: w * 0.22, y: h * 0.42))
                    p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.42))
                    p.move(to: CGPoint(x: w * 0.22, y: h * 0.46))
                    p.addLine(to: CGPoint(x: w * 0.1, y: h * 0.46))
                }
                .stroke(Color.white.opacity(0.12), lineWidth: 2.5)

                // Monkey bars
                Path { p in
                    let barY = h * 0.38
                    let startX = w * 0.4
                    let endX = w * 0.7
                    // Top bar
                    p.move(to: CGPoint(x: startX, y: barY))
                    p.addLine(to: CGPoint(x: endX, y: barY))
                    // Legs
                    p.move(to: CGPoint(x: startX, y: barY))
                    p.addLine(to: CGPoint(x: startX, y: h * 0.55))
                    p.move(to: CGPoint(x: endX, y: barY))
                    p.addLine(to: CGPoint(x: endX, y: h * 0.55))
                    // Rungs
                    for i in 0..<5 {
                        let x = startX + CGFloat(i) * (endX - startX) / 4
                        p.move(to: CGPoint(x: x, y: barY))
                        p.addLine(to: CGPoint(x: x, y: barY + 12))
                    }
                }
                .stroke(Color.white.opacity(0.12), lineWidth: 2.5)

                // Seesaw
                Path { p in
                    let centerX = w * 0.85
                    let centerY = h * 0.55
                    // Triangle base
                    p.move(to: CGPoint(x: centerX - 8, y: centerY))
                    p.addLine(to: CGPoint(x: centerX + 8, y: centerY))
                    p.addLine(to: CGPoint(x: centerX, y: centerY - 12))
                    p.closeSubpath()
                    // Board (tilts with animation)
                    let tilt = sin(phase * .pi * 2) * 8
                    p.move(to: CGPoint(x: centerX - 30, y: centerY - 12 + tilt))
                    p.addLine(to: CGPoint(x: centerX + 30, y: centerY - 12 - tilt))
                }
                .stroke(Color.white.opacity(0.12), lineWidth: 2.5)

                // Phone emoji moving through the playground
                phonePosition(w: w, h: h)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                phase = 1.0
            }
        }
    }

    @ViewBuilder
    private func phonePosition(w: CGFloat, h: CGFloat) -> some View {
        let pos = phonePoint(w: w, h: h, t: phase)
        Text("📱")
            .font(.system(size: 18))
            .opacity(0.2)
            .position(pos)
            .animation(.linear(duration: duration).repeatForever(autoreverses: false), value: phase)
    }

    private func phonePoint(w: CGFloat, h: CGFloat, t: CGFloat) -> CGPoint {
        if t < 0.33 {
            // Sliding down the slide
            let p = t / 0.33
            let x = w * 0.1 + (w * 0.25) * p
            let y = h * 0.35 + (h * 0.20) * p
            return CGPoint(x: x, y: y)
        } else if t < 0.66 {
            // Crossing monkey bars
            let p = (t - 0.33) / 0.33
            let x = w * 0.4 + (w * 0.3) * p
            let y = h * 0.38 + sin(p * .pi * 4) * 8
            return CGPoint(x: x, y: y)
        } else {
            // Bouncing on seesaw
            let p = (t - 0.66) / 0.34
            let x = w * 0.85
            let y = h * 0.43 - abs(sin(p * .pi * 3)) * 30
            return CGPoint(x: x, y: y)
        }
    }
}
