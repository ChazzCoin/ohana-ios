//
//  TimedView.swift
//  Ohana
//
//  Created by Charles Romeo on 1/3/24.
//

import Foundation
import SwiftUI
import Combine

struct TimedViewData {
    var view: AnyView
    var thought: String
    var startTime: TimeInterval
    var endTime: TimeInterval
}


struct FallingViewsManager: View {
    var screenHeight: CGFloat = UIScreen.main.bounds.height
    @State var timedViews: [TimedViewData] = []
    @State private var position: CGPoint = CGPoint(x: 50, y: 0)
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            ForEach(0..<timedViews.count, id: \.self) { index in
                TimedView(timedViewData: timedViews[index])
            }
        }.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        .onAppear() {
            timedViews.append(TimedViewData(view: AnyView(Text("This is a thought")), thought: "This is a thought", startTime: futureTimestamp(after: 1, unit: .minutes), endTime: futureTimestamp(after: 1, unit: .hours)))
        }
    }
}

struct TimedView: View {
    @State var timedViewData: TimedViewData
    @State var offsetY: CGFloat = -(UIScreen.main.bounds.height/2)
    @State var offsetX: CGFloat = 0
    @State var isVisible: Bool = true

    var body: some View {
        timedViewData.view
            .position(x: offsetX, y: offsetY)
            .opacity(isVisible ? 1 : 0)
            .onAppear() {
                offsetX = CGFloat.random(in: -UIScreen.main.bounds.width/2...UIScreen.main.bounds.width)
                print(UIScreen.main.bounds.height)
                animateOffset(from: 0, to: UIScreen.main.bounds.height, duration: 10)
            }
    }
    
    // Function to animate the offset
    func animateOffset(from startY: CGFloat, to endY: CGFloat, duration: TimeInterval) {
        // Set initial offset
        offsetY = startY
        print("Start: \(startY)")
        print("End: \(endY)")
        // Trigger the animation
        withAnimation(.linear(duration: duration)) {
            offsetY = endY
        }
        // Call the completion handler after the duration of the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            withAnimation(.linear(duration: 3)) {
                isVisible = false
            }
            
        }
    }
    
    func calculateDuration() -> TimeInterval {
        return timedViewData.endTime - timedViewData.startTime
    }
}

struct ThoughtView: View {
    let message: String
    let screenHeight: CGFloat
    let startTime: Date
    let endTime: Date
    @State private var yOffset: CGFloat = 0
    @State private var xOffset = CGFloat.random(in: 16...UIScreen.main.bounds.width-16)
    @State private var fontSize = CGFloat.random(in: 6...32)
    @State private var isVisible: Bool = true
    @State private var fontColor: Color = isDaytime() ? Color.black : Color.white

    var body: some View {
        Text(message)
            .font(.system(size: fontSize))
            .foregroundColor(fontColor)
            .padding()
            .background(
                LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.4), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
            )
            .clipShape(ThoughtBubble())
            .cornerRadius(30)
            .shadow(radius: 5)
            .opacity(isVisible ? 1 : 0)
            .position(x: xOffset, y: yOffset)
            .onAppear {
                calculateInitialPosition()
                startAnimation()
            }
    }

    private func calculateInitialPosition() {
        let currentTime = Date()
        let elapsedTime = currentTime.timeIntervalSince(startTime)
        let totalDuration = endTime.timeIntervalSince(startTime)
        let speed = screenHeight / CGFloat(totalDuration)
        yOffset = speed * CGFloat(elapsedTime)
    }

    private func startAnimation() {
        let remainingDuration = endTime.timeIntervalSince(Date())
        withAnimation(.linear(duration: remainingDuration)) {
            yOffset = screenHeight
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + remainingDuration) {
            withAnimation {
                isVisible = false
            }
        }
    }
}

struct ThoughtBubble: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        // Create a custom path for the thought bubble
        // This is a basic example, you might want to customize the shape to fit your needs
        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height), cornerSize: CGSize(width: 30, height: 30))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.6, y: rect.height, width: 20, height: 20), cornerSize: CGSize(width: 10, height: 10))
        
        return path
    }
}
