final class AnalyticsSell24hMiddleware: AnalyticsMiddleware {
    private let keyValueStorage: KeyValueStorage


    // MARK: - Lifecycle

    init(keyValueStorage: KeyValueStorage) {
        self.keyValueStorage = keyValueStorage
    }


    // MARK: - AnalyticsMiddleware

    func process(event: TrackerEvent, trackNewEvent: (TrackerEvent) -> ()) {

    }
}
