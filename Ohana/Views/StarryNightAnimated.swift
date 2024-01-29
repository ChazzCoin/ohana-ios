//
//  StarryNightAnimated.swift
//  Ohana
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct StarryNightAnimatedView: View {
    @State private var twinklingStars: [Star] = []
    @State private var shootingStarPosition: CGPoint = .zero
    @State private var shootingStarTrailingPosition = CGPoint(x: 0, y: 0)
//    @State private var shootingStarOffset: CGFloat = 0
    @State private var shootingStarOpacity: Double = 0

    // Timers for different animations
    let twinklingTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect() // Slower twinkling
    let shootingStarTimer = Timer.publish(every: 5, on: .main, in: .common).autoconnect() // Less frequent shooting stars


    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple, Color.blue]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            // Twinkling Stars
            Canvas { context, size in
                for star in twinklingStars {
                    let starRect = CGRect(x: star.position.x, y: star.position.y, width: star.size, height: star.size)
                    context.fill(Path(ellipseIn: starRect), with: .color(Color.white.opacity(star.opacity)))
                }
            }
            
            // Shooting Star
            ShootingStarView(leadingPoint: shootingStarPosition, trailingPoint: shootingStarTrailingPosition)
                            .opacity(shootingStarOpacity)
        }
        .onAppear {
            generateTwinklingStars(count: 100)
        }
        .onReceive(twinklingTimer) { _ in
            updateTwinklingStars()
        }
        .onReceive(shootingStarTimer) { _ in
            animateShootingStar()
        }
    }

    private func generateTwinklingStars(count: Int) {
        twinklingStars = (0..<count).map { _ in
            Star(position: CGPoint(x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                   y: CGFloat.random(in: 0...UIScreen.main.bounds.height)),
                 size: CGFloat.random(in: 1...3),
                 opacity: Double.random(in: 0.5...1))
        }
    }

    private func updateTwinklingStars() {
        for i in twinklingStars.indices {
            twinklingStars[i].opacity = Double.random(in: 0.5...1)
        }
    }

    private func animateShootingStar() {
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        let startOffsetX = CGFloat.random(in: -100...100)
        let startY = CGFloat.random(in: 0...screenHeight / 3)
        let endY = CGFloat.random(in: startY...screenHeight / 2)
        shootingStarPosition = CGPoint(x: startOffsetX, y: startY)
        shootingStarTrailingPosition = CGPoint(x: startOffsetX - 50, y: startY - 50)
        shootingStarOpacity = 1

        withAnimation(Animation.linear(duration: 2)) {
            shootingStarPosition = CGPoint(x: screenWidth + 100, y: endY)
            shootingStarTrailingPosition = CGPoint(x: screenWidth + 50, y: endY - 50)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            shootingStarOpacity = 0
        }
    }
}

struct ShootingStarView: View {
    var leadingPoint: CGPoint
    var trailingPoint: CGPoint

    var body: some View {
        Path { path in
            path.move(to: trailingPoint)
            path.addLine(to: leadingPoint)
        }
        .stroke(Color.white, lineWidth: 2)
        .shadow(radius: 5)
    }
}

struct Star {
    var position: CGPoint
    var size: CGFloat
    var opacity: Double
}

struct StarryNightAnimatedView_Previews: PreviewProvider {
    static var previews: some View {
        StarryNightAnimatedView()
    }
}
