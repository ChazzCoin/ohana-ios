//
//  FloatingEmoji.swift
//  Ohana
//
//  Created by Charles Romeo on 12/7/23.
//

import Foundation
import SwiftUI
import Combine

struct FallingThoughts: View {
    @State var emojiInstances = [UUID]()
    @State var currentEmoji: String
    
    @State var cancellables = Set<AnyCancellable>()
    var sWidth = UIScreen.main.bounds.width
    var sHeight = UIScreen.main.bounds.height
    
    let startTime: Date
    let endTime: Date
    @State private var yOffset: CGFloat = 0

    @State var gps = GlobalPositioningSystem()
    
    var body: some View {
        
        GeometryReader { geo in
            ZStack {

                ForEach(emojiInstances, id: \.self) { id in
                    
                    let tempX = CGFloat.random(in: -150...150)
                    
                    FloatingEmoji(emoji: currentEmoji, xCoord: tempX, id: id)
                        .offset(x: geo.size.width / 2, y: yOffset)
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
    
    private func startAnimation(in height: CGFloat) {
            let totalDuration = endTime.timeIntervalSince(startTime)
            let currentDuration = Date().timeIntervalSince(startTime)
            let progress = max(0, min(currentDuration / totalDuration, 1))

            // Calculate the initial Y offset
            yOffset = height * CGFloat(progress)

            // Start the animation only if it's within the time range
            if currentDuration < totalDuration {
                withAnimation(Animation.linear(duration: totalDuration - currentDuration)) {
                    yOffset = height
                }
            }
        }
    
    
}


