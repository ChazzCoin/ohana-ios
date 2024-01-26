//
//  EmojiProvider.swift
//  Ohana
//
//  Created by Charles Romeo on 12/7/23.
//

import Foundation
import SwiftUI

enum EmojiProvider: String, CaseIterable {
    case smile = "😊"
    case laugh = "😂"
    case heart = "❤️"
    case thumbsUp = "👍"
    case crying = "😢"
    case thinking = "🤔"
    // Add more emojis as needed
}

func emojiList() -> [String] {
    return EmojiProvider.allCases.map { $0.rawValue }
}

// SwiftUI View for the Emoji Picker
struct EmojiPicker: View {
    var onEmojiSelected: (EmojiProvider) -> Void
    
    var sWidth = UIScreen.main.bounds.width
    var sHeight = UIScreen.main.bounds.height

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(EmojiProvider.allCases, id: \.self) { emoji in
                    Text(emoji.rawValue)
                        .font(.largeTitle)
                        .padding(2)
                        .onTapGesture {
                            onEmojiSelected(emoji)
                        }
                }
            }
        }
        .frame(width: 300, height: 75)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .foregroundColor(Color(UIColor.systemBackground).opacity(0.8))
                .shadow(radius: 5)
        )
        .padding(.horizontal)
        .zIndex(20.0)
    }
}
