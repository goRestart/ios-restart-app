//
//  CommonDataTypes.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

final public class LGSize: Equatable {
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

public struct LGLocationCoordinates2D: Equatable {
    public let latitude: Double
    public let longitude: Double

    public init(latitude: Double , longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }

    public init?(coordinates: CLLocationCoordinate2D) {
        guard CLLocationCoordinate2DIsValid(coordinates) else { return nil }
        self.latitude = coordinates.latitude
        self.longitude = coordinates.longitude
    }

    public init(location: LGLocation) {
        self.latitude = location.location.latitude
        self.longitude = location.location.longitude
    }

    public init(fromCenterOfQuadKey quadKey: String) {

        let (latBin,longBin) = quadKey.getBinaryValues()
        let latDec = latBin.getBinaryValue()
        let longDec = longBin.getBinaryValue()
        let (lat, lon) = latDec.getCoordinates(with: longDec)
        self.latitude = lat
        self.longitude = lon
    }

    public func coordinates2DfromLocation() -> CLLocationCoordinate2D {
        let lat = self.latitude as CLLocationDegrees
        let long = self.longitude as CLLocationDegrees
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return coordinate
    }

    private func toBinary(_ value: Double, zoomLevel: Int) -> String {

        var modValue = value
        var finalString = ""
        var x = 0.0
        var y = 0.0

        for _ in 0...zoomLevel-1 {
            x = modValue * 2
            y = floor(x)
            finalString += "\(Int(y))"
            modValue = x - y
        }

        return finalString
    }

    private func binValuesToQuadKey(_ latBin: String, longBin: String) -> String {

        if latBin.isEmpty || longBin.isEmpty {
            return ""
        }

        var finalString = ""
        let maxLength = max(latBin.characters.count, longBin.characters.count)

        for i in 0...maxLength-1 {
            let lat = latBin.getCharInt(at: i)
            let long = longBin.getCharInt(at: i)
            let n = lat * 2 + long

            finalString += "\(Int(n))"
        }
        return finalString
    }

    public func coordsToQuadKey(_ zoomLevel: Int) -> String {

        let π = M_PI

        let sinLat = sin(self.latitude * π/180)
        let latDec = 0.5 - log((1+sinLat)/(1-sinLat))/(4*π)
        let longDec = (self.longitude + 180)/360

        let latBin = toBinary(latDec, zoomLevel: zoomLevel)
        let longBin = toBinary(longDec, zoomLevel: zoomLevel)

        return binValuesToQuadKey(latBin, longBin: longBin)
    }



}

public func ==(lhs: LGLocationCoordinates2D, rhs: LGLocationCoordinates2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

@objc public enum DistanceType: Int, CustomStringConvertible {
    case mi, km
    public var string: String {
        get {
            switch self {
            case .mi:
                return "mi" //"ML"
            case .km:
                return "km" //"KM"
            }
        }
    }

    public var description: String { return "\(string)" }
}

// @see: https://ambatana.atlassian.net/wiki/display/BAPI/IDs+reference
@objc public enum ProductStatus: Int, CustomStringConvertible {
    case pending = 0, approved = 1, discarded = 2, sold = 3, soldOld = 5, deleted = 6
    public var string: String {
        get {
            switch self {
            case .pending:
                return "Pending"
            case .approved:
                return "Approved"
            case .discarded:
                return "Discarded"
            case .sold:
                return "Sold"
            case .soldOld:
                return "Sold Old"
            case .deleted:
                return "Deleted"
            }
        }
    }

    public var description: String { return "\(string)" }
}

