//
//  TrackerProxy.swift
//  LetGo
//
//  Created by Albert Hernández López on 05/08/15.
//  Copyright © 2018 Ambatana B.V. Holdings. All rights reserved.
//

import LGCoreKit
import RxSwift

public final class TrackerProxy: Tracker {
    private static let defaultTrackers: [Tracker] = {
        var trackers = [Tracker]()
        trackers.append(AmplitudeTracker())
        trackers.append(AppsflyerTracker())
        trackers.append(FacebookTracker())
        trackers.append(CrashlyticsTracker())
        trackers.append(LeanplumTracker())
        return trackers
    }()

    public static let sharedInstance = TrackerProxy()

    public var logger: ((String) -> ())? = nil

    private let disposeBag = DisposeBag()
    private var trackers: [Tracker] = []

    private var notificationsPermissionEnabled: Bool {
        return application?.isRegisteredForRemoteNotifications ?? false
    }

    private var gpsPermissionEnabled: Bool {
       let result = locationManager.locationServiceStatus == .enabled(.authorizedAlways)
        || locationManager.locationServiceStatus == .enabled(.authorizedWhenInUse)
        return result
    }

    private let locationManager: LocationManager
    private let sessionManager: SessionManager
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository


    // MARK: - Lifecycle

    convenience init() {
        self.init(trackers: TrackerProxy.defaultTrackers)
    }

    convenience init(trackers: [Tracker]) {
        self.init(trackers: trackers,
                  sessionManager: Core.sessionManager,
                  myUserRepository: Core.myUserRepository,
                  locationManager: Core.locationManager,
                  installationRepository: Core.installationRepository)
    }

    init(trackers: [Tracker],
         sessionManager: SessionManager,
         myUserRepository: MyUserRepository,
         locationManager: LocationManager,
         installationRepository: InstallationRepository) {
        self.trackers = trackers
        self.locationManager = locationManager
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
    }

    public func add(tracker: Tracker) {
        trackers.append(tracker)
    }

    public func applicationWillEnterForeground() {
        setGPSPermission(gpsPermissionEnabled)
        setNotificationsPermission(notificationsPermissionEnabled)
    }


    // MARK: - Tracker

    public weak var application: AnalyticsApplication? {
        didSet { for var tracker in trackers { tracker.application = application } }
    }

    public func applicationDidFinishLaunching(launchOptions: [String: Any]?,
                                              apiKeys: AnalyticsAPIKeys) {
        trackers.forEach { $0.applicationDidFinishLaunching(launchOptions: launchOptions,
                                                            apiKeys: apiKeys) }
        setGPSPermission(gpsPermissionEnabled)
        setNotificationsPermission(notificationsPermissionEnabled)
        setupEventsRx()
    }

    public func applicationDidBecomeActive() {
        trackers.forEach { $0.applicationDidBecomeActive() }
    }

    public func setInstallation(_ installation: Installation?) {
        trackers.forEach { $0.setInstallation(installation) }
    }

    public func setUser(_ user: MyUser?) {
        trackers.forEach { $0.setUser(user) }
    }

    public func trackEvent(_ event: TrackerEvent) {
        logger?("\(event.actualName) -> \(String(describing: event.params))")
        trackers.forEach { $0.trackEvent(event) }
    }

    public func setLocation(_ location: LGLocation?, postalAddress: PostalAddress?) {
        trackers.forEach { $0.setLocation(location, postalAddress: postalAddress) }
    }

    public func setNotificationsPermission(_ enabled: Bool) {
        trackers.forEach { $0.setNotificationsPermission(enabled) }
    }

    public func setGPSPermission(_ enabled: Bool) {
        trackers.forEach { $0.setGPSPermission(enabled) }
    }

    public func setMarketingNotifications(_ enabled: Bool) {
        trackers.forEach { $0.setMarketingNotifications(enabled) }
    }

    public func setABTests(_ abTests: [AnalyticsABTestUserProperty]) {
        trackers.forEach { $0.setABTests(abTests) }
    }


    // MARK: Private methods

    private func setupEventsRx() {
        myUserRepository.rx_myUser.subscribeNext { [weak self] myUser in
            let user = (self?.sessionManager.loggedIn ?? false) ? myUser : nil
            self?.setUser(user)
        }.disposed(by: disposeBag)

        installationRepository.rx_installation.subscribeNext { [weak self] installation in
            self?.setInstallation(installation)
        }.disposed(by: disposeBag)

        locationManager.locationEvents.subscribeNext { [weak self] event in
            switch event {
            case .changedPermissions:
                self?.locationManagerDidChangePermissions()
            case .locationUpdate, .emergencyLocationUpdate:
                self?.setLocation(self?.locationManager.currentLocation, postalAddress: self?.locationManager.currentLocation?.postalAddress)
            case .movedFarFromSavedManualLocation:
                break
            }
        }.disposed(by: disposeBag)
    }

    private func locationManagerDidChangePermissions() {
        setGPSPermission(gpsPermissionEnabled)

        if gpsPermissionEnabled {
            trackEvent(TrackerEvent.permissionSystemComplete(.location, typePage: .listingList))
        } else {
            trackEvent(TrackerEvent.permissionSystemCancel(.location, typePage: .listingList))
        }
    }
}
