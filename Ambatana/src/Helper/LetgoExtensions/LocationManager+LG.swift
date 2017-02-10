//
//  LocationManager+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 21/12/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import CoreLocation

extension LocationManager {
    
    func countryMatchesWith(countryCode: String) -> Bool {
       return  countryCode == currentLocation?.countryCode?.lowercased()
    }
}
