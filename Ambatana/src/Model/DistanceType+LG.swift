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
        if let usesMetric = NSLocale.currentLocale.objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            distanceType = usesMetric ? .Km : .Mi
        }
            // fallback: km
        else {
            distanceType = DistanceType.Km
        }
        return distanceType
    }
}
