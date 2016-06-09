//
//  CLLocationManager+LocationService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

extension CLLocationManager: LocationService {
    public var distance: CLLocationDistance {
        get {
            return distanceFilter
        }
        set {
            distanceFilter = newValue
        }
    }
    public var accuracy: CLLocationDistance {
        get {
            return desiredAccuracy
        }
        set {
            desiredAccuracy = newValue
        }
    }
    public var lastKnownLocation: CLLocation! {
        get {
            return location
        }
    }

    public var locationManagerDelegate: CLLocationManagerDelegate! {
        get {
            return delegate
        }
        set {
            delegate = newValue
        }
    }

    public func locationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }

    public func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
}
