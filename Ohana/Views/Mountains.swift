//
//  Mountains.swift
//  Ohana
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct Mountain1LandscapeView: View {
    var body: some View {
        ZStack {
            // Sky
            Color.blue
                .edgesIgnoringSafeArea(.all)

            // Sun
            Circle()
                .fill(Color.yellow)
                .frame(width: 100, height: 100)
                .position(x: 50, y: 50)

            // Mountains
            Mountain1Shape()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.gray, Color.white]),
                                     startPoint: .bottom,
                                     endPoint: .top))
                .frame(height: 300)
                .offset(y: 200)

            // Foreground Mountains
            Mountain1Shape()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.green, Color.gray]),
                                     startPoint: .bottom,
                                     endPoint: .top))
                .frame(height: 200)
                .offset(y: 300)
        }
    }
}

struct Mountain1Shape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX * 0.2, y: rect.maxY * 0.5))
        path.addLine(to: CGPoint(x: rect.maxX * 0.5, y: rect.maxY * 0.2))
        path.addLine(to: CGPoint(x: rect.maxX * 0.8, y: rect.maxY * 0.6))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

struct Mountain1LandscapeView_Previews: PreviewProvider {
    static var previews: some View {
        Mountain1LandscapeView()
    }
}
