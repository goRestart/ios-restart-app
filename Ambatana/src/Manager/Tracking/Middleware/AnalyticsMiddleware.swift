protocol AnalyticsMiddleware {
    func process(event: TrackerEvent, trackNewEvent: (TrackerEvent) -> ())
}
