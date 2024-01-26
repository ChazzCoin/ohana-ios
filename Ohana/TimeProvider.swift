//
//  TimeProvider.swift
//  Ohana
//
//  Created by Charles Romeo on 1/3/24.
//

import Foundation

enum TimeUnit {
    case minutes
    case hours
    case days
}

extension TimeInterval {
 
    func toDouble() -> Double {
        return Double(self)
    }
}

//func isDaytime() -> Bool {
//    let currentHour = Calendar.current.component(.hour, from: Date())
//    return currentHour < 16
//}

func isDaytime() -> Bool {
    let currentHour = Calendar.current.component(.hour, from: Date())
    return currentHour >= 7 && currentHour < 16
}


func futureTimestamp(after value: Int, unit: TimeUnit) -> TimeInterval {
    let now = Date()
    var futureDate: Date

    switch unit {
    case .minutes:
        futureDate = Calendar.current.date(byAdding: .minute, value: value, to: now)!
    case .hours:
        futureDate = Calendar.current.date(byAdding: .hour, value: value, to: now)!
    case .days:
        futureDate = Calendar.current.date(byAdding: .day, value: value, to: now)!
    }

    return futureDate.timeIntervalSince1970
}


class TimeSelector {
    
    // Minute
    let ONE_MINUTE = Calendar.current.date(byAdding: .minute, value: 1, to: Date())!
    let FIVE_MINUTES = Calendar.current.date(byAdding: .minute, value: 5, to: Date())!
    static func minutesFromNow(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: Date())!
    }
    
    // Hour
    let ONE_HOUR = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    static func hoursFromNow(hours: Int) -> Date {
        return Calendar.current.date(byAdding: .hour, value: hours, to: Date())!
    }
    // Day
    let ONE_DAY = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    static func daysFromNow(days: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: days, to: Date())!
    }
    // Week
    let ONE_WEEK = Calendar.current.date(byAdding: .weekday, value: 1, to: Date())!
    // Month
    let ONE_MONTH = Calendar.current.date(byAdding: .month, value: 1, to: Date())!
    
}
