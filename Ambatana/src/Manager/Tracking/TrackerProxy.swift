//
//  TrackerProxy.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

final class TrackerProxy: Tracker {
    private static let defaultTrackers: [Tracker] = [AmplitudeTracker(), AppsflyerTracker(), FacebookTracker(),
                                                     CrashlyticsTracker(), LeanplumTracker()]

    static let sharedInstance = TrackerProxy()

    private let disposeBag = DisposeBag()
    private var trackers: [Tracker] = []

    private var notificationsPermissionEnabled: Bool {
        return UIApplication.sharedApplication().areRemoteNotificationsEnabled
    }

    private var gpsPermissionEnabled: Bool {
       return Core.locationManager.locationServiceStatus == .Enabled(.Authorized)
    }

    private var installation: Installation? {
        return Core.installationRepository.installation
    }

    private var myUser: MyUser? {
        guard Core.sessionManager.loggedIn else { return nil }
        return Core.myUserRepository.myUser
    }

    private var currentLocation: LGLocation? {
        return Core.locationManager.currentLocation
    }


    // MARK: - Lifecycle

    init(trackers: [Tracker] = TrackerProxy.defaultTrackers) {
        self.trackers = trackers

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationUpdate),
            name: LocationManager.Notification.LocationUpdate.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionUpdate),
            name: SessionManager.Notification.Login.rawValue, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(sessionUpdate),
            name: SessionManager.Notification.Logout.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(installationCreate),
            name: InstallationRepository.Notification.Create.rawValue, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(locationManagerDidChangeAuthorization),
            name: LocationManager.Notification.LocationDidChangeAuthorization.rawValue, object: nil)
    }


    // MARK: - Tracker

    func application(application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) {
            trackers.forEach { $0.application(application, didFinishLaunchingWithOptions: launchOptions) }

        setInstallation(Core.installationRepository.installation)
        setUser(Core.myUserRepository.myUser)
        setGPSPermission(gpsPermissionEnabled)
        setNotificationsPermission(notificationsPermissionEnabled)
        setupMktNotificationsRx()
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?,
        annotation: AnyObject?) {
            trackers.forEach {
                $0.application(application, openURL: url, sourceApplication: sourceApplication,
                annotation: annotation)
            }
    }

    func applicationDidEnterBackground(application: UIApplication) {
        trackers.forEach { $0.applicationDidEnterBackground(application) }
    }

    func applicationWillEnterForeground(application: UIApplication) {
        trackers.forEach { $0.applicationWillEnterForeground(application) }
        setGPSPermission(gpsPermissionEnabled)
        setNotificationsPermission(notificationsPermissionEnabled)
    }

    func applicationDidBecomeActive(application: UIApplication) {
        trackers.forEach { $0.applicationDidBecomeActive(application) }
    }

    func setInstallation(installation: Installation?) {
        trackers.forEach { $0.setInstallation(installation) }
    }

    func setUser(user: MyUser?) {
        trackers.forEach { $0.setUser(user) }
    }

    func trackEvent(event: TrackerEvent) {
        logMessage(.Verbose, type: .Tracking, message: "\(event.actualName) -> \(event.params)")
        trackers.forEach { $0.trackEvent(event) }
    }

    func setLocation(location: LGLocation?) {
        trackers.forEach { $0.setLocation(location) }
    }

    func setNotificationsPermission(enabled: Bool) {
        trackers.forEach { $0.setNotificationsPermission(enabled) }
    }

    func setGPSPermission(enabled: Bool) {
        trackers.forEach { $0.setGPSPermission(enabled) }
    }

    func setMarketingNotifications(enabled: Bool) {
        trackers.forEach { $0.setMarketingNotifications(enabled) }
    }

    // MARK: Private methods

    private dynamic func locationUpdate() {
        setLocation(currentLocation)
    }

    private dynamic func sessionUpdate() {
        setUser(myUser)
    }

    private dynamic func installationCreate() {
        setInstallation(installation)
    }

    private dynamic func locationManagerDidChangeAuthorization() {
        setGPSPermission(gpsPermissionEnabled)

        if gpsPermissionEnabled {
            trackEvent(TrackerEvent.permissionSystemComplete(.Location, typePage: .ProductList))
        } else {
            trackEvent(TrackerEvent.permissionSystemCancel(.Location, typePage: .ProductList))
        }
    }

    private func setupMktNotificationsRx() {
        NotificationsManager.sharedInstance.loggedInMktNofitications.bindNext { [weak self] enabled in
            self?.setMarketingNotifications(enabled)
        }.addDisposableTo(disposeBag)
    }
}
