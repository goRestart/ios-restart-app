import Foundation
import LGComponents

extension Date {
    
    enum DateDescriptor {
        static let maximumMinutesInAHour = 60
        static let maximumHoursInADay = 24
        static let maximumDaysInAWeek = 7
        static let maximumDaysInAMonth = 31
        static let maximumWeeksInAMonth = 5
    }

    private var secondsInADay: TimeInterval { return 86400 }

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
    
    var isYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
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
            return shortForm ? R.Strings.commonShortTimeMinutesAgoLabel(1) :
                R.Strings.commonTimeNowLabel
        } else if seconds < 60 {
            // less than 1 minute
            return shortForm ? R.Strings.commonShortTimeMinutesAgoLabel(1) :
                R.Strings.commonTimeSecondsAgoLabel(Int(seconds))
        } else if seconds < 3600 {
            // less than 1 hour
            if minutes == 1 {
                return shortForm ? R.Strings.commonShortTimeMinutesAgoLabel(Int(minutes)) :
                    R.Strings.commonTimeAMinuteAgoLabel
            } else {
                return shortForm ? R.Strings.commonShortTimeMinutesAgoLabel(Int(minutes)) :
                    R.Strings.commonTimeMinutesAgoLabel(Int(minutes))
            }
        } else if seconds < 86400 {
            // less than 1 day
            if hours == 1 {
                return shortForm ? R.Strings.commonShortTimeHoursAgoLabel(Int(hours)) :
                    R.Strings.commonTimeHourAgoLabel
            } else {
                return shortForm ? R.Strings.commonShortTimeHoursAgoLabel(Int(hours)) :
                    R.Strings.commonTimeHoursAgoLabel(Int(hours))
            }
        } else if seconds < 604800 {
            // less than 1 week
            if days == 1 {
                return shortForm ? R.Strings.commonShortTimeDayAgoLabel(Int(days)) :
                    R.Strings.commonTimeDayAgoLabel
            } else {
                return shortForm ? R.Strings.commonShortTimeDaysAgoLabel(Int(days)) :
                    R.Strings.commonTimeDaysAgoLabel(Int(days))
            }
        } else if seconds <= 2419200 {
            // less than 4 weeks
            if weeks == 1 {
                return shortForm ? R.Strings.commonShortTimeWeekAgoLabel(Int(weeks)) :
                    R.Strings.commonTimeWeekAgoLabel
            } else {
                return shortForm ? R.Strings.commonShortTimeWeeksAgoLabel(Int(weeks)) :
                    R.Strings.commonTimeWeeksAgoLabel(Int(weeks))
            }
        }
        // more than 4 weeks -> + 1 month
        return shortForm ? R.Strings.commonShortTimeMoreThanOneMonthAgoLabel :
            R.Strings.commonTimeMoreThanOneMonthAgoLabel
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
            return R.Strings.productListItemTimeMinuteLabel(Int(minsAgo))
        default:
            return R.Strings.productListItemTimeHourLabel(Int(hoursAgo))
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
            return R.Strings.productDateOneMinuteAgo
        case minute..<hour:
            return R.Strings.productDateXMinutesAgo(Int(minsAgo))
        case hour..<hourEnd:
            return R.Strings.productDateOneHourAgo
        case hourEnd..<day:
            return R.Strings.productDateXHoursAgo(Int(hoursAgo))
        case day..<dayEnd:
            return R.Strings.productDateOneDayAgo
        case dayEnd..<month:
            return R.Strings.productDateXDaysAgo(Int(daysAgo))
        case month..<monthEnd:
            return R.Strings.productDateOneMonthAgo
        case monthEnd..<month*Float(maxMonthsAgo):
            return R.Strings.productDateXMonthsAgo(Int(monthsAgo))
        default:
            return R.Strings.productDateMoreThanXMonthsAgo(maxMonthsAgo)
        }
    }

    func isFromLast24h() -> Bool {
        return isNewerThan(seconds: secondsInADay)
    }

    func isOlderThan(days: Double) -> Bool {
        return !isNewerThan(seconds: secondsInADay * days)
    }
    
    func isOlderThan(seconds: TimeInterval) -> Bool {
        return !isNewerThan(seconds: seconds)
    }

    func isNewerThan(seconds: TimeInterval) -> Bool {
        let time = self.timeIntervalSince1970
        let now = Date().timeIntervalSince1970
        return (now-time) < seconds
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    var nextYear: Int {
        return year + 1
    }
    
    var millisecondsSince1970: TimeInterval {
        return (self.timeIntervalSince1970 * 1000.0).rounded()
    }

    var isMeetingSafeTime: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour >= SharedConstants.minSafeHourForMeetings && hour <= SharedConstants.maxSafeHourForMeetings
    }

    func formattedForTracking() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return dateFormatter.string(from: self)
    }

    func prettyDateForMeeting() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "E d MMM"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: self)
    }

    func prettyTimeForMeeting() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a ZZZZ"
        formatter.timeZone = TimeZone.current
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }    
}
