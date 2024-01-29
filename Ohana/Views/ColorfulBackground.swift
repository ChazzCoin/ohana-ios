//
//  ColorfulBackground.swift
//  Ohana
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct DynamicGradientBackground: View {
    // Define the initial gradient colors
    @State private var startColor = Color.blue
    @State private var endColor = Color.purple

    // Define the animation duration
    let animationDuration: TimeInterval = 10

    // This function changes the gradient colors
    private func changeGradientColors() {
        withAnimation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true)) {
            // Change to new gradient colors
            startColor = Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
            endColor = Color(red: Double.random(in: 0...1), green: Double.random(in: 0...1), blue: Double.random(in: 0...1))
        }
    }

    var body: some View {
        LinearGradient(gradient: Gradient(colors: [startColor, endColor]), startPoint: .topLeading, endPoint: .bottomTrailing)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                changeGradientColors()
            }
    }
}



struct ContentViewww_Previews: PreviewProvider {
    static var previews: some View {
        DynamicGradientBackground()
    }
}
