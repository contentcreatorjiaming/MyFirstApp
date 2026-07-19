//
//  BallpitBackground.swift
//  myFirstApp
//
//  Ballpit-style animated background inspired by reactbits.dev "Ballpit".
//  Glossy purple / green / coral balls cascade in from the top of the
//  screen on launch, pile up, and keep getting stirred by an invisible
//  roaming pusher (stand-in for the cursor follower).
//  The scene is transparent so the app's pastel green shows through.
//

import SwiftUI
import SpriteKit

struct BallpitBackground: View {
    @State private var scene: BallpitScene = {
        let scene = BallpitScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        return scene
    }()

    var body: some View {
        SpriteView(scene: scene, options: [.allowsTransparency])
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }
}

final class BallpitScene: SKScene {

    // Button pink #F7A1C4 / button blue #009FFD / #7CFF67
    private let ballColors: [UIColor] = [
        UIColor(red: 0.969, green: 0.631, blue: 0.769, alpha: 1),
        UIColor(red: 0.0, green: 0.624, blue: 0.992, alpha: 1),
        UIColor(red: 0x7C / 255, green: 0xFF / 255, blue: 0x67 / 255, alpha: 1)
    ]

    private let ballCount = 50
    private let pusher = SKShapeNode(circleOfRadius: 48)
    private let walls = SKNode()
    private var didSetUp = false

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        view.allowsTransparency = true

        guard !didSetUp else { return }
        didSetUp = true

        physicsWorld.gravity = CGVector(dx: 0, dy: -4)
        addWalls()
        rainBalls()
        addPusher()
    }

    // Left, bottom and right walls only — the top stays open so balls
    // can rain in from above the screen.
    private func addWalls() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: size.height * 3))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: 0))
        path.addLine(to: CGPoint(x: size.width, y: size.height * 3))

        walls.physicsBody = SKPhysicsBody(edgeChainFrom: path)
        walls.physicsBody?.restitution = 0.95
        walls.physicsBody?.friction = 0.05
        addChild(walls)
    }

    // Stagger the drops so the user watches the pit fill up on launch.
    private func rainBalls() {
        for i in 0..<ballCount {
            let delay = Double(i) * 0.05 + Double.random(in: 0...0.04)
            run(SKAction.sequence([
                .wait(forDuration: delay),
                .run { [weak self] in self?.dropBall(index: i) }
            ]))
        }
    }

    private func dropBall(index: Int) {
        let radius = CGFloat.random(in: 13...30)
        let color = ballColors[index % ballColors.count]

        let ball = SKSpriteNode(texture: glossyTexture(color: color, radius: radius))
        ball.size = CGSize(width: radius * 2, height: radius * 2)
        ball.position = CGPoint(
            x: CGFloat.random(in: radius...(size.width - radius)),
            y: size.height + radius + CGFloat.random(in: 0...60)
        )

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.restitution = 0.8
        body.friction = 0.1
        body.linearDamping = 0.2
        body.density = 1
        body.velocity = CGVector(dx: CGFloat.random(in: -60...60), dy: 0)
        ball.physicsBody = body

        addChild(ball)
    }

    // Sphere-shaded texture: bright top-left light, darker edge and a
    // soft specular highlight — the "clearcoat" look from the original.
    private func glossyTexture(color: UIColor, radius: CGFloat) -> SKTexture {
        let diameter = radius * 2 * UIScreen.main.scale
        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)

        let renderer = UIGraphicsImageRenderer(size: rect.size)
        let image = renderer.image { ctx in
            let cg = ctx.cgContext
            cg.addEllipse(in: rect)
            cg.clip()

            var hue: CGFloat = 0, sat: CGFloat = 0, bri: CGFloat = 0, alp: CGFloat = 0
            color.getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alp)
            let light = UIColor(hue: hue, saturation: max(0, sat - 0.3), brightness: min(1, bri + 0.3), alpha: 1)
            let dark = UIColor(hue: hue, saturation: min(1, sat + 0.15), brightness: bri * 0.5, alpha: 1)

            let space = CGColorSpaceCreateDeviceRGB()
            let body = CGGradient(
                colorsSpace: space,
                colors: [light.cgColor, color.cgColor, dark.cgColor] as CFArray,
                locations: [0, 0.5, 1]
            )!
            cg.drawRadialGradient(
                body,
                startCenter: CGPoint(x: diameter * 0.35, y: diameter * 0.32),
                startRadius: 0,
                endCenter: CGPoint(x: diameter * 0.5, y: diameter * 0.5),
                endRadius: diameter * 0.72,
                options: .drawsAfterEndLocation
            )

            let shineCenter = CGPoint(x: diameter * 0.32, y: diameter * 0.28)
            let shine = CGGradient(
                colorsSpace: space,
                colors: [UIColor(white: 1, alpha: 0.9).cgColor,
                         UIColor(white: 1, alpha: 0).cgColor] as CFArray,
                locations: [0, 1]
            )!
            cg.drawRadialGradient(
                shine,
                startCenter: shineCenter, startRadius: 0,
                endCenter: shineCenter, endRadius: diameter * 0.32,
                options: []
            )
        }
        return SKTexture(image: image)
    }

    // Invisible ball that wanders through the pit and keeps the pile moving,
    // mimicking the followCursor sphere in the original effect.
    private func addPusher() {
        pusher.fillColor = .clear
        pusher.strokeColor = .clear
        pusher.position = CGPoint(x: size.width / 2, y: 60)

        let body = SKPhysicsBody(circleOfRadius: 48)
        body.isDynamic = false
        pusher.physicsBody = body

        addChild(pusher)
        roam()
    }

    private func roam() {
        let target = CGPoint(
            x: CGFloat.random(in: 30...(size.width - 30)),
            y: CGFloat.random(in: 30...(size.height * 0.45))
        )
        let move = SKAction.move(to: target, duration: Double.random(in: 1.0...2.0))
        move.timingMode = .easeInEaseOut
        pusher.run(move) { [weak self] in
            self?.roam()
        }
    }
}
