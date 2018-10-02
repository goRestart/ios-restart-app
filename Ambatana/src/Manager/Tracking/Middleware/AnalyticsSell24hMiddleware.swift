import LGComponents
import LGCoreKit

struct AnalyticsSell24hMiddleware: AnalyticsMiddleware {
    private static let threshold = TimeInterval.make(days: 1)
    private let keyValueStorage: KeyValueStorageable


    // MARK: - Lifecycle

    init(keyValueStorage: KeyValueStorageable) {
        self.keyValueStorage = keyValueStorage
    }


    // MARK: - AnalyticsMiddleware

    func process(event: TrackerEvent,
                 trackNewEvent: (TrackerEvent) -> ()) {
        guard event.name == .listingSellComplete, let listingId = event.params?[.listingId] as? String else { return }
        guard let firstOpenDate = keyValueStorage[.firstRunDate],
            firstOpenDate.isNewerThan(seconds: AnalyticsSell24hMiddleware.threshold) &&
            !keyValueStorage.userTrackingProductSellComplete24hTracked else { return }
        keyValueStorage.userTrackingProductSellComplete24hTracked = true

        let event = TrackerEvent.listingSellComplete24h(listingId: listingId)
        trackNewEvent(event)
    }
}
