//
//  CrashlyticsTracker.swift
//  LetGo
//
//  Created by Dídac on 24/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import Crashlytics

final class CrashlyticsTracker: Tracker {
    
    // MARK: - Tracker
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject?) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func setInstallation(_ installation: Installation?) {
    }

    func setUser(_ user: MyUser?) {
        Crashlytics.sharedInstance().setUserEmail(user?.email)
        Crashlytics.sharedInstance().setUserIdentifier(user?.objectId)
        Crashlytics.sharedInstance().setUserName(user?.name)
    }
    

    func trackEvent(_ event: TrackerEvent) {
    }

    func setLocation(_ location: LGLocation?) {}
    func setNotificationsPermission(_ enabled: Bool) {}
    func setGPSPermission(_ enabled: Bool) {}
    func setMarketingNotifications(_ enabled: Bool) {}
}
