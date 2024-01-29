//
//  ContentView.swift
//  Ohana
//
//  Created by Charles Romeo on 12/7/23.
//

import SwiftUI
import RealmSwift

struct ContentView: View {
    @Environment(\.scenePhase) var deviceState
    @State var currentMessage: String = ""
//    @ObservedResults(Thought.self) var thoughts
    
    @StateObject var thoughtsObserver = FirebaseThoughtsService()
    @State var keyboardIsShowing = false
    @State var keyboardHeight: CGFloat = 0.0
    
    @State private var filterIsOn: Bool = false
    @State private var currentFilter = "General"
    @State private var filters: [String] = [
        "General",
        "Happy",
        "Sad",
        "Angry",
        "Anxious",
        "Excited",
        "Grateful",
        "Hopeful",
        "Relaxed",
        "Stressed",
        "Confused",
        "Disappointed",
        "Inspired",
        "Lonely",
        "Proud",
        "Curious",
        "Frustrated",
        "Amused",
        "Overwhelmed",
        "Content"
    ]
    
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
                ForEach(self.thoughtsObserver.thoughts, id: \.id) { thought in
                    if !thought.isInvalidated {
                        ThoughtView(
                            curFilter: $currentFilter,
                            filterIsOn: $filterIsOn,
                            thought: thought,
                            message: thought.message,
                            likeCount: thought.likes,
                            screenHeight: gps.screenSize.height,
                            startTime: thought.startDate,
                            endTime: thought.endDate
                        )
                    }
                }
                .zIndex(2.0)
                .clearSectionBackground()
                
                HStack {
                    
                    Toggle("Filter", isOn: $filterIsOn)
                        .foregroundColor(.white)
                    
                    FilterStringPicker(strings: filters, selectedString: $currentFilter)
                        .frame(height: 150)
                    
                }
                .padding()
                .frame(width: filterIsOn ? 350 : 100, height: 75)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundColor(Color.black.opacity(1))
                        .shadow(radius: 5)
                )
                .position(gps.getCoordinate(for: .bottomLeft, offsetX: filterIsOn ? 200 : 75, offsetY: 125))
                
                ChatView() { m in
                    currentMessage = m
                }
                .clearSectionBackground()
                .zIndex(10.0)
                .position(gps.getCoordinate(for: .bottomCenter, offsetY: keyboardIsShowing ? (keyboardHeight + 50) : 50))
                
            }
            .frame(width: gps.screenSize.width, height: gps.screenSize.height)
            .background(StarryNightAnimatedView())
            .onAppear() {
                self.thoughtsObserver.startObserving()
            }
            
        }
        .onChange(of: self.deviceState) { newScenePhase in
            switch newScenePhase {
                case .active:
                    print("App is in foreground")
                    self.thoughtsObserver.startObserving()
                case .inactive:
                    print("App is inactive")
                case .background:
                    print("App is in background")
                    self.thoughtsObserver.stopObserving()
                @unknown default:
                    print("A new case was added that we're not handling")
            }
        }
        .keyboardListener(
            onAppear: { height in
                print("Keyboard appeared with height: \(height)")
                keyboardHeight = height
                keyboardIsShowing = true
            },
            onDisappear: { height in
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


