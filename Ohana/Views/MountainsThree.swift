//
//  MountainsThree.swift
//  Ohana
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct MountainLandscapeView: View {
    var body: some View {
        ZStack {
            // Sky
            SkyView()

            // Sun
            Circle()
                .fill(Color.yellow)
                .frame(width: 80, height: 80)
                .position(x: 60, y: 100)

            // Mountains
            MountainsView()

            // Lake
            LakeView()

            // Foreground Trees
            TreesView()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct SkyView: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple]),
                       startPoint: .top, endPoint: .bottom)
    }
}

struct MountainsView: View {
    var body: some View {
        Group {
            MountainShape(inclination: 0.5)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.white]),
                                     startPoint: .bottom, endPoint: .top))
                .frame(height: 280)
                .offset(y: 180)

            MountainShape(inclination: 0.3)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.white]),
                                     startPoint: .bottom, endPoint: .top))
                .frame(height: 260)
                .offset(y: 200)

            MountainShape(inclination: 0.6)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.gray]),
                                     startPoint: .bottom, endPoint: .top))
                .frame(height: 200)
                .offset(y: 300)
        }
    }
}

struct LakeView: View {
    var body: some View {
        Ellipse()
            .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                                 startPoint: .top, endPoint: .bottom))
            .frame(height: 100)
            .offset(y: 350)
    }
}

struct TreesView: View {
    var body: some View {
        HStack(spacing: 20) {
            ForEach(0..<5) { _ in
                TreeShape()
                    .fill(Color.green)
                    .frame(width: 20, height: 60)
            }
        }
        .offset(y: 400)
    }
}

struct MountainShape: Shape {
    var inclination: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                      control1: CGPoint(x: rect.maxX * inclination, y: rect.maxY * 0.2),
                      control2: CGPoint(x: rect.maxX * (1 - inclination), y: rect.maxY * 0.5))
        path.closeSubpath()
        return path
    }
}

struct TreeShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLines([
            CGPoint(x: rect.maxX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.maxY),
            CGPoint(x: rect.midX, y: rect.minY)
        ])
        return path
    }
}

struct MountainLandscapeView_Previews: PreviewProvider {
    static var previews: some View {
        MountainLandscapeView()
    }
}
