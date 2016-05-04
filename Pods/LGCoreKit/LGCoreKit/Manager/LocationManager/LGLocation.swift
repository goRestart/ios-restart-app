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

    static let allValues: [LGLocationType] = [.Manual, .Sensor, .IPLookup, .Regional]
}

public final class LGLocation: CustomStringConvertible, Equatable {

    public let location : LGLocationCoordinates2D
    public let type: LGLocationType?

    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    public init(latitude: Double, longitude: Double, type: LGLocationType?) {
        self.location = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
        self.type = type
    }

    public init?(coordinate: CLLocationCoordinate2D, type: LGLocationType?) {
        guard let coordinates = LGLocationCoordinates2D(coordinates: coordinate)else { return nil }
        self.location = coordinates
        self.type = type
    }

    public init?(location: CLLocation, type: LGLocationType?) {
        guard let coordinates = LGLocationCoordinates2D(coordinates: location.coordinate) else { return nil }
        self.location = coordinates
        self.type = type
    }

    public func distanceFromLocation(otherLocation: LGLocation) -> Double {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let otherClLocation = CLLocation(latitude: otherLocation.location.latitude, longitude: otherLocation.location.longitude)
        return clLocation.distanceFromLocation(otherClLocation)
    }

    public var description : String {
        return "location: \(location); type: \(type?.rawValue)"
    }
}

public func ==(lhs: LGLocation, rhs: LGLocation) -> Bool {
    guard lhs.type == rhs.type else { return false }

    let lLat = lhs.location.latitude
    let lLon = lhs.location.longitude

    let rLat = rhs.location.latitude
    let rLon = rhs.location.longitude

    return lLat == rLat && lLon == rLon
}
