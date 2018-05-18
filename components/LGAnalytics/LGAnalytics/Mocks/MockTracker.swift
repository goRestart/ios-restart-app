//
//  MockTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

@testable import LGComponents
import LGCoreKit

class MockTracker: Tracker {
    weak var application: AnalyticsApplication?
    var didFinishLaunchingWithOptionsBlock: ((Tracker) -> ())?
    var didBecomeActiveBlock: ((Tracker) -> ())?
    var setUserBlock: ((Tracker) -> ())?
    var setInstallationBlock: ((Tracker) -> ())?
    var trackEventBlock: ((Tracker) -> ())?
    var setLocationBlock: ((Tracker) -> ())?
    var setNotificationsPermissionBlock: ((Tracker) -> ())?
    var setGPSPermissionBlock: ((Tracker) -> ())?
    var setMarketingNotificationsBlock: ((Tracker) -> ())?
    var setABTestsBlock: ((Tracker) -> ())?

    var trackedEvents: [TrackerEvent] = []


    // MARK: - Tracker
    
    func applicationDidFinishLaunching(launchOptions: [String: Any]?,
                                       apiKeys: AnalyticsAPIKeys) {
        didFinishLaunchingWithOptionsBlock?(self)
    }
    
    func applicationDidBecomeActive() {
        didBecomeActiveBlock?(self)
    }

    func setInstallation(_ installation: Installation?) {
        setInstallationBlock?(self)
    }

    func setUser(_ user: MyUser?) {
        setUserBlock?(self)
    }
    
    func trackEvent(_ event: TrackerEvent) {
        trackedEvents.append(event)
        trackEventBlock?(self)
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {
        setLocationBlock?(self)
    }

    func setNotificationsPermission(_ enabled: Bool) {
        setNotificationsPermissionBlock?(self)
    }

    func setGPSPermission(_ enabled: Bool) {
        setGPSPermissionBlock?(self)
    }

    func setMarketingNotifications(_ enabled: Bool) {
        setMarketingNotificationsBlock?(self)
    }

    func setABTests(_ abTests: [AnalyticsABTestUserProperty]) {
        setABTestsBlock?(self)
    }
}
