//
//  MKMapView+Location.swift
//  LetGo
//
//  Created by Tomas Cobo on 14/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import MapKit

extension MKMapView {
    
    var currentRadius: Double {
        let centerLocation = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        return centerLocation.distance(from: topCenterLocation)
    }
    
    var currentRadiusKm: Double {
        let radiusKm = currentRadius > 0 ? currentRadius/1000 : 1.0
        return radiusKm.rounded(.down)
    }
    
    private var topCenterCoordinate: CLLocationCoordinate2D {
        return convert(CGPoint(x: frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }
    
}
