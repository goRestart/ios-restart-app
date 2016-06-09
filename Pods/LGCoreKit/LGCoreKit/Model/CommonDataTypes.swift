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

final public class LGLocationCoordinates2D: Equatable {
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

    public init(location: LGLocation) {
        self.latitude = location.location.latitude
        self.longitude = location.location.longitude
    }

    public init(fromCenterOfQuadKey quadKey: String) {
        //Initializing local properties to avoid compiler errors
        self.latitude = 0.0
        self.longitude = 0.0

        let (latBin,longBin) = quadkeyToBinValues(quadKey)
        let latDec = valueFromBinary(latBin)
        let longDec = valueFromBinary(longBin)
        let (lat, lon) = coordinatesFromDecimalValues(latDec, longDec)
        self.latitude = lat
        self.longitude = lon
    }

    public func coordinates2DfromLocation() -> CLLocationCoordinate2D {
        let lat = self.latitude as CLLocationDegrees
        let long = self.longitude as CLLocationDegrees
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return coordinate
    }

    private func toBinary(value: Double, zoomLevel: Int) -> String {

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

    private func getCharAtIndexOrZero(value: String, index: Int) -> Int {

        if !value.isEmpty && index < value.characters.count {

            let singleChar = Array(value.characters)[index]
            if let singleInt = Int(String(singleChar)) {
                return singleInt
            } else {
                return 0
            }
        }
        return 0
    }

    private func binValuesToQuadKey(latBin: String, longBin: String) -> String {

        if latBin.isEmpty || longBin.isEmpty {
            return ""
        }

        var finalString = ""
        let maxLength = max(latBin.characters.count, longBin.characters.count)

        for i in 0...maxLength-1 {
            let lat = getCharAtIndexOrZero(latBin, index: i)
            let long = getCharAtIndexOrZero(longBin, index: i)
            let n = lat * 2 + long

            finalString += "\(Int(n))"
        }
        return finalString
    }

    public func coordsToQuadKey(zoomLevel: Int) -> String {

        let π = M_PI

        let sinLat = sin(self.latitude * π/180)
        let latDec = 0.5 - log((1+sinLat)/(1-sinLat))/(4*π)
        let longDec = (self.longitude + 180)/360

        let latBin = toBinary(latDec, zoomLevel: zoomLevel)
        let longBin = toBinary(longDec, zoomLevel: zoomLevel)

        return binValuesToQuadKey(latBin, longBin: longBin)
    }

    private func quadkeyToBinValues(quadKey: String) -> (String,String) {

        var latBin = ""
        var lonBin = ""
        for i in 0...quadKey.characters.count - 1 {
            let quadCharInt = getCharAtIndexOrZero(quadKey, index: i)
            latBin += String(quadCharInt >> 1)
            lonBin += String(quadCharInt & 1)
        }

        return (latBin,lonBin)
    }

    private func valueFromBinary(value: String) -> Double {
        let oneVal = value + "1"
        let decimal = strtoul(oneVal, nil, 2)
        return Double(decimal) / pow(2.0, Double(oneVal.characters.count))
    }

    private func coordinatesFromDecimalValues(latDec: Double,_ longDec: Double) -> (Double, Double) {
        let π = M_PI

        let exponent = exp((0.5 - latDec) * 4 * π)

        return (asin((exponent - 1) / (exponent + 1)) * 180 / π, longDec * 360 - 180)
    }
}

public func ==(lhs: LGLocationCoordinates2D, rhs: LGLocationCoordinates2D) -> Bool {
    return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
}

@objc public enum DistanceType: Int, CustomStringConvertible {
    case Mi, Km
    public var string: String {
        get {
            switch self {
            case .Mi:
                return "mi" //"ML"
            case .Km:
                return "km" //"KM"
            }
        }
    }

    public var description: String { return "\(string)" }
}

// @see: https://ambatana.atlassian.net/wiki/display/BAPI/IDs+reference
@objc public enum ProductStatus: Int, CustomStringConvertible {
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

