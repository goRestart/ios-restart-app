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
    
    var didFinishLaunchingWithOptionsBlock: ((Tracker) -> ())?
    var openURLBlock: ((Tracker) -> ())?
    var didEnterBackground: ((Tracker) -> ())?
    var willEnterForegroundBlock: ((Tracker) -> ())?
    var didBecomeActiveBlock: ((Tracker) -> ())?
    var setUserBlock: ((Tracker) -> ())?
    var setInstallationBlock: ((Tracker) -> ())?
    var trackEventBlock: ((Tracker) -> ())?
    var updateCoordsBlock: ((Tracker) -> ())?
    var notificationsPermissionChangedBlock: ((Tracker) -> ())?
    var gpsPermissionChangedBlock: ((Tracker) -> ())?
    var setMarketingNotificationsBlock: ((Tracker) -> ())?

    var trackedEvents: [TrackerEvent] = []


    // MARK: - Tracker
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable: Any]?) {
        didFinishLaunchingWithOptionsBlock?(self)
    }
    
    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?, annotation: Any?) {
        openURLBlock?(self)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        didEnterBackground?(self)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        willEnterForegroundBlock?(self)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        didBecomeActiveBlock?(self)
    }

    func setInstallation(_ installation: Installation?) {
        setInstallationBlock?(self)
    }

    func setUser(_ user: MyUser?) {
        setUserBlock?(self)
    }
    
    func trackEvent(_ event: TrackerEvent) {
        trackedEvents.append(event)
        trackEventBlock?(self)
    }

    func setLocation(_ location: LGLocation?) {
        updateCoordsBlock?(self)
    }

    func setNotificationsPermission(_ enabled: Bool) {
        notificationsPermissionChangedBlock?(self)
    }

    func setGPSPermission(_ enabled: Bool) {
        gpsPermissionChangedBlock?(self)
    }

    func setMarketingNotifications(_ enabled: Bool) {
        setMarketingNotificationsBlock?(self)
    }
}
