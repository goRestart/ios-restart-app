//
//  LocationFromZipCodeViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit

class LocationFromZipCodeViewModel: BaseViewModel {

    let locationManager: LocationManager

    convenience override init() {
        self.init(locationManager: Core.locationManager)
    }

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        super.init()
    }

}
