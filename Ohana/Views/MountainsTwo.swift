//
//  MountainsTwo.swift
//  Ohana
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct Mountain2LandscapeView: View {
    var body: some View {
        ZStack {
            // Sky
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple]),
                           startPoint: .top, endPoint: .bottom)
            .edgesIgnoringSafeArea(.all)

            // Sun
            Circle()
                .fill(Color.yellow)
                .frame(width: 100, height: 100)
                .position(x: 50, y: 50)

            // Distant Mountains
            Group {
                MountainShape2(inclination: 0.5)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.5), Color.white]),
                                         startPoint: .bottom,
                                         endPoint: .top))
                    .frame(height: 280)
                    .offset(y: 180)

                MountainShape2(inclination: 0.3)
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.white]),
                                         startPoint: .bottom,
                                         endPoint: .top))
                    .frame(height: 260)
                    .offset(y: 200)
            }

            // Foreground Mountains
            MountainShape2(inclination: 0.6)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.gray]),
                                     startPoint: .bottom,
                                     endPoint: .top))
                .frame(height: 200)
                .offset(y: 300)
        }
    }
}

struct MountainShape2: Shape {
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

struct Mountain2LandscapeView_Previews: PreviewProvider {
    static var previews: some View {
        Mountain2LandscapeView()
    }
}
