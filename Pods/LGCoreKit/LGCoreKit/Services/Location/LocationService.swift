//
//  LocationService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 08/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public protocol LocationService: class {
    var distance: CLLocationDistance { get set }
    var accuracy: CLLocationDistance { get set }
    var lastKnownLocation: CLLocation! { get }

    var locationManagerDelegate: CLLocationManagerDelegate! { get set }

    func locationEnabled() -> Bool
    func authorizationStatus() -> CLAuthorizationStatus

    func requestWhenInUseAuthorization()
    func requestAlwaysAuthorization()

    func startUpdatingLocation()
    func stopUpdatingLocation()
}
