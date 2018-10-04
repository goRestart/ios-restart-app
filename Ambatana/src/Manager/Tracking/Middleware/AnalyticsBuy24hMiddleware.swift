import LGCoreKit

struct AnalyticsBuy24hMiddleware: AnalyticsMiddleware {
    private let threshold = TimeInterval.make(days: 1)
    private let keyValueStorage: KeyValueStorageable


    // MARK: - Lifecycle

    init(keyValueStorage: KeyValueStorageable) {
        self.keyValueStorage = keyValueStorage
    }


    // MARK: - AnalyticsMiddleware

    func process(event: TrackerEvent,
                 trackNewEvent: (TrackerEvent) -> ()) {
        guard event.name == .firstMessage else { return }
        guard let newEvent = TrackerEvent.buyer24h(event: event),
            let firstOpenDate = keyValueStorage[.firstRunDate],
            firstOpenDate.isNewerThan(seconds: threshold) &&
                !keyValueStorage.userTrackingProductBuyComplete24hTracked else { return }

        keyValueStorage.userTrackingProductBuyComplete24hTracked = true
        trackNewEvent(newEvent)
    }
}
