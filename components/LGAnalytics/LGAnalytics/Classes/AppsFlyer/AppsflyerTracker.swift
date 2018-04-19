//
//  AppsFlyerTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
//

import AppsFlyerLib
import LGCoreKit

fileprivate extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .loginFB, .loginEmail, .loginGoogle, .signupEmail, .firstMessage,
                 .listingMarkAsSold, .listingSellStart, .listingSellComplete, .listingSellComplete24h:
                return true
            default:
                return false
            }
        }
    }

    // Criteo: https://ambatana.atlassian.net/browse/ABIOS-1966 (2)
    var shouldTrackRegisteredUIAchievement: Bool {
        get {
            switch name {
            case .loginFB, .loginGoogle, .signupEmail:
                return true
            default:
                return false
            }
        }
    }
}

final class AppsflyerTracker: Tracker {
    private var tracker: AppsFlyerTracker {
        return AppsFlyerTracker.shared()
    }


    // MARK: - Tracker

    weak var application: AnalyticsApplication?

    func applicationDidFinishLaunching(launchOptions: [String: Any]?,
                                       apiKeys: AnalyticsAPIKeys) {
        tracker.appsFlyerDevKey = apiKeys.appsFlyerAPIKey
        tracker.appleAppID = apiKeys.appsFlyerAppleAppId
        tracker.appInviteOneLinkID = apiKeys.appsFlyerAppInviteOneLinkID
    }
    
    func applicationDidBecomeActive() {
        tracker.trackAppLaunch()
    }

    func setInstallation(_ installation: Installation?) {
        let installationId = installation?.objectId ?? ""
        tracker.customerUserID = installationId
    }

    func setUser(_ user: MyUser?) {
        guard let user = user else { return }

        if let email = user.email {
            tracker.setUserEmails([email], with: EmailCryptTypeSHA1)
        }
        tracker.trackEvent("af_user_status", withValues: ["ui_status": "login"])
    }
    
    func trackEvent(_ event: TrackerEvent) {
        if event.shouldTrack {
            tracker.trackEvent(event.actualName, withValues: event.params?.stringKeyParams)
        }
        if event.shouldTrackRegisteredUIAchievement {
            tracker.trackEvent(AFEventAchievementUnlocked, withValues: ["ui_achievement": "registered"])
        }
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) { }
    func setNotificationsPermission(_ enabled: Bool) {}
    func setGPSPermission(_ enabled: Bool) {}
    func setMarketingNotifications(_ enabled: Bool) {}
    func setABTests(_ abTests: [AnalyticsABTestUserProperty]) {}
}
