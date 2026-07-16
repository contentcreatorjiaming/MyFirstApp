//
//  PlaygroundAnimation.swift
//  myFirstApp
//
//  Animated lines that draw themselves into playground equipment
//  (slide, swing set, seesaw, monkey bars). Positioned above the title.
//

import SwiftUI

struct PlaygroundAnimation: View {
    @State private var drawProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let baseY = h * 0.32

            ZStack {
                // Slide
                Path { p in
                    p.move(to: CGPoint(x: w * 0.08, y: baseY - 50))
                    p.addLine(to: CGPoint(x: w * 0.08, y: baseY))
                    p.move(to: CGPoint(x: w * 0.18, y: baseY - 50))
                    p.addLine(to: CGPoint(x: w * 0.18, y: baseY))
                    p.move(to: CGPoint(x: w * 0.08, y: baseY - 45))
                    p.addLine(to: CGPoint(x: w * 0.18, y: baseY - 45))
                    p.move(to: CGPoint(x: w * 0.08, y: baseY - 35))
                    p.addLine(to: CGPoint(x: w * 0.18, y: baseY - 35))
                    p.move(to: CGPoint(x: w * 0.18, y: baseY - 50))
                    p.addLine(to: CGPoint(x: w * 0.35, y: baseY))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // Swing set
                Path { p in
                    let cx = w * 0.5
                    p.move(to: CGPoint(x: cx - 25, y: baseY))
                    p.addLine(to: CGPoint(x: cx, y: baseY - 55))
                    p.addLine(to: CGPoint(x: cx + 25, y: baseY))
                    p.move(to: CGPoint(x: cx - 10, y: baseY - 35))
                    p.addLine(to: CGPoint(x: cx - 10, y: baseY - 10))
                    p.move(to: CGPoint(x: cx + 10, y: baseY - 35))
                    p.addLine(to: CGPoint(x: cx + 10, y: baseY - 10))
                    p.move(to: CGPoint(x: cx - 15, y: baseY - 10))
                    p.addLine(to: CGPoint(x: cx - 5, y: baseY - 10))
                    p.move(to: CGPoint(x: cx + 5, y: baseY - 10))
                    p.addLine(to: CGPoint(x: cx + 15, y: baseY - 10))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // Monkey bars
                Path { p in
                    let sx = w * 0.62
                    let ex = w * 0.82
                    let barY = baseY - 50
                    p.move(to: CGPoint(x: sx, y: baseY))
                    p.addLine(to: CGPoint(x: sx, y: barY))
                    p.addLine(to: CGPoint(x: ex, y: barY))
                    p.addLine(to: CGPoint(x: ex, y: baseY))
                    for i in 0..<4 {
                        let rx = sx + CGFloat(i + 1) * (ex - sx) / 5
                        p.move(to: CGPoint(x: rx, y: barY))
                        p.addLine(to: CGPoint(x: rx, y: barY + 8))
                    }
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // Seesaw
                Path { p in
                    let cx = w * 0.92
                    p.move(to: CGPoint(x: cx - 6, y: baseY))
                    p.addLine(to: CGPoint(x: cx, y: baseY - 10))
                    p.addLine(to: CGPoint(x: cx + 6, y: baseY))
                    p.move(to: CGPoint(x: cx - 22, y: baseY - 10))
                    p.addLine(to: CGPoint(x: cx + 22, y: baseY - 10))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.18), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                drawProgress = 1.0
            }
        }
    }
}
