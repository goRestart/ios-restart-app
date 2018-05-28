import RxSwift
import LGCoreKit
import LGComponents

protocol TourLocationViewModelDelegate: BaseViewModelDelegate { }

final class TourLocationViewModel: BaseViewModel {

    var title: String {
        return R.Strings.locationPermissionsTitleV2
    }
    var showBubbleInfo: Bool {
        return false
    }
    var showAlertInfo: Bool {
        return !showBubbleInfo
    }
    var infoImage: UIImage? {
        return UIImage(named: "img_permissions_background")
    }

    let typePage: EventParameterTypePage
    let featureFlags: FeatureFlaggeable
    let locationManager: LocationManager
    let tracker: Tracker
    
    weak var navigator: TourLocationNavigator?
    weak var delegate: TourLocationViewModelDelegate?
    
    private let disposeBag = DisposeBag()

    convenience init(source: EventParameterTypePage) {
        self.init(source: source, locationManager: Core.locationManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(source: EventParameterTypePage, locationManager: LocationManager, featureFlags: FeatureFlags, tracker: Tracker) {
        self.typePage = source
        self.featureFlags = featureFlags
        self.locationManager = locationManager
        self.tracker = tracker
        super.init()

        locationManager.locationEvents.map { $0 == .changedPermissions }.observeOn(MainScheduler.instance)
            .bind { [weak self] _ in
                self?.nextStep()
        }.disposed(by: disposeBag)
    }

    func nextStep() {
        navigator?.tourLocationFinish()
    }

    // MARK: - Tracking
    
    func viewDidLoad() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.location, typePage: typePage, alertType: .fullScreen,
            permissionGoToSettings: .notAvailable)
        tracker.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        let actionOk = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertYes),
                                action: { [weak self] in self?.closeTourLocation() })
        let actionCancel = UIAction(interface: UIActionInterface.text(R.Strings.onboardingAlertNo),
                                    action: { [weak self] in self?.askForPermissions() })
        delegate?.vmShowAlert(R.Strings.onboardingLocationPermissionsAlertTitle,
                              message: R.Strings.onboardingLocationPermissionsAlertSubtitle,
                              actions: [actionCancel, actionOk])
    }

    func userDidTapYesButton() {
        askForPermissions()
    }
    
    private func closeTourLocation() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.location, typePage: typePage, alertType: .fullScreen,
                                                              permissionGoToSettings: .notAvailable)
        tracker.trackEvent(trackerEvent)
        nextStep()
    }
    
    private func askForPermissions() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.location, typePage: typePage, alertType: .fullScreen,
                                                                permissionGoToSettings: .notAvailable)
        tracker.trackEvent(trackerEvent)
        
        let trackerSystemEvent = TrackerEvent.permissionSystemStart(.location, typePage: typePage)
        tracker.trackEvent(trackerSystemEvent)
        locationManager.startSensorLocationUpdates()
    }
}
