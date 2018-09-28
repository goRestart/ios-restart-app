import LGCoreKit

final class AnalyticsSell24hMiddleware: AnalyticsMiddleware {
    private static let threshold = TimeInterval.make(days: 1)
    private let keyValueStorage: KeyValueStorageable


    // MARK: - Lifecycle

    init(keyValueStorage: KeyValueStorageable) {
        self.keyValueStorage = keyValueStorage
    }


    // MARK: - AnalyticsMiddleware

    func process(event: TrackerEvent,
                 trackNewEvent: (TrackerEvent) -> ()) {
        guard event.name == .listingSellComplete else { return }
        guard let firstOpenDate = keyValueStorage[.firstRunDate],
            Date().timeIntervalSince(firstOpenDate) <= AnalyticsSell24hMiddleware.threshold &&
            !keyValueStorage.userTrackingProductSellComplete24hTracked else { return }

        let listing = Listing.makeMock()
        let event = TrackerEvent.listingSellComplete24h(listing)
        trackNewEvent(event)
    }
}
