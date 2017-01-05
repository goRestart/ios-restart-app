//
//  MockTracker.swift
//  LetGo
//
//  Created by Albert Hernández López on 07/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit

class MockTracker: Tracker {
    
    var didFinishLaunchingWithOptionsBlock: (Tracker -> ())?
    var openURLBlock: (Tracker -> ())?
    var didEnterBackground: (Tracker -> ())?
    var willEnterForegroundBlock: (Tracker -> ())?
    var didBecomeActiveBlock: (Tracker -> ())?
    var setUserBlock: (Tracker -> ())?
    var setInstallationBlock: (Tracker -> ())?
    var trackEventBlock: (Tracker -> ())?
    var updateCoordsBlock: (Tracker -> ())?
    var notificationsPermissionChangedBlock: (Tracker -> ())?
    var gpsPermissionChangedBlock: (Tracker -> ())?
    var setMarketingNotificationsBlock: (Tracker -> ())?

    var trackedEvents: [TrackerEvent] = []


    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        didFinishLaunchingWithOptionsBlock?(self)
    }
    
    func application(application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: AnyObject?) {
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

    func setInstallation(installation: Installation?) {
        setInstallationBlock?(self)
    }

    func setUser(user: MyUser?) {
        setUserBlock?(self)
    }
    
    func trackEvent(event: TrackerEvent) {
        trackedEvents.append(event)
        trackEventBlock?(self)
    }

    func setLocation(location: LGLocation?) {
        updateCoordsBlock?(self)
    }

    func setNotificationsPermission(enabled: Bool) {
        notificationsPermissionChangedBlock?(self)
    }

    func setGPSPermission(enabled: Bool) {
        gpsPermissionChangedBlock?(self)
    }

    func setMarketingNotifications(enabled: Bool) {
        setMarketingNotificationsBlock?(self)
    }
}
