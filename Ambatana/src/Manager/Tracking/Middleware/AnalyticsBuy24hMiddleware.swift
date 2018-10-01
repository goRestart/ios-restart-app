import LGCoreKit

final class AnalyticsBuy24hMiddleware: AnalyticsMiddleware {
    private static let threshold = TimeInterval.make(days: 1)
    private let keyValueStorage: KeyValueStorageable


    // MARK: - Lifecycle

    init(keyValueStorage: KeyValueStorageable) {
        self.keyValueStorage = keyValueStorage
    }


    // MARK: - AnalyticsMiddleware

    func process(event: TrackerEvent,
                 trackNewEvent: (TrackerEvent) -> ()) {
        guard event.name == .firstMessage else { return }
        guard let firstOpenDate = keyValueStorage[.firstRunDate],
            Date().timeIntervalSince(firstOpenDate) <= AnalyticsBuy24hMiddleware.threshold &&
                !keyValueStorage.userTrackingProductBuyComplete24hTracked else { return }
        keyValueStorage.userTrackingProductBuyComplete24hTracked = true

//        let event = TrackerEvent.listingSellComplete24h(listingId: listingId)
//        trackNewEvent(event)
    }
}
