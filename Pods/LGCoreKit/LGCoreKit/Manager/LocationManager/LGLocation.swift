//
//  LGLocation.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/09/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public enum LGLocationType: String {
    case manual     = "manual"
    case sensor     = "sensor"
    case ipLookup   = "iplookup"
    case regional   = "regional"

    static let allValues: [LGLocationType] = [.manual, .sensor, .ipLookup, .regional]
}

public final class LGLocation: CustomStringConvertible, Equatable {

    public let location : LGLocationCoordinates2D
    public let type: LGLocationType?
    public let postalAddress: PostalAddress?
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
    }

    public init(latitude: Double, longitude: Double, type: LGLocationType?, postalAddress: PostalAddress?) {
        self.location = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
        self.postalAddress = postalAddress
        self.type = type
    }

    public init?(coordinate: CLLocationCoordinate2D, type: LGLocationType?, postalAddress: PostalAddress?) {
        guard let coordinates = LGLocationCoordinates2D(coordinates: coordinate)else { return nil }
        self.location = coordinates
        self.postalAddress = postalAddress
        self.type = type
    }

    public init?(location: CLLocation, type: LGLocationType?, postalAddress: PostalAddress?) {
        guard let coordinates = LGLocationCoordinates2D(coordinates: location.coordinate) else { return nil }
        self.location = coordinates
        self.postalAddress = postalAddress
        self.type = type
    }
    
    public func updating(postalAddress: PostalAddress) -> LGLocation {
        return LGLocation(latitude: coordinate.latitude, longitude: coordinate.longitude, type: type, postalAddress: postalAddress)
    }


    public func distanceFromLocation(_ otherLocation: LGLocation) -> Double {
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
        let otherClLocation = CLLocation(latitude: otherLocation.location.latitude, longitude: otherLocation.location.longitude)
        return clLocation.distance(from: otherClLocation)
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
    
    let lPostalAddress = lhs.postalAddress
    let rPostalAddress = rhs.postalAddress
    
    return lLat == rLat && lLon == rLon && lPostalAddress == rPostalAddress
}
