//
//  FacebookTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
//

import FBSDKCoreKit
import LGCoreKit

fileprivate extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .listingSellStart, .listingSellComplete, .firstMessage, .listingMarkAsSold, .listingEditComplete:
                return true
            default:
                return false
            }
        }
    }
}

final class FacebookTracker: Tracker {


    // MARK: - Tracker

    weak var application: AnalyticsApplication?

    func applicationDidFinishLaunching(launchOptions: [String: Any]?,
                                       apiKeys: AnalyticsAPIKeys) {
    }
    
    func applicationDidBecomeActive() {
        FBSDKAppEvents.activateApp()
        FBSDKAppLinkUtility.fetchDeferredAppLink { [weak application] (url, _) in
            guard let url = url else { return }
            application?.open(url: url,
                              options: [:],
                              completion: nil)
        }
    }

    func setInstallation(_ installation: Installation?) {
    }

    func setUser(_ user: MyUser?) {
    }
    
    func trackEvent(_ event: TrackerEvent) {
        if event.shouldTrack {
            FBSDKAppEvents.logEvent(event.actualName, parameters: event.params?.stringKeyParams)
        }
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {}
    func setNotificationsPermission(_ enabled: Bool) {}
    func setGPSPermission(_ enabled: Bool) {}
    func setMarketingNotifications(_ enabled: Bool) {}
    func setABTests(_ abTests: [AnalyticsABTestUserProperty]) {}
}
