//
//  Date+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 20/04/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

extension Date {

    func formattedTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        if isToday {
            dateFormatter.dateStyle = .none
        } else {
            dateFormatter.dateStyle = .short
        }
        dateFormatter.locale = Locale.autoupdatingCurrent
        return dateFormatter.string(from: self)
    }

    var isToday: Bool {
        return Calendar.current.isDateInToday(self)
    }

    /**
     Returns a string with the seconds, minutes, hours, days, weeks ago (or + 1 month)
     
     - parameter shortForm: selects how it must be written (ex: shortform -> "1 m" vs longform -> "a minute ago" )
                            (shortForm doesn't use seconds, it begins at 1 m)
     - returns: string with the propper format
     */

    func relativeTimeString(_ shortForm: Bool) -> String {

        let time = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970

        let seconds = now - time
        let minutes = round(seconds/60)
        let hours = round(minutes/60)
        let days = round(hours/24)
        let weeks = round(days/7)

        if seconds < 10 {
            return shortForm ? LGLocalizedString.commonShortTimeMinutesAgoLabel(1) :
                LGLocalizedString.commonTimeNowLabel
        } else if seconds < 60 {
            // less than 1 minute
            return shortForm ? LGLocalizedString.commonShortTimeMinutesAgoLabel(1) :
                LGLocalizedString.commonTimeSecondsAgoLabel(Int(seconds))
        } else if seconds < 3600 {
            // less than 1 hour
            if minutes == 1 {
                return shortForm ? LGLocalizedString.commonShortTimeMinutesAgoLabel(Int(minutes)) :
                    LGLocalizedString.commonTimeAMinuteAgoLabel
            } else {
                return shortForm ? LGLocalizedString.commonShortTimeMinutesAgoLabel(Int(minutes)) :
                    LGLocalizedString.commonTimeMinutesAgoLabel(Int(minutes))
            }
        } else if seconds < 86400 {
            // less than 1 day
            if hours == 1 {
                return shortForm ? LGLocalizedString.commonShortTimeHoursAgoLabel(Int(hours)) :
                    LGLocalizedString.commonTimeHourAgoLabel
            } else {
                return shortForm ? LGLocalizedString.commonShortTimeHoursAgoLabel(Int(hours)) :
                    LGLocalizedString.commonTimeHoursAgoLabel(Int(hours))
            }
        } else if seconds < 604800 {
            // less than 1 week
            if days == 1 {
                return shortForm ? LGLocalizedString.commonShortTimeDayAgoLabel(Int(days)) :
                    LGLocalizedString.commonTimeDayAgoLabel
            } else {
                return shortForm ? LGLocalizedString.commonShortTimeDaysAgoLabel(Int(days)) :
                    LGLocalizedString.commonTimeDaysAgoLabel(Int(days))
            }
        } else if seconds <= 2419200 {
            // less than 4 weeks
            if weeks == 1 {
                return shortForm ? LGLocalizedString.commonShortTimeWeekAgoLabel(Int(weeks)) :
                    LGLocalizedString.commonTimeWeekAgoLabel
            } else {
                return shortForm ? LGLocalizedString.commonShortTimeWeeksAgoLabel(Int(weeks)) :
                    LGLocalizedString.commonTimeWeeksAgoLabel(Int(weeks))
            }
        }
        // more than 4 weeks -> + 1 month
        return shortForm ? LGLocalizedString.commonShortTimeMoreThanOneMonthAgoLabel :
            LGLocalizedString.commonTimeMoreThanOneMonthAgoLabel
    }

    /**
     Gives a string showing how many minutes or hours have passed since date

     - parameter date: the date since to count the time

     - returns: A string with format "1m", "45m", "1h", "24h", "1500h"
     */
    func simpleTimeStringForDate() -> String {

        let time = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970

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

    func productsBubbleInfoText(_ maxMonthsAgo: Int) -> String {

        let time = timeIntervalSince1970
        let now = Date().timeIntervalSince1970

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

    func isFromLast24h() -> Bool {
        return isNewerThan(86400)
    }

    func isNewerThan(_ seconds: TimeInterval) -> Bool {
        let time = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        return (now-time) < seconds
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
}
