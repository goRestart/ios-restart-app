@testable import LetGoGodMode
import LGCoreKit
import Nimble
import Quick

final class AnalyticsBuy24hMiddlewareSpec: QuickSpec {
    override func spec() {
        describe("AnalyticsBuy24hMiddleware") {
            var tracker: MockTracker!
            var keyValueStorage: MockKeyValueStorage!
            var sut: AnalyticsBuy24hMiddleware!

            beforeEach {
                tracker = MockTracker()
                keyValueStorage = MockKeyValueStorage()
                keyValueStorage.currentUserProperties = UserDefaultsUser()
                sut = AnalyticsBuy24hMiddleware(keyValueStorage: keyValueStorage)
            }

            describe("process listing first message event") {
                var event: TrackerEvent!
                beforeEach {
                    let listing = Listing.makeMock()
                    let sendMessageInfo = SendMessageTrackingInfo()
                        .set(listing: listing)
                        .set(messageType: .text)
                        .set(quickAnswerTypeParameter: nil)
                        .set(typePage: .listingDetail)
                        .set(isBumpedUp: .trueParameter)
                    event = TrackerEvent.firstMessage(info: sendMessageInfo,
                                                      listingVisitSource: .listingList,
                                                      feedPosition: .position(index:1),
                                                      sectionPosition: .none,
                                                      userBadge: .silver,
                                                      containsVideo: .trueParameter,
                                                      isProfessional: false,
                                                      sectionName: nil)
                }

                context("when first run date is before 24h and did not track a buyer 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(minutes: 1))
                        keyValueStorage.userTrackingProductBuyComplete24hTracked = false
                        sut.process(event: event,
                                    trackNewEvent: tracker.trackEvent)
                    }
                    it("calls back to track a buyer 24h event") {
                        expect(tracker.trackedEvents[0].name) == .buyer24h
                    }
                    it("calls back to track an event with same params as the event that originated this one") {
                        expect(tracker.trackedEvents[0].params?.params.keys) == event.params?.params.keys
                    }
                    it("updates userTrackingProductSellComplete24hTracked") {
                        expect(keyValueStorage.userTrackingProductBuyComplete24hTracked) == true
                    }
                }

                context("when first run date is after 24h and did not track a buyer 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(days: 2))
                        keyValueStorage.userTrackingProductBuyComplete24hTracked = false
                        sut.process(event: event,
                                    trackNewEvent: tracker.trackEvent)
                    }
                    it("does not call back to track any event") {
                        expect(tracker.trackedEvents).to(beEmpty())
                    }
                }

                context("when first run date is before 24h and did track a buyer 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(minutes: 1))
                        keyValueStorage.userTrackingProductBuyComplete24hTracked = true
                        sut.process(event: event,
                                    trackNewEvent: tracker.trackEvent)
                    }
                    it("does not call back to track any event") {
                        expect(tracker.trackedEvents).to(beEmpty())
                    }
                }

                context("when first run date is after 24h and did track a buyer 24h event") {
                    beforeEach {
                        keyValueStorage[.firstRunDate] = Date(timeIntervalSinceNow: -TimeInterval.make(days: 2))
                        keyValueStorage.userTrackingProductBuyComplete24hTracked = true
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
