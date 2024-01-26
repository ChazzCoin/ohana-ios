//
//  CloudShape.swift
//  Ohana
//
//  Created by Charles Romeo on 1/24/24.
//

import Foundation
import SwiftUI

struct CloudsView: View {
    let cloudWidth: CGFloat = 200
    let cloudHeight: CGFloat = 100
    let screen = UIScreen.main.bounds
    @State private var cloudOffset = CGFloat.zero

    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5000) { _ in
                CloudShape()
                    .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color("skyBlue")]), startPoint: .top, endPoint: .bottom))
                    .frame(width: cloudWidth, height: cloudHeight)
            }
        }
        .offset(x: cloudOffset)
        .onAppear {
            withAnimation(Animation.linear(duration: 500).repeatForever(autoreverses: false)) {
                cloudOffset = -screen.width * 2
            }
        }
    }
}

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // First cloud segment
        path.addEllipse(in: CGRect(x: rect.minX, y: rect.midY - rect.height * 0.2, width: rect.width * 0.3, height: rect.height * 0.6))
        
        // Second cloud segment
        path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.2, y: rect.midY - rect.height * 0.3, width: rect.width * 0.4, height: rect.height * 0.6))

        // Third cloud segment
        path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.5, y: rect.midY - rect.height * 0.4, width: rect.width * 0.3, height: rect.height * 0.6))

        // Fourth cloud segment
        path.addEllipse(in: CGRect(x: rect.minX + rect.width * 0.7, y: rect.midY - rect.height * 0.2, width: rect.width * 0.4, height: rect.height * 0.6))

        // Base of the cloud to unify the segments
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY + rect.height * 0.2))
        path.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY + rect.height * 0.2),
                      control1: CGPoint(x: rect.minX + rect.width * 0.3, y: rect.maxY),
                      control2: CGPoint(x: rect.minX + rect.width * 0.7, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))

        return path
    }
}



struct CloudView_Previews: PreviewProvider {
    static var previews: some View {
        CloudShape()
            .fill(LinearGradient(gradient: Gradient(colors: [Color.blue, Color("skyBlue")]), startPoint: .top, endPoint: .bottom))
            .frame(width: 200, height: 100)
    }
}
