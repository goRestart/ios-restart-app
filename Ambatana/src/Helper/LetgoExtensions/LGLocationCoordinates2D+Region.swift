//
//  LGLocationCoordinates2D+Region.swift
//  LetGo
//
//  Created by Tomas Cobo on 02/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit
import CoreLocation
import MapKit

extension LGLocationCoordinates2D {
    func region(radiusAccuracy: Double) -> MKCoordinateRegion? {
        let coordinates: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        return MKCoordinateRegionMakeWithDistance(coordinates, radiusAccuracy, radiusAccuracy)
    }
}

