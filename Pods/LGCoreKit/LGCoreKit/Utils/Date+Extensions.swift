//
//  Date+Extensions.swift
//  LGCoreKit
//
//  Created by Nestor on 12/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

extension Date {
    
    /// Date creation for Chat (websockets).
    static func makeChatDate(millisecondsIntervalSince1970 milliseconds: Double?) -> Date? {
        guard let millisecondsValue = milliseconds else { return nil }
        let seconds = millisecondsValue/1000
        return Date(timeIntervalSince1970: seconds)
    }

    static func userCreationDateFrom(string: String?) -> Date? {
        guard let stringDate = string else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let date = formatter.date(from: stringDate)
        return date
    }

    static func userCreationStringFrom(date: Date?) -> String? {
        guard let creationDate = date else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        let creationDateString = formatter.string(from: creationDate)
        return creationDateString
    }
}
