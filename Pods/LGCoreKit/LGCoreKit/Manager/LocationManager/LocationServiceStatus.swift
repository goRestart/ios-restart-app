//
//  LocationServiceStatus.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public enum LocationServicesAuthStatus {
    case notDetermined
    case restricted
    case denied
    case authorized
}

public enum LocationServiceStatus: Equatable {
    case disabled
    case enabled(LocationServicesAuthStatus)

    public init(enabled: Bool, authStatus: CLAuthorizationStatus) {
        if !enabled {
            self = .disabled
        }
        else {
            switch authStatus {
            case .notDetermined:
                self = .enabled(.notDetermined)
            case .restricted:
                self = .enabled(.restricted)
            case .denied:
                self = .enabled(.denied)
            case .authorizedAlways:
                self = .enabled(.authorized)
            case .authorizedWhenInUse:
                self = .enabled(.authorized)
            }
        }
    }
}

public func ==(lhs: LocationServiceStatus, rhs: LocationServiceStatus) -> Bool {

    switch (lhs, rhs) {
    case (.disabled, .disabled):
        return true
    case (.enabled(let rAuthStatus), .enabled(let lAuthStatus)):
        return rAuthStatus == lAuthStatus
    default:
        return false
    }
}
