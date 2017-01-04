//
//  Tracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol Tracker {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?)
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject?)
    func applicationDidEnterBackground(_ application: UIApplication)
    func applicationWillEnterForeground(_ application: UIApplication)
    func applicationDidBecomeActive(_ application: UIApplication)
    func setInstallation(_ installation: Installation?)
    func setUser(_ user: MyUser?)
    func trackEvent(_ event: TrackerEvent)
    func setLocation(_ location: LGLocation?)
    func setNotificationsPermission(_ enabled: Bool)
    func setGPSPermission(_ enabled: Bool)
    func setMarketingNotifications(_ enabled: Bool)
}
