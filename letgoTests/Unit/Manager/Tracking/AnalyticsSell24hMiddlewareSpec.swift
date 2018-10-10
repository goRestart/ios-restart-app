@testable import LetGoGodMode
import LGCoreKit
import Nimble
import Quick

final class AnalyticsSell24hMiddlewareSpec: QuickSpec {
    override func spec() {
        describe("AnalyticsSell24hMiddleware") {
            var tracker: MockTracker!
            var keyValueStorage: MockKeyValueStorage!
            var sut: AnalyticsSell24hMiddleware!

            beforeEach {
                tracker = MockTracker()
                keyValueStorage = MockKeyValueStorage()
                keyValueStorage.currentUserProperties = UserDefaultsUser()
                sut = AnalyticsSell24hMiddleware(keyValueStorage: keyValueStorage)
            }

            describe("process listing sell complete event") {
                var event: TrackerEvent!
                beforeEach {
                    let listing = Listing.makeMock()
                    let machineLearningTrackingInfo = MachineLearningTrackingInfo.defaultValues()
                    event = TrackerEvent.listingSellComplete(listing,
                                                             buttonName: nil,
                                                             sellButtonPosition: nil,
                                                             negotiable: nil,
                                                             pictureSource: nil,
                                                             videoLength: nil,
                                                             typePage: .sell,
                                                             machineLearningTrackingInfo: machineLearningTrackingInfo)
                }

                context("when first run date is before 24h and did not track a sell 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(minutes: 1))
                        keyValueStorage.userTrackingProductSellComplete24hTracked = false
                        sut.process(event: event,
                                    trackNewEvent: tracker.trackEvent)
                    }
                    it("calls back to track a lister 24h event") {
                        expect(tracker.trackedEvents[0].name) == .lister24h
                    }
                    it("calls back to track an event with same params as the event that originated this one") {
                        expect(tracker.trackedEvents[0].params?.params.keys) == event.params?.params.keys
                    }
                    it("updates userTrackingProductSellComplete24hTracked") {
                        expect(keyValueStorage.userTrackingProductSellComplete24hTracked) == true
                    }
                }

                context("when first run date is after 24h and did not track a sell 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(days: 2))
                        keyValueStorage.userTrackingProductSellComplete24hTracked = false
                        sut.process(event: event,
                                    trackNewEvent: tracker.trackEvent)
                    }
                    it("does not call back to track any event") {
                        expect(tracker.trackedEvents).to(beEmpty())
                    }
                }

                context("when first run date is before 24h and did track a sell 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(minutes: 1))
                        keyValueStorage.userTrackingProductSellComplete24hTracked = true
                        sut.process(event: event,
                                    trackNewEvent: tracker.trackEvent)
                    }
                    it("does not call back to track any event") {
                        expect(tracker.trackedEvents).to(beEmpty())
                    }
                }

                context("when first run date is after 24h and did track a sell 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(days: 2))
                        keyValueStorage.userTrackingProductSellComplete24hTracked = true
                        sut.process(event: event,
                                    trackNewEvent: tracker.trackEvent)
                    }
                    it("does not call back to track any event") {
                        expect(tracker.trackedEvents).to(beEmpty())
                    }
                }
            }
        }
    }
}
