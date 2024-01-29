//
//  Thought.swift
//  Ohana
//
//  Created by Charles Romeo on 1/24/24.
//

import RealmSwift
import Foundation

class Thought: Object, ObjectKeyIdentifiable {
    @Persisted(primaryKey: true) var id = UUID().uuidString
    @Persisted var message: String = ""
    @Persisted var category: String = "General"
    @Persisted var duration: TimeInterval = 0
    @Persisted var startTime: TimeInterval = Date().timeIntervalSince1970
    @Persisted var endTime: TimeInterval = Date().timeIntervalSince1970
    @Persisted var likes: Int = 0

    convenience init(message: String, startTime: TimeInterval, endTime: TimeInterval) {
        self.init()
        self.message = message
        self.startTime = startTime
        self.endTime = endTime
    }
    
    convenience init(message: String, duration: TimeInterval) {
        self.init()
        self.message = message
        self.duration = duration
    }
    
    var startDate: Date {
        return Date(timeIntervalSince1970: startTime)
    }

    var endDate: Date {
        return Date(timeIntervalSince1970: endTime)
    }
}
