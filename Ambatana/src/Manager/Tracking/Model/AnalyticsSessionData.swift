/* A session might be composed of several visits. If the visitor comes back to the site within that time period,
 it is still considered one user session */
struct AnalyticsSessionData {
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
        let newLenght = length + visitLength
        return AnalyticsSessionData(lastVisitEndDate: visitEndDate,
                                    length: newLenght)
    }
}
