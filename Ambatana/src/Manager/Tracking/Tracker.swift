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
    func applicationDidBecomeActive(application: UIApplication)
    func setUser(user: User)
    func trackEvent(event: TrackerEvent)
}
