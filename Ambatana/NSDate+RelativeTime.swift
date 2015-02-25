//
//  NSDate+RelativeTime.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 11/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

extension NSDate {
    
    func relativeTimeToString() -> String
    {
        let time = self.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970
        
        let seconds = now - time
        let minutes = round(seconds/60)
        let hours = round(minutes/60)
        let days = round(hours/24)
        let weeks = round(days/7)

        //println("Date: \(self) --> seconds: \(seconds), minutes: \(minutes), hours: \(hours), days: \(days)")
        
        if seconds < 10 {
            return translate("just_now")
        } else if seconds < 60 {
            return translateWithFormat("x_seconds_ago", [Int(seconds)])
        }
        
        if minutes < 60 {
            if minutes == 1 {
                return translate("a_minute_ago")
            } else {
                return translateWithFormat("x_minutes_ago", [Int(minutes)])
            }
        }
        
        if hours < 24 {
            if hours == 1 {
                return translate("an_hour_ago")
            } else {
                return translateWithFormat("x_hours_ago", [Int(hours)])
            }
        }
        
        if days < 7 {
            if days == 1 {
                return translate("a_day_ago")
            } else {
                return translateWithFormat("x_days_ago", [Int(days)])
            }
        }
        
        if weeks < 4 {
            if weeks == 1 {
                return translate("a_week_ago")
            } else {
                return translateWithFormat("x_weeks_ago", [Int(days)])
            }
        }
        
        return translate("more_than_a_month_ago")
    }
}
