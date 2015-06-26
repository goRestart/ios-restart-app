//
//  NSDate+RelativeTime.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 11/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import UIKit

extension NSDate {
    
    func relativeTimeString() -> String
    {
        let time = self.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970
        
        let seconds = now - time
        let minutes = round(seconds/60)
        let hours = round(minutes/60)
        let days = round(hours/24)
        let weeks = round(days/7)

        if seconds < 10 {
            return NSLocalizedString("common_time_now_label", comment: "")
        } else if seconds < 60 {
            return String(format: NSLocalizedString("common_time_seconds_ago_label", comment: ""), Int(seconds))
        }
        
        if minutes < 60 {
            if minutes == 1 {
                return NSLocalizedString("common_time_a_minute_ago_label", comment: "")
            } else {
                return String(format: NSLocalizedString("common_time_minutes_ago_label", comment: ""), Int(minutes))
            }
        }
        
        if hours < 24 {
            if hours == 1 {
                return NSLocalizedString("common_time_hour_ago_label", comment: "")
            } else {
                return String(format: NSLocalizedString("common_time_hours_ago_label", comment: ""), Int(hours))
            }
        }
        
        if days < 7 {
            if days == 1 {
                return NSLocalizedString("common_time_day_ago_label", comment: "")
            } else {
                return String(format: NSLocalizedString("common_time_days_ago_label", comment: ""), Int(days))
            }
        }
        
        if weeks <= 4 {
            if weeks == 1 {
                return NSLocalizedString("common_time_week_ago_label", comment: "")
            } else {
                return String(format: NSLocalizedString("common_time_weeks_ago_label", comment: ""), Int(weeks))
            }
        }
        
        return NSLocalizedString("common_time_more_than_one_month_ago_label", comment: "")
    }
}
