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
    // Amplitude must be initiated before OptimizelyTracker or the integration between them won't work
    private static let defaultTrackers: [Tracker] = [AmplitudeTracker(), AppsflyerTracker(), FacebookTracker(),
        GoogleConversionTracker(), NanigansTracker(), KahunaTracker(), OptimizelyTracker(), CrashlyticsTracker(),
        GANTracker(), AdjustTracker()]

    public static let sharedInstance = TrackerProxy()
    public var trackers: [Tracker] = []


    // MARK: - Lifecycle

    public init(trackers: [Tracker] = TrackerProxy.defaultTrackers) {
        self.trackers = trackers

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdate:",
            name: LocationManager.Notification.LocationUpdate.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionUpdate:",
            name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "sessionUpdate:",
            name: SessionManager.Notification.Logout.rawValue, object: nil)
    }


    // MARK: - Tracker

    public func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
            trackers.forEach { $0.application(application, didFinishLaunchingWithOptions: launchOptions) }
    }

    public func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
        annotation: AnyObject?) {
            trackers.forEach {
                $0.application(application, openURL: url, sourceApplication: sourceApplication,
                annotation: annotation)
            }
    }

    public func applicationDidEnterBackground(application: UIApplication) {
        trackers.forEach { $0.applicationDidEnterBackground(application) }
    }

    public func applicationWillEnterForeground(application: UIApplication) {
        trackers.forEach { $0.applicationWillEnterForeground(application) }
    }

    public func applicationDidBecomeActive(application: UIApplication) {
        trackers.forEach { $0.applicationDidBecomeActive(application) }
    }

    public func setUser(user: MyUser?) {
        trackers.forEach { $0.setUser(user) }
    }

    public func trackEvent(event: TrackerEvent) {
        trackers.forEach { $0.trackEvent(event) }
    }

    public func updateCoordinates() {
        trackers.forEach { $0.updateCoordinates() }
    }


    // MARK: Private methods

    private dynamic func locationUpdate(_: NSNotification) {
        updateCoordinates()
    }

    private dynamic func sessionUpdate(_: NSNotification) {
        let myUser = Core.myUserRepository.myUser
        setUser(myUser)
    }
}
