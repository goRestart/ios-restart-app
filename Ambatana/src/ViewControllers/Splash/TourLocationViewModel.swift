//
//  TourLocationViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 10/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

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

    private let disposeBag = DisposeBag()

    convenience init(source: EventParameterTypePage) {
        self.init(source: source, locationManager: Core.locationManager)
    }

    init(source: EventParameterTypePage, locationManager: LocationManager) {
        self.typePage = source
        super.init()

        locationManager.locationEvents.map { $0 == .ChangedPermissions }.observeOn(MainScheduler.instance)
            .bindNext { [weak self] _ in
                self?.nextStep()
        }.addDisposableTo(disposeBag)
    }

    func nextStep() {
        navigator?.tourLocationFinish()
    }

    // MARK: - Tracking
    
    func viewDidLoad() {
        let trackerEvent = TrackerEvent.permissionAlertStart(.Location, typePage: typePage, alertType: .FullScreen,
            permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapNoButton() {
        let trackerEvent = TrackerEvent.permissionAlertCancel(.Location, typePage: typePage, alertType: .FullScreen,
            permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    func userDidTapYesButton() {
        let trackerEvent = TrackerEvent.permissionAlertComplete(.Location, typePage: typePage, alertType: .FullScreen,
            permissionGoToSettings: .notAvailable)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

        let trackerSystemEvent = TrackerEvent.permissionSystemStart(.Location, typePage: typePage)
        TrackerProxy.sharedInstance.trackEvent(trackerSystemEvent)
    }
}
