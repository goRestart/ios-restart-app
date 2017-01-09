//
//  AppsFlyerTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import AppsFlyerLib
import LGCoreKit

fileprivate extension TrackerEvent {
    var shouldTrack: Bool {
        get {
            switch name {
            case .firstMessage, .productMarkAsSold, .productSellStart, .productSellComplete,
                 .productSellComplete24h, .commercializerStart, .commercializerComplete:
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
    
    // MARK: - Tracker
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
        AppsFlyerTracker.shared().appsFlyerDevKey = EnvironmentProxy.sharedInstance.appsFlyerAPIKey
        AppsFlyerTracker.shared().appleAppID = EnvironmentProxy.sharedInstance.appleAppId
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        AppsFlyerTracker.shared().trackAppLaunch()
    }

    func setInstallation(_ installation: Installation?) {
        let installationId = installation?.objectId ?? ""
        AppsFlyerTracker.shared().customerUserID = installationId
    }

    func setUser(_ user: MyUser?) {
        guard let user = user else { return }

        let tracker = AppsFlyerTracker.shared()
        if let email = user.email {
            tracker?.setUserEmails([email], with: EmailCryptTypeSHA1)
        }
        tracker?.trackEvent("af_user_status", withValues: ["ui_status": "login"])
    }
    
    func trackEvent(_ event: TrackerEvent) {
        let tracker = AppsFlyerTracker.shared()
        if event.shouldTrack {
            tracker?.trackEvent(event.actualName, withValues: event.params?.stringKeyParams)
        }
        if event.shouldTrackRegisteredUIAchievement {
            tracker?.trackEvent(AFEventAchievementUnlocked, withValues: ["ui_achievement": "registered"])
        }
    }

    func setLocation(_ location: LGLocation?) {}
    func setNotificationsPermission(_ enabled: Bool) {}
    func setGPSPermission(_ enabled: Bool) {}
    func setMarketingNotifications(_ enabled: Bool) {}
}
