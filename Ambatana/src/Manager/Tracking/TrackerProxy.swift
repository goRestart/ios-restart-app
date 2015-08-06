//
//  TrackerProxy.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class TrackerProxy: Tracker {
    
    var trackers: [Tracker] = []
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        for tracker in trackers {
            tracker.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        for tracker in trackers {
            tracker.applicationDidBecomeActive(application)
        }
    }
    
    public func setUser(user: User) {
        for tracker in trackers {
            tracker.setUser(user)
        }
    }
    
    public func trackEvent(event: TrackerEvent) {
        for tracker in trackers {
            tracker.trackEvent(event)
        }
    }
}
