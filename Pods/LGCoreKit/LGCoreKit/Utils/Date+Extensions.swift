//
//  Date+Extensions.swift
//  LGCoreKit
//
//  Created by Nestor on 12/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

extension Date {

    static var dateFormatter: DateFormatter = DateFormatter()

    /// Date creation for Chat (websockets).
    static func makeChatDate(millisecondsIntervalSince1970 milliseconds: TimeInterval?) -> Date? {
        guard let millisecondsValue = milliseconds else { return nil }
        let seconds = millisecondsValue/1000
        return Date(timeIntervalSince1970: seconds)
    }
    
    func millisecondsSince1970() -> TimeInterval {
        return timeIntervalSince1970*1000
    }

    static func userCreationDateFrom(string: String?) -> Date? {
        guard let stringDate = string else { return nil }
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.date(from: stringDate)
        return date
    }

    static func userCreationStringFrom(date: Date?) -> String? {
        guard let creationDate = date else { return nil }
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let creationDateString = dateFormatter.string(from: creationDate)
        return creationDateString
    }
    
    func roundedMillisecondsSince1970() -> TimeInterval {
        return (timeIntervalSince1970 * 1000.0).rounded()
    }
    
    func nextYear() -> Int {
        return Calendar.current.component(.year, from: self) + 1
    }
}
