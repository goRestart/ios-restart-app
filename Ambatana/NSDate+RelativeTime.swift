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
            return LGLocalizedString.commonTimeNowLabel
        } else if seconds < 60 {
            return String(format: LGLocalizedString.commonTimeSecondsAgoLabel, Int(seconds))
        }
        
        if minutes < 60 {
            if minutes == 1 {
                return LGLocalizedString.commonTimeAMinuteAgoLabel
            } else {
                return String(format: LGLocalizedString.commonTimeMinutesAgoLabel, Int(minutes))
            }
        }
        
        if hours < 24 {
            if hours == 1 {
                return LGLocalizedString.commonTimeHourAgoLabel
            } else {
                return String(format: LGLocalizedString.commonTimeHoursAgoLabel, Int(hours))
            }
        }
        
        if days < 7 {
            if days == 1 {
                return LGLocalizedString.commonTimeDayAgoLabel
            } else {
                return String(format: LGLocalizedString.commonTimeDaysAgoLabel, Int(days))
            }
        }
        
        if weeks <= 4 {
            if weeks == 1 {
                return LGLocalizedString.commonTimeWeekAgoLabel
            } else {
                return String(format: LGLocalizedString.commonTimeWeeksAgoLabel, Int(weeks))
            }
        }
        
        return LGLocalizedString.commonTimeMoreThanOneMonthAgoLabel
    }
}
