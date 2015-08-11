//
//  TrackerProxy.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class TrackerProxy: Tracker {
    
    // Constants
    private static let defaultTrackers: [Tracker] = [AmplitudeTracker(), AppsflyerTracker(), FacebookTracker(), GoogleTracker()/*, NanigansTracker()*/]
    
    // iVars
    public var trackers: [Tracker] = []

    public static let sharedInstance = TrackerProxy()
    
    public init(trackers: [Tracker] = TrackerProxy.defaultTrackers) {
        self.trackers = trackers
    }
    
    // MARK: - Tracker
    
    public func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
        for tracker in trackers {
            tracker.application(application, didFinishLaunchingWithOptions: launchOptions)
        }
    }
    
    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) {
        for tracker in trackers {
            tracker.application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }
    
    public func applicationWillEnterForeground(application: UIApplication) {
        for tracker in trackers {
            tracker.applicationWillEnterForeground(application)
        }
    }
    
    public func applicationDidBecomeActive(application: UIApplication) {
        for tracker in trackers {
            tracker.applicationDidBecomeActive(application)
        }
    }
    
    public func setUser(user: User?) {
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
