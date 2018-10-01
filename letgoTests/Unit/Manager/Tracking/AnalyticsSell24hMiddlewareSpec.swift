@testable import LetGoGodMode
import LGCoreKit
import Nimble
import Quick

final class AnalyticsSell24hMiddlewareSpec: QuickSpec {
    override func spec() {
        describe("AnalyticsSell24hMiddleware") {
            var listing: Listing!
            var listingSellCompleteEvent: TrackerEvent!
            var tracker: MockTracker!
            var keyValueStorage: MockKeyValueStorage!
            var sut: AnalyticsSell24hMiddleware!

            beforeEach {
                listing = Listing.makeMock()
                let machineLearningTrackingInfo = MachineLearningTrackingInfo.defaultValues()
                listingSellCompleteEvent = TrackerEvent.listingSellComplete(listing,
                                                                            buttonName: nil,
                                                                            sellButtonPosition: nil,
                                                                            negotiable: nil,
                                                                            pictureSource: nil,
                                                                            videoLength: nil,
                                                                            freePostingModeAllowed: false,
                                                                            typePage: .sell,
                                                                            machineLearningTrackingInfo: machineLearningTrackingInfo)
                tracker = MockTracker()
                keyValueStorage = MockKeyValueStorage()
                keyValueStorage.currentUserProperties = UserDefaultsUser()
                sut = AnalyticsSell24hMiddleware(keyValueStorage: keyValueStorage)
            }

            describe("process listing sell complete event") {
                context("when first run date is before 24h and did not track a sell 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(minutes: 1))
                        keyValueStorage.userTrackingProductSellComplete24hTracked = false
                        sut.process(event: listingSellCompleteEvent,
                                    trackNewEvent: tracker.trackEvent)
                    }
                    it("calls back to track a listing sell complete event 24h") {
                        expect(tracker.trackedEvents[0].name) == .listingSellComplete24h
                    }
                    it("calls back to track an event with same listing id as sell complete one") {
                        expect(tracker.trackedEvents[0].params?[.listingId] as? String) == listing.objectId
                    }
                    it("updates userTrackingProductSellComplete24hTracked") {
                        expect(keyValueStorage.userTrackingProductSellComplete24hTracked) == true
                    }
                }

                context("when first run date is after 24h and did not track a sell 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(days: 2))
                        keyValueStorage.userTrackingProductSellComplete24hTracked = false
                        sut.process(event: listingSellCompleteEvent,
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
                        sut.process(event: listingSellCompleteEvent,
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
                        sut.process(event: listingSellCompleteEvent,
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

