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
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
    }

    func setInstallation(installation: Installation?) {
    }

    func setUser(user: MyUser?) {
        Crashlytics.sharedInstance().setUserEmail(user?.email)
        Crashlytics.sharedInstance().setUserIdentifier(user?.objectId)
        Crashlytics.sharedInstance().setUserName(user?.name)
    }
    

    func trackEvent(event: TrackerEvent) {
    }

    func setLocation(location: LGLocation?) {}
    func setNotificationsPermission(enabled: Bool) {}
    func setGPSPermission(enabled: Bool) {}
    func setMarketingNotifications(enabled: Bool) {}
}
