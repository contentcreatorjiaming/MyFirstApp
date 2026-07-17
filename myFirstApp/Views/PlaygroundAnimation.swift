//
//  PlaygroundAnimation.swift
//  myFirstApp
//
//  Animated lines that draw themselves into playground equipment
//  spread across the background, surrounding the menu text.
//

import SwiftUI

struct PlaygroundAnimation: View {
    @State private var drawProgress: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // Slide (top-left)
                Path { p in
                    let sx = w * 0.05, sy = h * 0.28
                    p.move(to: CGPoint(x: sx, y: sy))
                    p.addLine(to: CGPoint(x: sx, y: sy + 70))
                    p.move(to: CGPoint(x: sx + 20, y: sy))
                    p.addLine(to: CGPoint(x: sx + 20, y: sy + 70))
                    p.move(to: CGPoint(x: sx, y: sy + 5))
                    p.addLine(to: CGPoint(x: sx + 20, y: sy + 5))
                    p.move(to: CGPoint(x: sx, y: sy + 20))
                    p.addLine(to: CGPoint(x: sx + 20, y: sy + 20))
                    p.move(to: CGPoint(x: sx + 20, y: sy))
                    p.addLine(to: CGPoint(x: sx + 65, y: sy + 70))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // Swing set (center-top)
                Path { p in
                    let cx = w * 0.5, sy = h * 0.22
                    p.move(to: CGPoint(x: cx - 35, y: sy + 65))
                    p.addLine(to: CGPoint(x: cx, y: sy))
                    p.addLine(to: CGPoint(x: cx + 35, y: sy + 65))
                    p.move(to: CGPoint(x: cx - 12, y: sy + 20))
                    p.addLine(to: CGPoint(x: cx - 12, y: sy + 50))
                    p.move(to: CGPoint(x: cx + 12, y: sy + 20))
                    p.addLine(to: CGPoint(x: cx + 12, y: sy + 50))
                    p.move(to: CGPoint(x: cx - 18, y: sy + 50))
                    p.addLine(to: CGPoint(x: cx - 6, y: sy + 50))
                    p.move(to: CGPoint(x: cx + 6, y: sy + 50))
                    p.addLine(to: CGPoint(x: cx + 18, y: sy + 50))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // Monkey bars (top-right)
                Path { p in
                    let sx = w * 0.68, ex = w * 0.95, sy = h * 0.30
                    p.move(to: CGPoint(x: sx, y: sy + 55))
                    p.addLine(to: CGPoint(x: sx, y: sy))
                    p.addLine(to: CGPoint(x: ex, y: sy))
                    p.addLine(to: CGPoint(x: ex, y: sy + 55))
                    for i in 0..<5 {
                        let rx = sx + CGFloat(i + 1) * (ex - sx) / 6
                        p.move(to: CGPoint(x: rx, y: sy))
                        p.addLine(to: CGPoint(x: rx, y: sy + 10))
                    }
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // Seesaw (bottom-right)
                Path { p in
                    let cx = w * 0.82, sy = h * 0.62
                    p.move(to: CGPoint(x: cx - 8, y: sy))
                    p.addLine(to: CGPoint(x: cx, y: sy - 14))
                    p.addLine(to: CGPoint(x: cx + 8, y: sy))
                    p.move(to: CGPoint(x: cx - 30, y: sy - 14))
                    p.addLine(to: CGPoint(x: cx + 30, y: sy - 14))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                // Merry-go-round (bottom-left)
                Path { p in
                    let cx = w * 0.15, cy = h * 0.65
                    let r: CGFloat = 25
                    p.addEllipse(in: CGRect(x: cx - r, y: cy - r * 0.4, width: r * 2, height: r * 0.8))
                    p.move(to: CGPoint(x: cx, y: cy))
                    p.addLine(to: CGPoint(x: cx, y: cy - 18))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color.white.opacity(0.15), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                drawProgress = 1.0
            }
        }
    }
}
