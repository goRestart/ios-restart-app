//
//  TrackerProxySpec.swift
//  LGAnalytics_Tests
//
//  Created by Albert Hernández López on 29/03/2018.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
//

@testable import LGComponents
import LGCoreKit
import Quick
import Nimble

class TrackerProxySpec: QuickSpec {
    override func spec() {
        describe("TrackerProxy") {
            var sut: TrackerProxy!
            var tracker1: MockTracker!
            var tracker2: MockTracker!
            var tracker3: MockTracker!
            var trackers: [Tracker]!

            beforeEach {
                tracker1 = MockTracker()
                tracker2 = MockTracker()
                tracker3 = MockTracker()
                trackers = [tracker1, tracker2, tracker3]
                sut = TrackerProxy(trackers: trackers)
            }

            describe("Tracker proxying") {
                var flags: [Bool]!
                beforeEach {
                    flags = [false, false, false]
                }

                describe("assign application variable") {
                    var application: MockAnalyticsApplication!
                    beforeEach {
                        application = MockAnalyticsApplication()
                        sut.application = application
                    }

                    it("assigns it into tracker1's application") {
                        expect(tracker1.application) === application
                    }

                    it("assigns it into tracker2's application") {
                        expect(tracker2.application) === application
                    }

                    it("assigns it into tracker3's application") {
                        expect(tracker3.application) === application
                    }
                }

                describe("applicationDidFinishLaunching") {
                    beforeEach {
                        tracker1.didFinishLaunchingWithOptionsBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.didFinishLaunchingWithOptionsBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.didFinishLaunchingWithOptionsBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.applicationDidFinishLaunching(launchOptions: nil,
                                                          apiKeys: MockAnalyticsAPIKeys())
                    }

                    it("forwards to each tracker's applicationDidFinishLaunching") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("applicationDidBecomeActive") {
                    beforeEach {
                        tracker1.didBecomeActiveBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.didBecomeActiveBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.didBecomeActiveBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.applicationDidBecomeActive()
                    }

                    it("forwards to each tracker's applicationDidBecomeActive") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("setUser") {
                    beforeEach {
                        tracker1.setUserBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.setUserBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.setUserBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.setUser(nil)
                    }

                    it("forwards to each tracker's setUser") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("setInstallation") {
                    beforeEach {
                        tracker1.setInstallationBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.setInstallationBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.setInstallationBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.setInstallation(nil)
                    }

                    it("forwards to each tracker's setInstallation") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("trackEvent") {
                    beforeEach {
                        tracker1.trackEventBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.trackEventBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.trackEventBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.trackEvent(TrackerEvent.logout())
                    }

                    it("forwards to each tracker's trackEvent") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("setLocation") {
                    beforeEach {
                        tracker1.setLocationBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.setLocationBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.setLocationBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.setLocation(nil,
                                        postalAddress: nil)
                    }

                    it("forwards to each tracker's setLocation") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("setNotificationsPermission") {
                    beforeEach {
                        tracker1.setNotificationsPermissionBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.setNotificationsPermissionBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.setNotificationsPermissionBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.setNotificationsPermission(true)
                    }

                    it("forwards to each tracker's setNotificationsPermission") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("setGPSPermission") {
                    beforeEach {
                        tracker1.setGPSPermissionBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.setGPSPermissionBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.setGPSPermissionBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.setGPSPermission(true)
                    }

                    it("forwards to each tracker's setGPSPermission") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("setMarketingNotifications") {
                    beforeEach {
                        tracker1.setMarketingNotificationsBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.setMarketingNotificationsBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.setMarketingNotificationsBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.setMarketingNotifications(true)
                    }

                    it("forwards to each tracker's setMarketingNotifications") {
                        expect(flags) == [true, true, true]
                    }
                }

                describe("setABTests") {
                    beforeEach {
                        tracker1.setABTestsBlock = { (tracker: Tracker) in flags[0] = true }
                        tracker2.setABTestsBlock = { (tracker: Tracker) in flags[1] = true }
                        tracker3.setABTestsBlock = { (tracker: Tracker) in flags[2] = true }
                        sut.setABTests([])
                    }

                    it("forwards to each tracker's setABTests") {
                        expect(flags) == [true, true, true]
                    }
                }
            }
        }
    }
}
