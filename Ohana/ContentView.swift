//
//  ContentView.swift
//  Ohana
//
//  Created by Charles Romeo on 12/7/23.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    
    @State var currentMessage: String = ""
    @ObservedResults(Thought.self) var thoughts
    
    @StateObject var thoughtsObserver = FirebaseThoughtsService()
    @State var keyboardIsShowing = false
    @State var keyboardHeight: CGFloat = 0.0
    
    @State var resetFlag = false
    func resetView() {
        resetFlag = true
        resetFlag = false
    }
    
    func getBackground() -> AnyView {
        if isDaytime() { return AnyView(SunsetGradientView()) }
        return AnyView(StarryNightSkyView())
    }
    
    var body: some View {
        
        GlobalPositioningZStack { geo, gps in
            ZStack {
                
                ForEach(thoughts, id: \.id) { thought in
                    ThoughtView(message: thought.message,
                                screenHeight: gps.screenSize.height,
                                startTime: thought.startDate,
                                endTime: thought.endDate)
                }
                .zIndex(10.0)
                .clearSectionBackground()

                ChatView() { m in
                    currentMessage = m
                }
                .clearSectionBackground()
                .zIndex(2.0)
                .position(gps.getCoordinate(for: .bottomCenter, offsetY: keyboardIsShowing ? (keyboardHeight + 50) : 50))
                
            }
            .frame(width: gps.screenSize.width, height: gps.screenSize.height)
            .background(getBackground())
            .onAppear() {
                thoughtsObserver.startObserving(realm: self.thoughts.realm?.thaw())
            }
            
        }
        .keyboardListener(
            onAppear: { height in
                // Handle keyboard appearance (e.g., adjust view)
                print("Keyboard appeared with height: \(height)")
                keyboardHeight = height
                keyboardIsShowing = true
            },
            onDisappear: { height in
                // Handle keyboard disappearance
                print("Keyboard disappeared")
                keyboardHeight = height
                keyboardIsShowing = false
            }
        )
        
        
    }
}

//#Preview {
//    ContentView()
//}

extension View {
    // Method to set the position of the view based on a specified ScreenArea
    func position(using gps: GlobalPositioningSystem, at area: ScreenArea, offsetX: CGFloat = 0, offsetY: CGFloat = 0) -> some View {
        self.position(gps.getCoordinate(for: area, offsetX: offsetX, offsetY: offsetY))
    }
}
