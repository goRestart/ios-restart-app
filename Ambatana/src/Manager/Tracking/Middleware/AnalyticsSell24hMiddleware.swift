import LGComponents
import LGCoreKit

struct AnalyticsSell24hMiddleware: AnalyticsMiddleware {
    private let threshold = TimeInterval.make(days: 1)
    private let keyValueStorage: KeyValueStorageable


    // MARK: - Lifecycle

    init(keyValueStorage: KeyValueStorageable) {
        self.keyValueStorage = keyValueStorage
    }


    // MARK: - AnalyticsMiddleware

    func process(event: TrackerEvent,
                 trackNewEvent: (TrackerEvent) -> ()) {
        guard event.name == .listingSellComplete else { return }
        guard let newEvent = TrackerEvent.lister24h(event: event),
            let firstOpenDate = keyValueStorage[.firstRunDate],
            firstOpenDate.isNewerThan(seconds: threshold) &&
                !keyValueStorage.userTrackingProductSellComplete24hTracked else { return }

        keyValueStorage.userTrackingProductSellComplete24hTracked = true
        trackNewEvent(newEvent)
    }
}
