//
//  TourLocationViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 10/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

protocol TourLocationViewModelDelegate: BaseViewModelDelegate { }

final class TourLocationViewModel: BaseViewModel {

    var title: String {
        return LGLocalizedString.locationPermissionsTitleV2
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
            .bindNext { [weak self] _ in
                self?.nextStep()
        }.addDisposableTo(disposeBag)
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
        if featureFlags.newOnboardingPhase1 {
            let actionOk = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertYes),
                                    action: { [weak self] in self?.closeTourLocation() })
            let actionCancel = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertNo),
                                        action: { [weak self] in self?.askForPermissions() })
            delegate?.vmShowAlert(LGLocalizedString.onboardingLocationPermissionsAlertTitle,
                                  message: LGLocalizedString.onboardingLocationPermissionsAlertSubtitle,
                                  actions: [actionCancel, actionOk])
        } else {
            closeTourLocation()
        }
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
