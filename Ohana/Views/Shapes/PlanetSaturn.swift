//
//  PlanetSaturn.swift
//  Ohana
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

struct SaturnView: View {
    var body: some View {
        ZStack {
            // Saturn's Body
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow, Color.orange, Color.red]),
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 50, height: 50)
                .shadow(radius: 10)
                .opacity(0.65)

            // Saturn's Rings
//            SaturnRings()
//                .offset(x: 0, y: 20) // Adjust offset here
        }
    }
}

struct SaturnRings: View {
    var body: some View {
        ZStack {
            SaturnRingShape(inset: 5)
                .fill(LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.white.opacity(0.8), Color.gray.opacity(0.4)]),
                                     startPoint: .leading, endPoint: .trailing))
                .frame(width: 140, height: 50) // Adjust ring size here
                .rotationEffect(.degrees(15))

            SaturnRingShape(inset: 10)
                .stroke(Color.white.opacity(0.8), lineWidth: 1)
                .frame(width: 140, height: 50) // Adjust ring size here
                .rotationEffect(.degrees(15))
        }
    }
}

struct SaturnRingShape: Shape {
    var inset: CGFloat

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        path.addEllipse(in: rect.insetBy(dx: inset, dy: inset))
        return path
    }
}

struct SaturnGradient: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.red, Color.orange, Color.yellow, Color.orange, Color.red]),
                       startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

struct RingGradient: View {
    var body: some View {
        LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.4), Color.white.opacity(0.8), Color.gray.opacity(0.4)]),
                       startPoint: .leading, endPoint: .trailing)
    }
}

#Preview {
    SaturnView()
}

