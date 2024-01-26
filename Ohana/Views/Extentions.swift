//
//  Extentions.swift
//  Ohana
//
//  Created by Charles Romeo on 1/25/24.
//

import Foundation
import SwiftUI

struct ClearBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.clear)
            .listRowBackground(Color.clear)
    }
}

extension View {
    func clearSectionBackground() -> some View {
        self.modifier(ClearBackgroundModifier())
    }
}
