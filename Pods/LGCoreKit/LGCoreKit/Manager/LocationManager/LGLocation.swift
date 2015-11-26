//
//  LGLocation.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public enum LGLocationType: String {
    case Manual     = "manual"
    case Sensor     = "sensor"
    case IPLookup   = "iplookup"
    case Regional   = "regional"
    case LastSaved  = "lastsaved"
}

public class LGLocation: CustomStringConvertible, Equatable {
    
    public private(set) var location : CLLocation
    public private(set) var type: LGLocationType
    
    public var coordinate: CLLocationCoordinate2D {
        return location.coordinate
    }
    
    public init(location: CLLocation, type: LGLocationType) {
        self.location = location
        self.type = type
    }
    
    public var description : String {
        return "location: \(location.description); type: \(type.rawValue)"
    }
}

public func ==(lhs: LGLocation, rhs: LGLocation) -> Bool {
    guard lhs.type == rhs.type else { return false }
    
    let lLat = lhs.location.coordinate.latitude
    let lLon = lhs.location.coordinate.longitude
    
    let rLat = rhs.location.coordinate.latitude
    let rLon = rhs.location.coordinate.longitude
    
    return lLat == rLat && lLon == rLon
}
