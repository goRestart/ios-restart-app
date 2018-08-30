import LGComponents
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
        return trackers
    }()

    static let sharedInstance = TrackerProxy()

    private let disposeBag = DisposeBag()
    private var trackers: [Tracker] = []

    private var notificationsPermissionEnabled: Bool {
        return UIApplication.shared.areRemoteNotificationsEnabled
    }

    private var gpsPermissionEnabled: Bool {
       return locationManager.locationServiceStatus == .enabled(.authorizedAlways) ||
        locationManager.locationServiceStatus == .enabled(.authorizedWhenInUse)
    }

    private let locationManager: LocationManager
    private let sessionManager: SessionManager
    private let myUserRepository: MyUserRepository
    private let installationRepository: InstallationRepository
    private let notificationsManager: NotificationsManager
    private var analyticsSessionManager: AnalyticsSessionManager


    // MARK: - Lifecycle

    convenience init() {
        self.init(trackers: TrackerProxy.defaultTrackers)
    }

    convenience init(trackers: [Tracker]) {
        let myUserRepository = Core.myUserRepository
        let keyValueStorage = KeyValueStorage.sharedInstance
        let dao = AnalyticsSessionUDDAO(keyValueStorage: keyValueStorage)
        let analyticsSessionManager = LGAnalyticsSessionManager(myUserRepository: myUserRepository,
                                                                dao: dao)
        self.init(trackers: trackers,
                  sessionManager: Core.sessionManager,
                  myUserRepository: myUserRepository,
                  locationManager: Core.locationManager,
                  installationRepository: Core.installationRepository,
                  notificationsManager: LGNotificationsManager.sharedInstance,
                  analyticsSessionManager: analyticsSessionManager)
    }

    init(trackers: [Tracker],
         sessionManager: SessionManager,
         myUserRepository: MyUserRepository,
         locationManager: LocationManager,
         installationRepository: InstallationRepository,
         notificationsManager: NotificationsManager,
         analyticsSessionManager: AnalyticsSessionManager) {
        self.trackers = trackers
        self.locationManager = locationManager
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.installationRepository = installationRepository
        self.notificationsManager = notificationsManager
        self.analyticsSessionManager = analyticsSessionManager

        self.analyticsSessionManager.sessionThresholdReachedCompletion = { [weak self] in
            let event = TrackerEvent.sessionOneMinuteFirstWeek()
            self?.trackEvent(event)
        }
    }


    // MARK: - Tracker

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?,
                     featureFlags: FeatureFlaggeable) {
        trackers.forEach { $0.application(application,
                                          didFinishLaunchingWithOptions: launchOptions,
                                          featureFlags: featureFlags) }

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

        let now = Date()
        analyticsSessionManager.pauseSession(visitEndDate: now)
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        trackers.forEach { $0.applicationWillEnterForeground(application) }
        setGPSPermission(gpsPermissionEnabled)
        setNotificationsPermission(notificationsPermissionEnabled)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        trackers.forEach { $0.applicationDidBecomeActive(application) }

        let now = Date()
        analyticsSessionManager.startOrContinueSession(visitStartDate: now)
    }

    func setInstallation(_ installation: Installation?) {
        trackers.forEach { $0.setInstallation(installation) }
    }

    func setUser(_ user: MyUser?) {
        trackers.forEach { $0.setUser(user) }
        if user != nil {
            let now = Date()
            analyticsSessionManager.startOrContinueSession(visitStartDate: now)
        }
    }

    func trackEvent(_ event: TrackerEvent) {
        logMessage(.verbose, type: .tracking, message: "\(event.actualName) -> \(String(describing: event.params))")
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
        myUserRepository.rx_myUser.bind { [weak self] myUser in
            let user = (self?.sessionManager.loggedIn ?? false) ? myUser : nil
            self?.setUser(user)
        }.disposed(by: disposeBag)

        installationRepository.rx_installation.bind { [weak self] installation in
            self?.setInstallation(installation)
        }.disposed(by: disposeBag)

        locationManager.locationEvents.bind { [weak self] event in
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

    private func setupMktNotificationsRx() {
        notificationsManager.loggedInMktNofitications.asObservable().bind { [weak self] enabled in
            self?.setMarketingNotifications(enabled)
        }.disposed(by: disposeBag)
    }
}
