//
//  MockTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LetGo
import LGCoreKit

internal class MockTracker: Tracker {
    
    var didFinishLaunchingWithOptionsBlock: (Tracker -> ())?
    var openURLBlock: (Tracker -> ())?
    var didEnterBackground: (Tracker -> ())?
    var willEnterForegroundBlock: (Tracker -> ())?
    var didBecomeActiveBlock: (Tracker -> ())?
    var setUserBlock: (Tracker -> ())?
    var trackEventBlock: (Tracker -> ())?
    var updateCoordsBlock: (Tracker -> ())?
    var notificationsPermissionChangedBlock: (Tracker -> ())?
    var gpsPermissionChangedBlock: (Tracker -> ())?

    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        didFinishLaunchingWithOptionsBlock?(self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        openURLBlock?(self)
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        didEnterBackground?(self)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        willEnterForegroundBlock?(self)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        didBecomeActiveBlock?(self)
    }
    
    func setUser(user: MyUser?) {
        setUserBlock?(self)
    }
    
    func trackEvent(event: TrackerEvent) {
        trackEventBlock?(self)
    }
    
    func updateCoordinates() {
        updateCoordsBlock?(self)
    }

    func notificationsPermissionChanged() {
        notificationsPermissionChangedBlock?(self)
    }

    func gpsPermissionChanged() {
        gpsPermissionChangedBlock?(self)
    }
}