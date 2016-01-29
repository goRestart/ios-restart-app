//
//  Tracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public protocol Tracker {
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?)
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?)
    func applicationDidEnterBackground(application: UIApplication)
    func applicationWillEnterForeground(application: UIApplication)
    func applicationDidBecomeActive(application: UIApplication)
    func setUser(user: MyUser?)
    func trackEvent(event: TrackerEvent)
    func updateCoordinates()
    func notificationsPermissionChanged()
    func gpsPermissionChanged()
}
