//
//  FloatingEmoji.swift
//  Ohana
//
//  Created by Charles Romeo on 12/7/23.
//

import Foundation
import SwiftUI
import Combine

struct FloatingEmojiView: View {
    @State var emojiInstances = [UUID]()
    @State var currentEmoji: String
    
    @State var cancellables = Set<AnyCancellable>()
    var sWidth = UIScreen.main.bounds.width
    var sHeight = UIScreen.main.bounds.height
    
    @State var gps = GlobalPositioningSystem()
    
    var body: some View {
        ZStack {

            // Displaying all the emoji instances
            ForEach(emojiInstances, id: \.self) { id in
                let tempX = CGFloat.random(in: -150...150)
                FloatingEmoji(emoji: currentEmoji, xCoord: tempX, id: id)
                    .offset(x: 0, y: 50)
                    .zIndex(20.0)
            }
        }
        .frame(width: 400, height: 400)
        .background(Color.clear)
        .onAppear() {
            CodiChannel.general.receive(on: RunLoop.main) { message in
                currentEmoji = message as! String
                addEmojiInstance()
            }.store(in: &cancellables)
        }
    }

    private func addEmojiInstance() {
        withAnimation {
            emojiInstances.append(UUID())
        }
        
        // Optional: Remove the instance after animation to clear memory
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            emojiInstances.removeAll { $0 == emojiInstances.first }
        }
    }
}

struct FloatingEmoji: View {
    @State var emoji: String
    @State var xCoord: Double
    var id: UUID
    @State var directionIsUp: Bool = false
    let animationDuration: TimeInterval = 3

    @State private var isFloating = false
    @State private var isFaded = false

    var body: some View {
        Text(emoji)
            .font(.system(size: 40))
            .opacity(isFaded ? 0 : 1)
            .offset(x: xCoord, y: isFloating ? (directionIsUp ? -200 : 200) : 0) // Increased offset for a continuous upward movement
            .animation(.easeInOut(duration: animationDuration), value: isFloating)
            .onAppear {
                withAnimation {
                    isFloating = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration / 2) {
                    withAnimation {
                        isFaded = true
                    }
                }
            }
    }
}
