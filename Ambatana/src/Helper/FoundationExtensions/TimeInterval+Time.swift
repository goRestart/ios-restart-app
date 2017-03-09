//
//  Double+Time.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

extension TimeInterval {
    static func makeMinute() -> TimeInterval {
        return 60
    }
    static func makeMinutes(_ count: Int) -> TimeInterval {
        return 60 * TimeInterval(count)
    }
    static func makeHour() -> TimeInterval {
        return 60 * 60
    }
    static func makeHours(_ count: Int) -> TimeInterval {
        return 60 * 60 * TimeInterval(count)
    }
    static func makeDay() -> TimeInterval {
        return 60 * 60 * 24
    }
    static func makeDays(_ count: Int) -> TimeInterval {
        return 60 * 60 * 24 * TimeInterval(count)
    }
}
