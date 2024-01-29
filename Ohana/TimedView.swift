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
    @Binding var curFilter: String
    @Binding var filterIsOn: Bool
    @State var thought: Thought
    @State var message: String
    @State var likeCount: Int
    @State var screenHeight: CGFloat
    @State var startTime: Date
    @State var endTime: Date
    @State private var yOffset: CGFloat = 0
    @State private var xOffset = CGFloat.random(in: 100...UIScreen.main.bounds.width-100)
    @State private var fontSize = 14.0
    @State private var isVisible: Bool = true
    @State private var isEnabled: Bool = true
    @State private var fontColor: Color = isDaytime() ? Color.black : Color.white
    @State private var viewSize: CGSize = .zero  // Store the view size
    @State private var viewZIndex: CGFloat = CGFloat.random(in: 1.0...7.0)
    @State private var viewIsActive: Bool = false
    
    @State private var hasBeenLiked: Bool = false
    
    @StateObject var thoughtsObserver = FirebaseThoughtsService()
    
    private let moodGradients: [String: LinearGradient] = [
        "General": LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom),
        "Happy": LinearGradient(gradient: Gradient(colors: [.yellow, .orange]), startPoint: .top, endPoint: .bottom),
        "Sad": LinearGradient(gradient: Gradient(colors: [.blue, .gray]), startPoint: .top, endPoint: .bottom),
        "Angry": LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .top, endPoint: .bottom),
        "Anxious": LinearGradient(gradient: Gradient(colors: [.purple, .gray]), startPoint: .top, endPoint: .bottom),
        "Excited": LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom),
        "Grateful": LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .top, endPoint: .bottom),
        "Hopeful": LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .top, endPoint: .bottom),
        "Relaxed": LinearGradient(gradient: Gradient(colors: [.blue, .green]), startPoint: .top, endPoint: .bottom),
        "Stressed": LinearGradient(gradient: Gradient(colors: [.gray, .red]), startPoint: .top, endPoint: .bottom),
        "Confused": LinearGradient(gradient: Gradient(colors: [.purple, .pink]), startPoint: .top, endPoint: .bottom),
        "Disappointed": LinearGradient(gradient: Gradient(colors: [.gray, .black]), startPoint: .top, endPoint: .bottom),
        "Inspired": LinearGradient(gradient: Gradient(colors: [.pink, .orange]), startPoint: .top, endPoint: .bottom),
        "Lonely": LinearGradient(gradient: Gradient(colors: [.black, .blue]), startPoint: .top, endPoint: .bottom),
        "Proud": LinearGradient(gradient: Gradient(colors: [.purple, .red]), startPoint: .top, endPoint: .bottom),
        "Curious": LinearGradient(gradient: Gradient(colors: [.orange, .yellow]), startPoint: .top, endPoint: .bottom),
        "Frustrated": LinearGradient(gradient: Gradient(colors: [.red, .black]), startPoint: .top, endPoint: .bottom),
        "Amused": LinearGradient(gradient: Gradient(colors: [.green, .yellow]), startPoint: .top, endPoint: .bottom),
        "Overwhelmed": LinearGradient(gradient: Gradient(colors: [.red, .purple]), startPoint: .top, endPoint: .bottom),
        "Content": LinearGradient(gradient: Gradient(colors: [.gray, .white]), startPoint: .top, endPoint: .bottom)
    ]
    
    // Function to get gradient based on mood
    func getGradient(forMood mood: String) -> LinearGradient {
        moodGradients[mood] ?? LinearGradient(gradient: Gradient(colors: [.black, .white]), startPoint: .top, endPoint: .bottom)
    }
    
    var backgroundStyle: LinearGradient {
        return viewIsActive ? LinearGradient(
            gradient: Gradient(colors: [
                Color.gray.opacity(0.9),
                Color.gray,
                Color.gray.opacity(0.7)
            ]),
            startPoint: .top,
            endPoint: .bottom
        ) :
        getGradient(forMood: thought.category)
//        LinearGradient(gradient: Gradient(colors: [Color.white.opacity(0.4), Color.blue.opacity(0.1)]), startPoint: .top, endPoint: .bottom)
    }

       var body: some View {
           GeometryReader { geometry in
               ScrollView {
                   Text(message)
                       .font(.system(size: fontSize))
                       .foregroundColor(fontColor)
                       .padding()
                       .fixedSize(horizontal: false, vertical: true)
               }
               .background(backgroundStyle)
               .clipShape(ThoughtBubble())
               .cornerRadius(30)
               .shadow(radius: 5)
               .onAppear {
                   viewSize = geometry.size
                   calculateInitialPosition()
                   startAnimation()
               }
               
               // Like Badge
               Text("\(likeCount)")
                   .font(.caption)
                   .fontWeight(.bold)
                   .foregroundColor(.white)
                   .frame(width: 24, height: 24)
                   .background(Color.red)
                   .clipShape(Circle())
                   .offset(x: -10, y: -10)
           }
           .zIndex(viewZIndex)
           .frame(maxWidth: 150, maxHeight: 100)
           .opacity(isVisible && isEnabled ? 1 : 0)
           .position(x: xOffset, y: yOffset)
           .onChange(of: filterIsOn) { _ in
               if filterIsOn {
                   self.isEnabled = curFilter == thought.category
               } else {
                   self.isEnabled = true
               }
           }
           .onChange(of: curFilter) { newFilter in
               if filterIsOn {
                   self.isEnabled = newFilter == thought.category
               } else {
                   self.isEnabled = true
               }
           }
           .onTap {
               if viewIsActive {
                   viewZIndex = CGFloat.random(in: 1.0...7.0)
                   viewIsActive = false
               } else {
                   viewZIndex = 10.0
                   viewIsActive = true
               }
           }.simultaneousGesture(TapGesture(count: 2).onEnded({ _ in
               print("Tapped double")
               if hasBeenLiked { return }
               newRealm().safeWrite { r in
                   if let temp = thought.thaw() {
                       temp.likes = temp.likes + 1
                       firebaseDatabase { db in
                           db.save(collection: "thoughts", id: temp.id, obj: temp)
                       }
                   }
               }
               likeCount = likeCount + 1
               hasBeenLiked = true
            }))
           
           .onAppear {
               
               if let obj = newRealm().findByField(Thought.self, value: thought.id) {
                   likeCount = obj.likes
                   message = obj.message
               }
               
               thoughtsObserver.startObserving(id: thought.id) { obj in
                   likeCount = obj.likes
                   message = obj.message
               }
               
               likeCount = thought.likes
               xOffset = CGFloat.random(in: viewSize.width/2...UIScreen.main.bounds.width-viewSize.width/2)
           }
           .onDisappear() {
               thoughtsObserver.stopObserving()
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
//            firebaseDatabase { db in
//                db.child("thoughts").child(self.thought.id).removeValue()
//            }
        }
    }
}

struct ThoughtBubble: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: rect.width, height: rect.height), cornerSize: CGSize(width: 30, height: 30))
        path.addRoundedRect(in: CGRect(x: rect.width * 0.6, y: rect.height, width: 20, height: 20), cornerSize: CGSize(width: 10, height: 10))
        
        return path
    }
}
