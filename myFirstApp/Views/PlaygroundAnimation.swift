//
//  PlaygroundAnimation.swift
//  myFirstApp
//
//  Animated playground scene arranged around the screen edges so it
//  never overlaps titles, buttons or the expanded menu. Equipment
//  draws itself in; swings swing, clouds drift, and a seesaw at the
//  bottom center tilts with a ball rolling along the plank.
//

import SwiftUI

struct PlaygroundAnimation: View {
    /// Hide the seesaw when the signed-in menu is showing, since it
    /// sits exactly where the SIGN OUT button appears.
    var showSeesaw: Bool = true
    /// Vertical position of the seesaw: right under the pink/blue
    /// buttons by default; menu screens pass the SIGN OUT spot instead.
    var seesawY: CGFloat = 0.57

    @State private var drawProgress: CGFloat = 0
    @State private var swingPhase: Double = -1     // -1...1
    @State private var cloudShift: CGFloat = 0
    @State private var sunAngle: Double = 0

    private let stroke = Color.white.opacity(0.3)
    private let style = StrokeStyle(lineWidth: 3, lineCap: .round)
    // The seesaw is the hero piece: solid white and chunky like the title
    private let boldStyle = StrokeStyle(lineWidth: 6, lineCap: .round)

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack {
                // ----- Top band (above all titles) -----

                // Sun (top-left corner, slowly rotating)
                Path { p in
                    let r: CGFloat = 18
                    p.addEllipse(in: CGRect(x: -r, y: -r, width: r * 2, height: r * 2))
                    for i in 0..<8 {
                        let a = CGFloat(i) * .pi / 4
                        p.move(to: CGPoint(x: cos(a) * (r + 5), y: sin(a) * (r + 5)))
                        p.addLine(to: CGPoint(x: cos(a) * (r + 13), y: sin(a) * (r + 13)))
                    }
                }
                .trim(from: 0, to: drawProgress)
                .stroke(stroke, style: style)
                .frame(width: 1, height: 1)
                .rotationEffect(.degrees(sunAngle))
                .position(x: w * 0.10, y: h * 0.075)

                // Drifting clouds
                cloud(at: CGPoint(x: w * 0.32 + cloudShift * 0.6, y: h * 0.045), scale: 0.6)
                cloud(at: CGPoint(x: w * 0.86 + cloudShift, y: h * 0.07), scale: 0.85)

                // ----- Left / right edges (clear of centered text) -----

                // Swing set (left edge, below the sun)
                Path { p in
                    let cx = w * 0.13, sy = h * 0.19
                    p.move(to: CGPoint(x: cx - 36, y: sy + 62))
                    p.addLine(to: CGPoint(x: cx, y: sy))
                    p.addLine(to: CGPoint(x: cx + 36, y: sy + 62))
                    p.move(to: CGPoint(x: cx - 24, y: sy + 22))
                    p.addLine(to: CGPoint(x: cx + 24, y: sy + 22))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(stroke, style: style)

                swingSeat(pivot: CGPoint(x: w * 0.13 - 12, y: h * 0.19 + 22), angle: swingPhase * 18)
                swingSeat(pivot: CGPoint(x: w * 0.13 + 12, y: h * 0.19 + 22), angle: swingPhase * -18)

                // Monkey bars (right edge, above the title)
                Path { p in
                    let sx = w * 0.75, ex = w * 0.97, sy = h * 0.19
                    p.move(to: CGPoint(x: sx, y: sy + 48))
                    p.addLine(to: CGPoint(x: sx, y: sy))
                    p.addLine(to: CGPoint(x: ex, y: sy))
                    p.addLine(to: CGPoint(x: ex, y: sy + 48))
                    for i in 0..<4 {
                        let rx = sx + CGFloat(i + 1) * (ex - sx) / 5
                        p.move(to: CGPoint(x: rx, y: sy))
                        p.addLine(to: CGPoint(x: rx, y: sy + 10))
                    }
                }
                .trim(from: 0, to: drawProgress)
                .stroke(stroke, style: style)

                // Spring rider (left edge, mid-height)
                Path { p in
                    let cx = w * 0.32, base = h * 0.79
                    for i in 0..<3 {
                        let y = base - CGFloat(i) * 7
                        p.move(to: CGPoint(x: cx - 7, y: y))
                        p.addQuadCurve(to: CGPoint(x: cx + 7, y: y - 3.5),
                                       control: CGPoint(x: cx + 10, y: y + 2))
                    }
                    p.move(to: CGPoint(x: cx - 15, y: base - 26))
                    p.addLine(to: CGPoint(x: cx + 15, y: base - 26))
                    p.move(to: CGPoint(x: cx + 15, y: base - 26))
                    p.addQuadCurve(to: CGPoint(x: cx + 27, y: base - 33),
                                   control: CGPoint(x: cx + 23, y: base - 23))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(stroke, style: style)

                // Slide (right edge, below the buttons)
                Path { p in
                    let lx = w * 0.94, sy = h * 0.70
                    p.move(to: CGPoint(x: lx, y: sy))
                    p.addLine(to: CGPoint(x: lx, y: sy + 70))
                    p.move(to: CGPoint(x: lx - 20, y: sy))
                    p.addLine(to: CGPoint(x: lx - 20, y: sy + 70))
                    for i in 0..<4 {
                        let ry = sy + 7 + CGFloat(i) * 16
                        p.move(to: CGPoint(x: lx - 20, y: ry))
                        p.addLine(to: CGPoint(x: lx, y: ry))
                    }
                    p.move(to: CGPoint(x: lx - 20, y: sy))
                    p.addCurve(
                        to: CGPoint(x: lx - 75, y: sy + 70),
                        control1: CGPoint(x: lx - 45, y: sy + 12),
                        control2: CGPoint(x: lx - 48, y: sy + 62)
                    )
                }
                .trim(from: 0, to: drawProgress)
                .stroke(stroke, style: style)

                // ----- Bottom band -----

                // Merry-go-round (bottom-left)
                Path { p in
                    let cx = w * 0.13, cy = h * 0.88
                    let r: CGFloat = 28
                    p.addEllipse(in: CGRect(x: cx - r, y: cy - r * 0.4, width: r * 2, height: r * 0.8))
                    p.move(to: CGPoint(x: cx, y: cy))
                    p.addLine(to: CGPoint(x: cx, y: cy - 20))
                    p.move(to: CGPoint(x: cx - 13, y: cy - 15))
                    p.addLine(to: CGPoint(x: cx + 13, y: cy - 15))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(stroke, style: style)

                // Seesaw — bold, solid white, centered
                if showSeesaw {
                    Path { p in
                        let cx = w * 0.5, cy = h * seesawY
                        p.move(to: CGPoint(x: cx - 16, y: cy + 20))
                        p.addLine(to: CGPoint(x: cx, y: cy))
                        p.addLine(to: CGPoint(x: cx + 16, y: cy + 20))
                    }
                    .trim(from: 0, to: drawProgress)
                    .stroke(Color.white, style: boldStyle)

                    // Tilting plank with the ball rolling along it
                    seesawPlank(center: CGPoint(x: w * 0.5, y: h * seesawY), angle: swingPhase * 9)
                }

                // Climbing dome (bottom-right)
                Path { p in
                    let cx = w * 0.72, base = h * 0.89, r: CGFloat = 38
                    p.addArc(center: CGPoint(x: cx, y: base), radius: r,
                             startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    p.addArc(center: CGPoint(x: cx, y: base), radius: r * 0.62,
                             startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
                    p.move(to: CGPoint(x: cx, y: base - r))
                    p.addLine(to: CGPoint(x: cx, y: base))
                    p.move(to: CGPoint(x: cx - r * 0.5, y: base - r * 0.87))
                    p.addLine(to: CGPoint(x: cx - r * 0.31, y: base))
                    p.move(to: CGPoint(x: cx + r * 0.5, y: base - r * 0.87))
                    p.addLine(to: CGPoint(x: cx + r * 0.31, y: base))
                }
                .trim(from: 0, to: drawProgress)
                .stroke(stroke, style: style)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2.5)) {
                drawProgress = 1.0
            }
            withAnimation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true)) {
                swingPhase = 1
            }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                cloudShift = 40
            }
            withAnimation(.linear(duration: 18).repeatForever(autoreverses: false)) {
                sunAngle = 360
            }
        }
    }

    // MARK: - Animated parts

    private func swingSeat(pivot: CGPoint, angle: Double) -> some View {
        Path { p in
            p.move(to: .zero)
            p.addLine(to: CGPoint(x: 0, y: 30))
            p.move(to: CGPoint(x: -6, y: 30))
            p.addLine(to: CGPoint(x: 6, y: 30))
        }
        .trim(from: 0, to: drawProgress)
        .stroke(stroke, style: style)
        .frame(width: 1, height: 1)
        .rotationEffect(.degrees(angle), anchor: .top)
        .position(pivot)
        .offset(y: 15)
    }

    // Plank and ball rotate together, and the ball also slides along
    // the plank toward the low side — same direction as the tilt —
    // staying well inside the ends so it never falls off.
    private func seesawPlank(center: CGPoint, angle: Double) -> some View {
        ZStack {
            Path { p in
                p.move(to: CGPoint(x: -52, y: 0))
                p.addLine(to: CGPoint(x: 52, y: 0))
            }
            .trim(from: 0, to: drawProgress)
            .stroke(Color.white, style: boldStyle)

            Circle()
                .fill(Color.white)
                .frame(width: 22, height: 22)
                .offset(x: CGFloat(angle / 9) * 36, y: -14)
                .opacity(drawProgress)
        }
        .frame(width: 1, height: 1)
        .rotationEffect(.degrees(angle))
        .position(center)
    }

    private func cloud(at point: CGPoint, scale: CGFloat) -> some View {
        Path { p in
            p.addArc(center: CGPoint(x: -14 * scale, y: 0), radius: 10 * scale,
                     startAngle: .degrees(90), endAngle: .degrees(270), clockwise: false)
            p.addArc(center: CGPoint(x: 0, y: -6 * scale), radius: 12 * scale,
                     startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
            p.addArc(center: CGPoint(x: 14 * scale, y: 0), radius: 10 * scale,
                     startAngle: .degrees(270), endAngle: .degrees(90), clockwise: false)
            p.closeSubpath()
        }
        .trim(from: 0, to: drawProgress)
        .stroke(stroke, style: style)
        .frame(width: 1, height: 1)
        .position(point)
    }
}
