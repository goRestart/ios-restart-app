//
//  Double+Time.swift
//  LetGo
//
//  Created by Eli Kohen on 09/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

extension TimeInterval {
    static func make(minutes: Int) -> TimeInterval {
        return 60 * TimeInterval(minutes)
    }
    static func make(hours: Int) -> TimeInterval {
        return 60 * 60 * TimeInterval(hours)
    }
    static func make(days: Int) -> TimeInterval {
        return 60 * 60 * 24 * TimeInterval(days)
    }
}
