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

    weak var navigator: TourLocationNavigator?
    weak var delegate: TourLocationViewModelDelegate?
    
    private let disposeBag = DisposeBag()

    convenience init(source: EventParameterTypePage) {
        self.init(source: source, locationManager: Core.locationManager)
    }

    init(source: EventParameterTypePage, locationManager: LocationManager) {
        self.typePage = source
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
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        let actionOk = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertYes),
                                action: { [weak self] in self?.canceledRequestPermission() })
        let actionCancel = UIAction(interface: UIActionInterface.text(LGLocalizedString.onboardingAlertNo),
                                    action: { [weak self] in self?.askForPermissions() })
        delegate?.vmShowAlert(LGLocalizedString.onboardingLocationPermissionsAlertTitle,
                              message: LGLocalizedString.onboardingLocationPermissionsAlertSubtitle,
                              actions: [actionCancel, actionOk])
    }
    
    func userDidTapYesButton() {
        askForPermissions()

    }
    
    private func canceledRequestPermission() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.location, typePage: typePage, alertType: .fullScreen,
                                                              permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        nextStep()
    }
    
    private func askForPermissions() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.location, typePage: typePage, alertType: .fullScreen,
                                                                permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        
        let trackerSystemEvent = TrackerEvent.permissionSystemStart(.location, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerSystemEvent)
        nextStep()
    }
}
