//
//  ThoughtBubble.swift
//  Ohana
//
//  Created by Charles Romeo on 1/3/24.
//

import Foundation
import SwiftUI

struct ThoughtBubbleView: View {
    @State var thought: String
    
    var body: some View {
        Text(thought)
            .padding() // Add some padding around the text
            .background(Color.white) // White background for the bubble
            .clipShape(BubbleShape()) // Custom shape for the thought bubble
            .shadow(radius: 5) // Add a subtle shadow for a 3D effect
    }
}

struct BubbleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Main bubble
        path.addRoundedRect(in: CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height - rect.height / 4), cornerSize: CGSize(width: 20, height: 20))

        // Tail
        let tailWidth: CGFloat = 20
        let tailHeight: CGFloat = rect.height / 4
        let tailOrigin = CGPoint(x: rect.width / 2 - tailWidth / 2, y: rect.height - tailHeight)
        path.move(to: tailOrigin)
        path.addLine(to: CGPoint(x: rect.width / 2, y: rect.height))
        path.addLine(to: CGPoint(x: rect.width / 2 + tailWidth / 2, y: tailOrigin.y))
        path.addLine(to: tailOrigin)

        return path
    }
}

struct ThoughtBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        ThoughtBubbleView(thought: "This is a thought")
    }
}
