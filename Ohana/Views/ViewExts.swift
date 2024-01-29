//
//  ViewExts.swift
//  Ohana
//
//  Created by Charles Romeo on 1/26/24.
//

import Foundation
import SwiftUI

extension View {
    func onTap(perform action: @escaping () -> Void) -> some View {
        self.onTapGesture {
            // Perform the custom action
            action()
        }
    }
    
    func onDoubleTap(perform action: @escaping () -> Void) -> some View {
        self.gesture(TapGesture(count: 2).onEnded({ _ in
            print("Tapped double")
            action()
         }))
    }
    
    func onTapCount(count:Int, perform action: @escaping () -> Void) -> some View {
        self.gesture(TapGesture(count: count).onEnded({ _ in
            print("Tapped \(count) times")
            action()
         }))
    }
    
}
