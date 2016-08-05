//
//  LGLocationCoordinates2D+Distance.swift
//  LetGo
//
//  Created by Isaac Roldan on 9/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import CoreLocation

extension LGLocationCoordinates2D {
    func distanceTo(toCoordinates: LGLocationCoordinates2D) -> Double {
        var meters = 0.0
        
        let fromLocation = CLLocation(latitude: latitude, longitude: longitude)
        let toLocation = CLLocation(latitude: toCoordinates.latitude, longitude: toCoordinates.longitude)
        meters = fromLocation.distanceFromLocation(toLocation)
        
        let distanceType = DistanceType.systemDistanceType()
        switch (distanceType) {
        case .Km:
            return meters * 0.001
        case .Mi:
            return meters * 0.000621371
        }
    }
}
