import LGCoreKit

final class AnalyticsBuySell24hMiddleware: AnalyticsMiddleware {
    private static let threshold = TimeInterval.make(days: 1)
    private let keyValueStorage: KeyValueStorageable


    // MARK: - Lifecycle

    init(keyValueStorage: KeyValueStorageable) {
        self.keyValueStorage = keyValueStorage
    }


    // MARK: - AnalyticsMiddleware

    func process(event: TrackerEvent,
                 trackNewEvent: (TrackerEvent) -> ()) {
        guard event.name == .listingSellComplete || event.name == .firstMessage else { return }
        guard let firstOpenDate = keyValueStorage[.firstRunDate],
            Date().timeIntervalSince(firstOpenDate) <= AnalyticsBuySell24hMiddleware.threshold &&
                !keyValueStorage.userTrackingProductBuySellComplete24hTracked else { return }
        keyValueStorage.userTrackingProductBuySellComplete24hTracked = true

//        let event = TrackerEvent.listingSellComplete24h(listingId: listingId)
//        trackNewEvent(event)
    }
}
