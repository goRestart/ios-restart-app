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
    var willEnterForegroundBlock: (Tracker -> ())?
    var didBecomeActiveBlock: (Tracker -> ())?
    var setUserBlock: (Tracker -> ())?
    var trackEventBlock: (Tracker -> ())?
    
    // MARK: - Tracker
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        didFinishLaunchingWithOptionsBlock?(self)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        openURLBlock?(self)
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        willEnterForegroundBlock?(self)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        didBecomeActiveBlock?(self)
    }
    
    func setUser(user: User?) {
        setUserBlock?(self)
    }
    
    func trackEvent(event: TrackerEvent) {
        trackEventBlock?(self)
    }
    
    func updateCoordinates() {
        
    }
}