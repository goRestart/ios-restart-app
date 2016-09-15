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

    func nextStep() {
        navigator?.tourLoginFinish()
    }
}
