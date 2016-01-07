//
//  LocationServiceStatus.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public enum LocationServicesAuthStatus {
    case NotDetermined
    case Restricted
    case Denied
    case Authorized
}

public enum LocationServiceStatus: Equatable {
    case Disabled
    case Enabled(LocationServicesAuthStatus)

    public init(enabled: Bool, authStatus: CLAuthorizationStatus) {
        if !enabled {
            self = .Disabled
        }
        else {
            switch authStatus {
            case .NotDetermined:
                self = Enabled(.NotDetermined)
            case .Restricted:
                self = Enabled(.Restricted)
            case .Denied:
                self = Enabled(.Denied)
            case .AuthorizedAlways:
                self = Enabled(.Authorized)
            case .AuthorizedWhenInUse:
                self = Enabled(.Authorized)
            }
        }
    }
}

public func ==(lhs: LocationServiceStatus, rhs: LocationServiceStatus) -> Bool {

    switch (lhs, rhs) {
    case (.Disabled, .Disabled):
        return true
    case (.Enabled(let rAuthStatus), .Enabled(let lAuthStatus)):
        return rAuthStatus == lAuthStatus
    default:
        return false
    }
}
