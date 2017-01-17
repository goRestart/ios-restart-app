//
//  DistanceType+LG.swift
//  LetGo
//
//  Created by Eli Kohen on 16/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension DistanceType {
    
    static func systemDistanceType() -> DistanceType {

        let distanceType: DistanceType
        // use whatever the locale says
        if Locale.current.usesMetricSystem {
            distanceType = .km
        } else {
            distanceType = .mi
        }
        return distanceType
    }
}
