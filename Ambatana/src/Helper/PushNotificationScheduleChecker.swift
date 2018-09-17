import Foundation

private let hoursInDay = 24

struct PushNotificationScheduleChecker {
    let startingHour: Int
    let endingHour: Int
    
    private static func normalise(hour: Int) -> Int {
        return min(hoursInDay - 1, max(0, hour))
    }
    
    init(startingHour start: Int, endingHour end: Int) {
        self.startingHour = PushNotificationScheduleChecker.normalise(hour: start)
        self.endingHour = PushNotificationScheduleChecker.normalise(hour: end)
    }
    
    func mutePushNotification(at hour: Int = Int(Calendar.current.component(.hour, from: Date()))) -> Bool {
        guard startingHour != endingHour else { return false }
        if startingHour < endingHour {
            return (startingHour..<endingHour).contains(hour)
        } else {
            return (startingHour..<hoursInDay).contains(hour) || (0..<endingHour).contains(hour)
        }
    }
}
