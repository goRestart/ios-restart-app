//
//  CommonDataTypes.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

@objc public class LGSize: Equatable {
    public var width: Float
    public var height: Float
    
    public init(width: Float, height: Float) {
        self.width = width
        self.height = height
    }
}

public func ==(lhs: LGSize, rhs: LGSize) -> Bool {
    return lhs.width == rhs.width && lhs.height == rhs.height
}

@objc public class LGLocationCoordinates2D: Equatable {
    public var latitude: Double
    public var longitude: Double
    
    public init(latitude: Double , longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public init?(coordinates: CLLocationCoordinate2D) {
        if !CLLocationCoordinate2DIsValid(coordinates) {
            self.latitude = 0
            self.longitude = 0
            return nil
        }
        else {
            self.latitude = coordinates.latitude
            self.longitude = coordinates.longitude
        }
    }
    
    public func coordinates2DfromLocation() -> CLLocationCoordinate2D {
        var lat = self.latitude as CLLocationDegrees
        var long = self.longitude as CLLocationDegrees
        var coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return coordinate
    }
}

public func ==(lhs: LGLocationCoordinates2D, rhs: LGLocationCoordinates2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

@objc public enum DistanceType: Int, Printable {
    case Mi, Km
    public var string: String {
        get {
            switch self {
            case .Mi:
                return "ML"
            case .Km:
                return "KM"
            }
        }
    }
    
    public static func fromString(string: String) -> DistanceType {
        switch string {
        case "ML", "Ml", "ml", "MI", "Mi", "mi":
            return .Mi
        case "KM", "Km", "km":
            return .Km
        default:
            return .Km
        }
    }
    
    public func formatDistance(distance: Float) -> String {
        var format: String
        switch self {
        case .Mi:
            format = "%.1f mi"
        case .Km:
            format = "%.1f km"
        default:
            format = "%.1f mi"
        }
        return NSString(format: format, distance) as String
    }
    
    public var description: String { return "\(string)" }
}

// @see: https://ambatana.atlassian.net/wiki/display/BAPI/IDs+reference
@objc public enum ProductStatus: Int, Printable {
    case Pending = 0, Approved = 1, Discarded = 2, Sold = 3, SoldOld = 5, Deleted = 6
    public var string: String {
        get {
            switch self {
            case .Pending:
                return "Pending"
            case .Approved:
                return "Approved"
            case .Discarded:
                return "Discarded"
            case .Sold:
                return "Sold"
            case .SoldOld:
                return "Sold Old"
            case .Deleted:
                return "Deleted"
            }
        }
    }
    
    public var description: String { return "\(string)" }
}

