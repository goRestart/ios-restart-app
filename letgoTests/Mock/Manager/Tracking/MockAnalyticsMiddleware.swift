@testable import LetGoGodMode

final class MockAnalyticsMiddleware: AnalyticsMiddleware {
    var lastProcessedEvent: TrackerEvent?

    func process(event: TrackerEvent,
                 trackNewEvent: (TrackerEvent) -> ()) {
        self.lastProcessedEvent = event
    }
}
