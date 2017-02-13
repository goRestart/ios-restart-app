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
    private static let defaultTrackers: [Tracker] = {
        var trackers = [Tracker]()
        trackers.append(AmplitudeTracker())
        trackers.append(AppsflyerTracker())
        trackers.append(FacebookTracker())
        trackers.append(CrashlyticsTracker())
        trackers.append(LeanplumTracker())
        trackers.append(NewRelicTracker())
        return trackers
    }()

    static let sharedInstance = TrackerProxy()

    private let disposeBag = DisposeBag()
    private var trackers: [Tracker] = []

    private var notificationsPermissionEnabled: Bool {
        return UIApplication.shared.areRemoteNotificationsEnabled
    }

    private var gpsPermissionEnabled: Bool {
       return locationManager.locationServiceStatus == .enabled(.authorized)
    }

    private let locationManager: LocationManager
    private let sessionManager: SessionManager
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository
    private let notificationsManager: NotificationsManager


    // MARK: - Lifecycle

    convenience init() {
        self.init(trackers: TrackerProxy.defaultTrackers)
    }

    convenience init(trackers: [Tracker]) {
        self.init(trackers: trackers,
                  sessionManager: Core.sessionManager,
                  myUserRepository: Core.myUserRepository,
                  locationManager: Core.locationManager,
                  installationRepository: Core.installationRepository,
                  notificationsManager: LGNotificationsManager.sharedInstance)
    }

    init(trackers: [Tracker], sessionManager: SessionManager, myUserRepository: MyUserRepository,
         locationManager: LocationManager, installationRepository: InstallationRepository,
         notificationsManager: NotificationsManager) {
        self.trackers = trackers
        self.locationManager = locationManager
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        self.notificationsManager = notificationsManager
    }


    // MARK: - Tracker

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        trackers.forEach { $0.application(application, didFinishLaunchingWithOptions: launchOptions) }

        setGPSPermission(gpsPermissionEnabled)
        setNotificationsPermission(notificationsPermissionEnabled)
        setupEventsRx()
        setupMktNotificationsRx()
    }

    func application(_ application: UIApplication, openURL url: URL, sourceApplication: String?,
        annotation: Any?) {
            trackers.forEach {
                $0.application(application, openURL: url, sourceApplication: sourceApplication,
                annotation: annotation)
            }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        trackers.forEach { $0.applicationDidEnterBackground(application) }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        trackers.forEach { $0.applicationWillEnterForeground(application) }
        setGPSPermission(gpsPermissionEnabled)
        setNotificationsPermission(notificationsPermissionEnabled)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        trackers.forEach { $0.applicationDidBecomeActive(application) }
    }

    func setInstallation(_ installation: Installation?) {
        trackers.forEach { $0.setInstallation(installation) }
    }

    func setUser(_ user: MyUser?) {
        trackers.forEach { $0.setUser(user) }
    }

    func trackEvent(_ event: TrackerEvent) {
        logMessage(.verbose, type: .tracking, message: "\(event.actualName) -> \(event.params)")
        trackers.forEach { $0.trackEvent(event) }
    }

    func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {
        trackers.forEach { $0.setLocation(location, postalAddress: postalAddress) }
    }

    func setNotificationsPermission(_ enabled: Bool) {
        trackers.forEach { $0.setNotificationsPermission(enabled) }
    }

    func setGPSPermission(_ enabled: Bool) {
        trackers.forEach { $0.setGPSPermission(enabled) }
    }

    func setMarketingNotifications(_ enabled: Bool) {
        trackers.forEach { $0.setMarketingNotifications(enabled) }
    }

    // MARK: Private methods

    private func setupEventsRx() {
        myUserRepository.rx_myUser.bindNext { [weak self] myUser in
            let user = (self?.sessionManager.loggedIn ?? false) ? myUser : nil
            self?.setUser(user)
        }.addDisposableTo(disposeBag)

        installationRepository.rx_installation.bindNext { [weak self] installation in
            self?.setInstallation(installation)
        }.addDisposableTo(disposeBag)

        locationManager.locationEvents.bindNext { [weak self] event in
            switch event {
            case .changedPermissions:
                self?.locationManagerDidChangePermissions()
            case .locationUpdate:
                self?.setLocation(self?.locationManager.currentLocation, postalAddress: self?.locationManager.currentLocation?.postalAddress)
            case .movedFarFromSavedManualLocation:
                break
            }
        }.addDisposableTo(disposeBag)
    }

    private func locationManagerDidChangePermissions() {
        setGPSPermission(gpsPermissionEnabled)

        if gpsPermissionEnabled {
            trackEvent(TrackerEvent.permissionSystemComplete(.location, typePage: .productList))
        } else {
            trackEvent(TrackerEvent.permissionSystemCancel(.location, typePage: .productList))
        }
    }

    private func setupMktNotificationsRx() {
        notificationsManager.loggedInMktNofitications.asObservable().bindNext { [weak self] enabled in
            self?.setMarketingNotifications(enabled)
        }.addDisposableTo(disposeBag)
    }
}
