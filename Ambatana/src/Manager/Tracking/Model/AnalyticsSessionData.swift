import LGCoreKit

/* A session might be composed of several visits. If the visitor comes back to the site within that time period,
 it is still considered one user session */
struct AnalyticsSessionData: Equatable {
    let lastVisitEndDate: Date
    let length: TimeInterval

    private init(lastVisitEndDate: Date,
                 length: TimeInterval) {
        self.lastVisitEndDate = lastVisitEndDate
        self.length = length
    }

    static func make(visitStartDate: Date,
                     visitEndDate: Date) -> AnalyticsSessionData {
        let visitLength = visitEndDate.timeIntervalSince1970 - visitStartDate.timeIntervalSince1970
        return AnalyticsSessionData(lastVisitEndDate: visitEndDate,
                                    length: visitLength)
    }

    func updating(visitStartDate: Date,
                  visitEndDate: Date) -> AnalyticsSessionData {
        let visitLength = visitEndDate.timeIntervalSince1970 - visitStartDate.timeIntervalSince1970
        let newLength = length + visitLength
        return AnalyticsSessionData(lastVisitEndDate: visitEndDate,
                                    length: newLength)
    }

    static func ==(lhs: AnalyticsSessionData, rhs: AnalyticsSessionData) -> Bool {
        return lhs.lastVisitEndDate == rhs.lastVisitEndDate &&
            lhs.length == rhs.length
    }
}

extension AnalyticsSessionData: UserDefaultsDecodable {
    private enum UserDefaultKey: String {
        case lastVisitEndDate, length
    }

    static func decode(_ dictionary: [String: Any]) -> AnalyticsSessionData? {
        guard let lastVisitEndDate = dictionary[UserDefaultKey.lastVisitEndDate.rawValue] as? Date,
            let length = dictionary[UserDefaultKey.length.rawValue] as? Double else { return nil }
        return AnalyticsSessionData(lastVisitEndDate: lastVisitEndDate,
                                    length: length)
    }

    func encode() -> [String: Any] {
        var dictionary = [String: Any]()
        dictionary[UserDefaultKey.lastVisitEndDate.rawValue] = lastVisitEndDate
        dictionary[UserDefaultKey.length.rawValue] = length
        return dictionary
    }
}

