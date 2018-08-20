@testable import LetGoGodMode
import LGCoreKit
import Quick
import Nimble
import SwiftyUserDefaults

final class FeedBadgingSynchronizerSpec: QuickSpec {
    override func spec() {
        var sut: LGFeedBadgingSynchronizer!
        
        var locationManager: MockLocationManager!
        var listingRepository: MockListingRepository!
        var keyValueStorage: KeyValueStorage!
        var notificationsManager: MockNotificationsManager!
        
        describe("LGFeedBadgingSynchronizer") {
            beforeEach {
                locationManager = MockLocationManager()
                listingRepository = MockListingRepository.makeMock()
                keyValueStorage = KeyValueStorage()
                notificationsManager = MockNotificationsManager()
                
                
            }
            
            describe("retrieve recent listings") {
                var didExecuteCompletion: Bool!
                var result: [Listing]!
                let completion: (([Listing]) -> Void) = { r in
                    result = r
                    didExecuteCompletion = true
                }
                
                context("App icon badge is higher than 0") {
                    beforeEach {
                        sut = LGFeedBadgingSynchronizer(locationManager: locationManager,
                                                        listingRepository: listingRepository,
                                                        keyValueStorage: keyValueStorage,
                                                        notificationsManager: notificationsManager,
                                                        appIconBadgeNumber: Int.makeRandom())
                    }
                    
                    context("Last session date is higher than 1 hour from now") {
                        beforeEach {
                            didExecuteCompletion = false
                            result = nil
                            keyValueStorage[.lastSessionDate] = Date().addingTimeInterval(-TimeInterval.make(hours: 2))
                            sut.retrieveRecentListings(completion: completion)
                            expect(didExecuteCompletion).toEventually(beTrue())
                        }
                        it("executes completion") {
                            expect(didExecuteCompletion).toEventually(beTrue())
                        }
                        it("gives a value to result array") {
                            expect(result).toNot(beNil())
                        }
                    }
                    
                    context("Last session date is minor than 1 hour from now") {
                        beforeEach {
                            didExecuteCompletion = false
                            result = nil
                            keyValueStorage[.lastSessionDate] = Date().addingTimeInterval(-TimeInterval.make(minutes: 59))
                            sut.retrieveRecentListings(completion: completion)
                        }
                        it("does not execute completion") {
                            expect(didExecuteCompletion).toEventually(beFalse())
                        }
                        it("does not give a value to result array") {
                            expect(result).to(beNil())
                        }
                    }
                }
            
                context("App icon badge equals 0") {
                    beforeEach {
                        sut = LGFeedBadgingSynchronizer(locationManager: locationManager,
                                                        listingRepository: listingRepository,
                                                        keyValueStorage: keyValueStorage,
                                                        notificationsManager: notificationsManager,
                                                        appIconBadgeNumber: 0)
                    }
                    
                    context("Last session date is higher than 1 hour from now") {
                        beforeEach {
                            didExecuteCompletion = false
                            result = nil
                            keyValueStorage[.lastSessionDate] = Date().addingTimeInterval(-TimeInterval.make(hours: 2))
                            sut.retrieveRecentListings(completion: completion)
                        }
                        it("does not execute completion") {
                            expect(didExecuteCompletion).toEventually(beFalse())
                        }
                        it("does not give a value to result array") {
                            expect(result).to(beNil())
                        }
                    }
                    
                    context("Last session date is minor than 1 hour from now") {
                        beforeEach {
                            didExecuteCompletion = false
                            result = nil
                            keyValueStorage[.lastSessionDate] = Date().addingTimeInterval(-TimeInterval.make(minutes: 59))
                            sut.retrieveRecentListings(completion: completion)
                        }
                        it("does not execute completion") {
                            expect(didExecuteCompletion).toEventually(beFalse())
                        }
                        it("does not give a value to result array") {
                            expect(result).to(beNil())
                        }
                    }
                }
            }
        }
    }
}

