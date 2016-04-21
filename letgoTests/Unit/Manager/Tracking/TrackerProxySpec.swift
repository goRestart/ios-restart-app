@testable import LetGo
import LGCoreKit
import Quick
import Nimble

class TrackerProxySpec: QuickSpec {
    override func spec() {
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

        describe("Tracker protocol proxying") {
            it("redirects to each tracker application:didFinishLaunchingWithOptions:") {
                var flags = [false, false, false]
                tracker1.didFinishLaunchingWithOptionsBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.didFinishLaunchingWithOptionsBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.didFinishLaunchingWithOptionsBlock = { (tracker: Tracker) in flags[2] = true }
                
                sut.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker application:openURL:sourceApplication:annotation:)") {
                var flags = [false, false, false]
                tracker1.openURLBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.openURLBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.openURLBlock = { (tracker: Tracker) in flags[2] = true }
                
                sut.application(UIApplication.sharedApplication(), openURL: NSURL(string: "http://www.google.com")!, sourceApplication: nil, annotation: nil)
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker applicationWillEnterForeground:") {
                var flags = [false, false, false]
                tracker1.willEnterForegroundBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.willEnterForegroundBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.willEnterForegroundBlock = { (tracker: Tracker) in flags[2] = true }
                
                sut.applicationWillEnterForeground(UIApplication.sharedApplication())
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker applicationDidBecomeActive:") {
                var flags = [false, false, false]
                tracker1.didBecomeActiveBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.didBecomeActiveBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.didBecomeActiveBlock = { (tracker: Tracker) in flags[2] = true }
                
                sut.applicationDidBecomeActive(UIApplication.sharedApplication())
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker setInstallation:") {
                var flags = [false, false, false]
                tracker1.setInstallationBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.setInstallationBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.setInstallationBlock = { (tracker: Tracker) in flags[2] = true }

                sut.setInstallation(MockInstallation())
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker setUser:") {
                var flags = [false, false, false]
                tracker1.setUserBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.setUserBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.setUserBlock = { (tracker: Tracker) in flags[2] = true }
                
                sut.setUser(MockUser())
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker trackEvent:") {
                var flags = [false, false, false]
                tracker1.trackEventBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.trackEventBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.trackEventBlock = { (tracker: Tracker) in flags[2] = true }
                
                sut.trackEvent(TrackerEvent.logout())
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker updateCoords:") {
                var flags = [false, false, false]
                tracker1.updateCoordsBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.updateCoordsBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.updateCoordsBlock = { (tracker: Tracker) in flags[2] = true }
                
                sut.setLocation(nil)
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker notificationsPermissionChanged:") {
                var flags = [false, false, false]
                tracker1.notificationsPermissionChangedBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.notificationsPermissionChangedBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.notificationsPermissionChangedBlock = { (tracker: Tracker) in flags[2] = true }

                sut.setNotificationsPermission(true)
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
            it("redirects to each tracker gpsPermissionChanged:") {
                var flags = [false, false, false]
                tracker1.gpsPermissionChangedBlock = { (tracker: Tracker) in flags[0] = true }
                tracker2.gpsPermissionChangedBlock = { (tracker: Tracker) in flags[1] = true }
                tracker3.gpsPermissionChangedBlock = { (tracker: Tracker) in flags[2] = true }

                sut.setGPSPermission(true)
                for flag in flags {
                    expect(flag).to(beTrue())
                }
            }
        }
    }
}
