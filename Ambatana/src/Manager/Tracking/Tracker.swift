//
//  Tracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

protocol Tracker {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?)
    func applicationDidEnterBackground(_ application: UIApplication)
    func applicationWillEnterForeground(_ application: UIApplication)
    func applicationDidBecomeActive(_ application: UIApplication)
    func setInstallation(_ installation: Installation?)
    func setUser(_ user: MyUser?)
    func trackEvent(_ event: TrackerEvent)
    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?)
    func setNotificationsPermission(_ enabled: Bool)
    func setGPSPermission(_ enabled: Bool)
    func setMarketingNotifications(_ enabled: Bool)
}
