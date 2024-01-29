//
//  DayToNight.swift
//  Ohana
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct DayToNight: View {
    @State private var gradientColors = [Color.blue, Color.orange]
    @State private var sunPosition = UnitPoint(x: 0.1, y: 0.3)
    @State private var showStars = false

    // Update the background based on the time of day
    private func updateBackground() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        // Transition from day to night
        if hour >= 6 && hour < 18 { // Daytime
            gradientColors = [Color.blue, Color.orange]
            sunPosition = UnitPoint(x: Double(hour - 6) / 12.0, y: 0.3)
            showStars = false
        } else { // Nighttime
            gradientColors = [Color.black, Color.purple]
            sunPosition = UnitPoint(x: 0.1, y: 0.3) // Reset sun position for the next day
            showStars = true
        }
    }

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(gradient: Gradient(colors: gradientColors), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .onAppear {
                    updateBackground()
                }

            // Sun and Moon
            Circle()
                .frame(width: 30, height: 30)
                .foregroundColor(showStars ? Color.yellow : Color.clear) // Sun during day, hidden at night
                .position(x: sunPosition.x * UIScreen.main.bounds.width, y: sunPosition.y * UIScreen.main.bounds.height)

            // Stars
            if showStars {
                StarryNightSkyView()
            }
        }
    }
}


struct DynamicGradientBackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        DayToNight()
    }
}
