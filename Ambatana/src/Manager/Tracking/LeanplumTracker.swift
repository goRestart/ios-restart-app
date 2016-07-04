//
//  LeanplumTracker.swift
//  LetGo
//
//  Created by Eli Kohen on 04/07/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import Taplytics

final class LeanplumTracker: Tracker {

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
        guard let installationId = installation?.objectId else { return }
        Leanplum.setDeviceId(installationId)
    }

    func setUser(user: MyUser?) {
        guard let userId = user?.objectId else { return }
        Leanplum.setUserId(userId)

        //TODO ADD USER ATTRIBUTES
    }

    func trackEvent(event: TrackerEvent) {

    }

    func setLocation(location: LGLocation?) {}

    func setNotificationsPermission(enabled: Bool) {}
    
    func setGPSPermission(enabled: Bool) {}
}
