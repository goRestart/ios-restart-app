//
//  LCLocationManagerProtocol.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 28/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import CoreLocation

public protocol CLLocationManagerProtocol {
    var distanceFilter: CLLocationDistance { get set }
    var desiredAccuracy: CLLocationDistance { get set }
    var location: CLLocation? { get }
    var delegate: CLLocationManagerDelegate? { get set }
    static func locationServicesEnabled() -> Bool
    static func authorizationStatus() -> CLAuthorizationStatus
    func requestAlwaysAuthorization()
    func requestWhenInUseAuthorization()
    func startUpdatingLocation()
    func stopUpdatingLocation()
}

extension CLLocationManager: CLLocationManagerProtocol {
  
}
