//
//  StaryNight.swift
//  Ohana
//
//  Created by Charles Romeo on 1/25/24.
//

import Foundation
import SwiftUI

struct StarryNightSkyView: View {
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.black, Color.purple, Color.blue]),
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            // Canvas for stars
            Canvas { context, size in
                for _ in 0..<100 { // Adjust number of stars as needed
                    let x = CGFloat.random(in: 0...size.width)
                    let y = CGFloat.random(in: 0...size.height)
                    let starSize = CGFloat.random(in: 1...3)
                    let starOpacity = Double.random(in: 0.5...1)
                    let starRect = CGRect(x: x, y: y, width: starSize, height: starSize)
                    
                    context.fill(Path(ellipseIn: starRect), with: .color(Color.white.opacity(starOpacity)))
                }
            }
        }
    }
}

struct StarryNightSkyView_Previews: PreviewProvider {
    static var previews: some View {
        StarryNightSkyView()
    }
}
