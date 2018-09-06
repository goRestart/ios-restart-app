import Foundation

extension Date {

    static var dateFormatter: DateFormatter = DateFormatter()

    /// Date creation for Chat (websockets).
    static func makeChatDate(millisecondsIntervalSince1970 milliseconds: TimeInterval?) -> Date? {
        guard let millisecondsValue = milliseconds else { return nil }
        let seconds = millisecondsValue/1000
        return Date(timeIntervalSince1970: seconds)
    }
    
    func millisecondsSince1970() -> TimeInterval {
        return timeIntervalSince1970*1000
    }

    static func userCreationDateFrom(string: String?) -> Date? {
        guard let stringDate = string else { return nil }
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let date = dateFormatter.date(from: stringDate)
        return date
    }

    static func userCreationStringFrom(date: Date?) -> String? {
        guard let creationDate = date else { return nil }
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let creationDateString = dateFormatter.string(from: creationDate)
        return creationDateString
    }
    
    func roundedMillisecondsSince1970() -> TimeInterval {
        return (timeIntervalSince1970 * 1000.0).rounded()
    }
    
    /// Returns true if `days` have passed since
    func isOlderThan(days: Int) -> Bool {
        guard let dateInThePast = Calendar.current.date(byAdding: .day, value: -days, to: Date()) else {
            return false
        }
        return self < dateInThePast
    }

    func nextYear() -> Int {
        return Calendar.current.component(.year, from: self) + 1
    }
}
