//
//  CrashlyticsTracker.swift
//  LetGo
//
//  Created by Dídac on 24/11/15.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
//

import LGCoreKit
import Crashlytics

final class CrashlyticsTracker: Tracker {
    private var crashlytics: Crashlytics {
        return Crashlytics.sharedInstance()
    }

    
    // MARK: - Tracker

    weak var application: AnalyticsApplication?

    func applicationDidFinishLaunching(launchOptions: [String: Any]?,
                                       apiKeys: AnalyticsAPIKeys) {
    }
    
    func applicationDidBecomeActive() {
    }

    func setInstallation(_ installation: Installation?) {
    }

    func setUser(_ user: MyUser?) {
        crashlytics.setUserEmail(user?.email)
        crashlytics.setUserIdentifier(user?.objectId)
        crashlytics.setUserName(user?.name)
    }
    

    func trackEvent(_ event: TrackerEvent) {
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {}
    func setNotificationsPermission(_ enabled: Bool) {}
    func setGPSPermission(_ enabled: Bool) {}
    func setMarketingNotifications(_ enabled: Bool) {}
    func setABTests(_ abTests: [AnalyticsABTestUserProperty]) {}
}
