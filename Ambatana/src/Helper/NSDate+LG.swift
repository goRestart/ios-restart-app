//
//  NSDate+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 20/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension NSDate {
    func relativeTimeString() -> String {

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
            return LGLocalizedString.commonTimeSecondsAgoLabel(Int(seconds))
        }

        if minutes < 60 {
            if minutes == 1 {
                return LGLocalizedString.commonTimeAMinuteAgoLabel
            } else {
                return LGLocalizedString.commonTimeMinutesAgoLabel(Int(minutes))
            }
        }

        if hours < 24 {
            if hours == 1 {
                return LGLocalizedString.commonTimeHourAgoLabel
            } else {
                return LGLocalizedString.commonTimeHoursAgoLabel(Int(hours))
            }
        }

        if days < 7 {
            if days == 1 {
                return LGLocalizedString.commonTimeDayAgoLabel
            } else {
                return LGLocalizedString.commonTimeDaysAgoLabel(Int(days))
            }
        }

        if weeks <= 4 {
            if weeks == 1 {
                return LGLocalizedString.commonTimeWeekAgoLabel
            } else {
                return LGLocalizedString.commonTimeWeeksAgoLabel(Int(weeks))
            }
        }

        return LGLocalizedString.commonTimeMoreThanOneMonthAgoLabel
    }

    /**
     Gives a string showing how many minutes or hours have passed since date

     - parameter date: the date since to count the time

     - returns: A string with format "1m", "45m", "1h", "24h", "1500h"
     */
    func simpleTimeStringForDate() -> String {

        let time = self.timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970

        let seconds = Float(now - time)

        let second: Float = 1
        let minute: Float = 60.0
        let hour: Float = minute * 60.0

        let minsAgo = min(round(seconds/minute), 59) // min() to avoid having labels with 60min
        let hoursAgo = round(seconds/hour)

        switch seconds {
        case second..<hour:
            return String(format: LGLocalizedString.productListItemTimeMinuteLabel, Int(minsAgo))
        default:
            return String(format: LGLocalizedString.productListItemTimeHourLabel, Int(hoursAgo))
        }
    }

    func productsBubbleInfoText(maxMonthsAgo: Int) -> String {

        let time = timeIntervalSince1970
        let now = NSDate().timeIntervalSince1970

        let seconds = Float(now - time)

        let second: Float = 1
        let minute: Float = 60.0
        let hour: Float = minute * 60.0
        let hourEnd: Float = hour + hour/2 + 1
        let day: Float = hour * 24.0
        let dayEnd: Float = day + day/2 + 1
        let month: Float = day * 30.0
        let monthEnd: Float = month + month/2 + 1

        let minsAgo = round(seconds/minute)
        let hoursAgo = round(seconds/hour)
        let daysAgo = round(seconds/day)
        let monthsAgo = round(seconds/month)

        switch seconds {
        case second..<minute, minute:
            return LGLocalizedString.productDateOneMinuteAgo
        case minute..<hour:
            return String(format: LGLocalizedString.productDateXMinutesAgo, Int(minsAgo))
        case hour..<hourEnd:
            return LGLocalizedString.productDateOneHourAgo
        case hourEnd..<day:
            return String(format: LGLocalizedString.productDateXHoursAgo, Int(hoursAgo))
        case day..<dayEnd:
            return LGLocalizedString.productDateOneDayAgo
        case dayEnd..<month:
            return String(format: LGLocalizedString.productDateXDaysAgo, Int(daysAgo))
        case month..<monthEnd:
            return LGLocalizedString.productDateOneMonthAgo
        case monthEnd..<month*Float(maxMonthsAgo):
            return String(format: LGLocalizedString.productDateXMonthsAgo, Int(monthsAgo))
        default:
            return String(format: LGLocalizedString.productDateMoreThanXMonthsAgo, maxMonthsAgo)
        }
    }
}
