enum BumpUpTimerType {
    case oneDay
    case threeDays
    case sevenDays

    var isMultiDay: Bool {
        switch self {
        case .oneDay:
            return false
        case .threeDays, .sevenDays:
            return true
        }
    }
    var dotsCount: Int? {
        switch self {
        case .oneDay:
            return nil
        case .threeDays:
            return 3
        case .sevenDays:
            return 7
        }
    }
    var maxCountdown: TimeInterval {
        switch self {
        case .oneDay:
            return TimeInterval.make(days: 1)
        case .threeDays:
            return TimeInterval.make(days: 3)
        case .sevenDays:
            return TimeInterval.make(days: 7)
        }
    }

    func highlightedDotFor(timeRemaining: TimeInterval) -> Int? {
        guard let dotsCount = self.dotsCount else { return nil }
        switch self {
        case .oneDay:
            return nil
        case .threeDays, .sevenDays:
            let timeSectorSize = maxCountdown/Double(dotsCount)
            let timeSector = timeRemaining/timeSectorSize
            return Int(floor(timeSector))
        }
    }

    func textForTimeWith(timeLeft: TimeInterval) -> String? {
        guard let dotsCount = dotsCount else {
            return Int(timeLeft).secondsToPrettyCountdownFormat()
        }
        let rebumpPeriod = maxCountdown/Double(dotsCount)
        let timeLeftRemainder = timeLeft.truncatingRemainder(dividingBy: rebumpPeriod)
        return Int(timeLeftRemainder).secondsToPrettyCountdownFormat()
    }
}
