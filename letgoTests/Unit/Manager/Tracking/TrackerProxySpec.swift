import LetGo
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
        
        describe("shared instance") {
            beforeEach {
                sut = TrackerProxy.sharedInstance
            }
            
            it("contains an Amplitude tracker") {
                var contained = false
                for tracker in sut.trackers {
                    if tracker is AmplitudeTracker {
                        contained = true
                    }
                }
                expect(contained).to(beTrue())
            }
            it("contains an Appsflyer tracker") {
                var contained = false
                for tracker in sut.trackers {
                    if tracker is AppsflyerTracker {
                        contained = true
                    }
                }
                expect(contained).to(beTrue())
            }
            it("contains an FacebookTracker tracker") {
                var contained = false
                for tracker in sut.trackers {
                    if tracker is FacebookTracker {
                        contained = true
                    }
                }
                expect(contained).to(beTrue())
            }
            it("contains an GoogleTracker tracker") {
                var contained = false
                for tracker in sut.trackers {
                    if tracker is GoogleTracker {
                        contained = true
                    }
                }
                expect(contained).to(beTrue())
            }
            it("contains an NanigansTracker tracker") {
                var contained = false
                for tracker in sut.trackers {
                    if tracker is NanigansTracker {
                        contained = true
                    }
                }
                expect(contained).to(beTrue())
            }
        }
        
        describe("initialization") {
            it("keeps track of the passed by trackers") {
                expect(sut.trackers.count).to(equal(3))
            }
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
        }
    }
}
