//
//  ChatView.swift
//  Ohana
//
//  Created by Charles Romeo on 12/7/23.
//

import Foundation
import SwiftUI
import Combine
import RealmSwift


struct ChatView: View {
    var callback: (String) -> Void

    @State var cancellables = Set<AnyCancellable>()
    
    @State private var messageText: String = ""
    @State private var messages: [String] = []
    
    @State private var timeInts: [Int] = Array(1...60)
    @State private var currentTimeInt = 1
    @State private var currentTimeString = "Minutes"
    @State private var timeStrings: [String] = ["Seconds", "Minutes", "Hours", "Days", "Weeks", "Months", "Years"]
    
    @State var showTimePicker: Bool = false
    
    @State var hintText = "Share a thought..."

    var body: some View {
        
        VStack {
            
            if self.showTimePicker {
                HStack {
                    // Horizontal ScrollView for filter chips
                    Spacer()
                    VStack {
                        HStack {
                            FilterIntPicker(numbers: timeInts, selectedNumber: $currentTimeInt)
                                .frame(width: 100)
                            FilterStringPicker(strings: timeStrings, selectedString: $currentTimeString)
                                .frame(width: 200)
                        }
                        Spacer()
                        
                        Text("Your thought will fall for \(currentTimeInt) \(currentTimeString)")
                            .foregroundColor(Color.blue)
                        
                        Spacer()
                        
                        HStack {
                            Text("Confirm Time & Send")
                                .padding(8)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .onTapGesture {
                                    sendMessage()
                                }
                            
                            Spacer()
                            
                            Text("Cancel")
                                .padding(8)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .onTapGesture {
                                    showTimePicker = false
                                }
                        }.padding()
                        
                        
                        Spacer()
                        
                    }.background(
                        RoundedRectangle(cornerRadius: 15)
                            .foregroundColor(Color.black.opacity(0.45))
                            .shadow(radius: 5)
                    )
                    .frame(width: 300, height: 200)
                    .padding(.leading)
                    .padding(.trailing)
                }
            }
            

            HStack {
                TextField(hintText, text: $messageText, onEditingChanged: { isEditing in
                    if !isEditing {
                        
                    }
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())

                Button(action: {
                    
                    if messageText.isEmpty {
                        hintText = "Please express a thought!"
                        return
                    }
                    
                    showTimePicker = true
                }) {
                    Text("Send")
                        .padding(8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .opacity(showTimePicker ? 0 : 1)
                }
            }
            .padding(.trailing)
            .padding(.leading)
            .padding(.bottom)
        }
        
    }

    func sendMessage() {
        
        // Create a Realm instance
//        let realm = try! Realm()

        // Calculate start and end times
        let startTime = Date()
        let endTime = Calendar.current.date(byAdding: stringToCalendarComponent(currentTimeString), value: currentTimeInt, to: startTime)!

        // Create a Thought object
        let newThought = Thought(message: messageText, startTime: startTime.timeIntervalSince1970, endTime: endTime.timeIntervalSince1970)
        
        firebaseDatabase { db in
            db.save(collection: "thoughts", id: newThought.id, obj: newThought)
        }
        
//        try! realm.write {
//            realm.create(Thought.self, value: newThought, update: .all)
//        }
        
        showTimePicker = false
        messageText = ""
    }
}

struct FilterChipString: View {
    @State var timeString: String
    @Binding var currentString: String
    @State var action: (String) -> Void

    var body: some View {
        Text(timeString)
            .padding(8)
            .background(timeString == currentString ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .onTapGesture {
                action(timeString)
            }
    }
}

struct FilterChipInt: View {
    @State var timeInt: Int
    @Binding var currentTimeInt: Int
    @State var action: (Int) -> Void

    var body: some View {
        Text(String(timeInt))
            .padding(8)
            .background(timeInt == currentTimeInt ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(10)
            .onTapGesture {
                action(timeInt)
            }
    }
}
struct FilterStringPicker: View {
    @State var strings: [String]
    @Binding var selectedString: String

    init(strings: [String], selectedString: Binding<String>) {
        self.strings = strings
        self._selectedString = selectedString
    }

    var body: some View {
        Picker(selection: $selectedString, label: Text("Select a Period")) {
            ForEach(strings, id: \.self) { number in
                Text("\(number)").tag(number)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.2)))
        .padding()
    }
}
struct FilterIntPicker: View {
    @State var numbers: [Int]
    @Binding var selectedNumber: Int

    init(numbers: [Int], selectedNumber: Binding<Int>) {
        self.numbers = numbers
        self._selectedNumber = selectedNumber
    }

    var body: some View {
        Picker(selection: $selectedNumber, label: Text("Select a Number")) {
            ForEach(numbers, id: \.self) { number in
                Text("\(number)").tag(number)
            }
        }
        .pickerStyle(WheelPickerStyle())
        .background(RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2)))
        .padding()
    }
}

func stringToCalendarComponent(_ timeString: String) -> Calendar.Component {
    switch timeString {
    case "Seconds":
        return .second
    case "Minutes":
        return .minute
    case "Hours":
        return .hour
    case "Days":
        return .day
    case "Weeks":
        return .weekOfYear
    case "Months":
        return .month
    case "Years":
        return .year
    default:
        return .minute
    }
}
