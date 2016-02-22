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
    private static let defaultTrackers: [Tracker] = [AmplitudeTracker(), AppsflyerTracker(), FacebookTracker(),
        GoogleConversionTracker(), NanigansTracker(), KahunaTracker(), CrashlyticsTracker(),
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

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "installationCreate:",
            name: InstallationRepository.Notification.Create.rawValue, object: nil)

        // TODO: For non-new installs, set the installation. This should be removed in the future.
        if let installation = Core.installationRepository.installation {
            setInstallation(installation)
        }
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

    public func setInstallation(installation: Installation) {
        trackers.forEach { $0.setInstallation(installation) }
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

    public func notificationsPermissionChanged() {
        trackers.forEach { $0.notificationsPermissionChanged() }
    }

    public func gpsPermissionChanged() {
        trackers.forEach { $0.gpsPermissionChanged() }
    }


    // MARK: Private methods

    private dynamic func locationUpdate(_: NSNotification) {
        updateCoordinates()
    }

    private dynamic func sessionUpdate(_: NSNotification) {
        let myUser = Core.myUserRepository.myUser
        setUser(myUser)
    }

    private dynamic func installationCreate(_: NSNotification) {
        guard let installation = Core.installationRepository.installation else { return }
        setInstallation(installation)
    }
}
