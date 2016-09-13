//
//  TourLoginViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 4/2/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
enum TourLoginNextStep {
    case Notifications
    case Location
    case None
}

final class TourLoginViewModel: BaseViewModel {

    weak var navigator: TourLoginNavigator?

    func nextStep() -> TourLoginNextStep? {
        guard navigator == nil else {
            navigator?.tourLoginFinish()
            return nil
        }
        let casnAskForPushPermissions = PushPermissionsManager.sharedInstance
            .shouldShowPushPermissionsAlertFromViewController(.Onboarding)
       
        if casnAskForPushPermissions {
            return .Notifications
        } else if Core.locationManager.shouldAskForLocationPermissions() {
            return .Location
        } else {
            return .None
        }
    }
}