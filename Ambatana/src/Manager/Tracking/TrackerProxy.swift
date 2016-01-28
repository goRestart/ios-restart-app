//
//  TrackerProxy.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import CoreLocation

public class TrackerProxy: Tracker {

    // Constants
    // TODO : uncomment GANTracker once is working
    // Amplitude must be initiated before OptimizelyTracker or the integration between them won't work
    private static let defaultTrackers: [Tracker] = [AmplitudeTracker(), AppsflyerTracker(), FacebookTracker(),
        GoogleConversionTracker(), NanigansTracker(), KahunaTracker(), OptimizelyTracker(), CrashlyticsTracker(),
        GANTracker(), AdjustTracker()]

    // iVars
    public var trackers: [Tracker] = []

    public static let sharedInstance = TrackerProxy()

    public init(trackers: [Tracker] = TrackerProxy.defaultTrackers) {
        self.trackers = trackers

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateCoordinatesFromNotification:",
            name: LocationManager.Notification.LocationUpdate.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionUpdate:",
            name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionUpdate:",
            name: SessionManager.Notification.Logout.rawValue, object: nil)
    }

    // MARK: - Tracker

    public func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
            for tracker in trackers {
                tracker.application(application, didFinishLaunchingWithOptions: launchOptions)
            }
    }

    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
        annotation: AnyObject?) {
            for tracker in trackers {
                tracker.application(application, openURL: url, sourceApplication: sourceApplication,
                    annotation: annotation)
            }
    }

    public func applicationDidEnterBackground(application: UIApplication) {
        for tracker in trackers {
            tracker.applicationDidEnterBackground(application)
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

    public func setUser(user: MyUser?) {
        for tracker in trackers {
            tracker.setUser(user)
        }
    }

    public func trackEvent(event: TrackerEvent) {
        for tracker in trackers {
            tracker.trackEvent(event)
        }
    }

    public func updateCoordinates() {
        for tracker in trackers {
            tracker.updateCoordinates()
        }
    }

    // MARK: private methods

    private dynamic func updateCoordinatesFromNotification(notification: NSNotification) {
        updateCoordinates()
    }

    private dynamic func sessionUpdate(_: NSNotification) {
        let myUser = Core.myUserRepository.myUser
        setUser(myUser)
    }
}
