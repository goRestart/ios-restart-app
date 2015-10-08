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
    
    public init(location: LGLocation) {
        self.latitude = location.location.coordinate.latitude
        self.longitude = location.location.coordinate.longitude
    }
    
    public func coordinates2DfromLocation() -> CLLocationCoordinate2D {
        var lat = self.latitude as CLLocationDegrees
        var long = self.longitude as CLLocationDegrees
        var coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        return coordinate
    }
    
    private func toBinary(value: Double, zoomLevel: Int) -> String {
        
        var modValue = value
        var finalString = ""
        var x = 0.0
        var y = 0.0
        
        for i in 0...zoomLevel-1 {
            x = modValue * 2
            y = floor(x)
            finalString += "\(Int(y))"
            modValue = x - y
        }
        
        return finalString
    }
    
    private func getCharAtIndexOrZero(value: String, index: Int) -> Int {
        
        if !value.isEmpty && index < count(value) {
            
            let singleChar = Array(value)[index]
            if let singleInt = String(singleChar).toInt() {
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
        var maxLength = max(count(latBin), count(longBin))
        
        for i in 0...maxLength-1 {
            var lat = getCharAtIndexOrZero(latBin, index: i)
            var long = getCharAtIndexOrZero(longBin, index: i)
            var n = lat * 2 + long
            
            finalString += "\(Int(n))"
        }
        return finalString
    }

    public func coordsToQuadKey(zoomLevel: Int) -> String {
        
        let π = M_PI
        
        var sinLat = sin(self.latitude * π/180)
        var latDec = 0.5 - log((1+sinLat)/(1-sinLat))/(4*π)
        var longDec = (self.longitude + 180)/360
        
        var latBin = toBinary(latDec, zoomLevel: zoomLevel)
        var longBin = toBinary(longDec, zoomLevel: zoomLevel)
        
        return binValuesToQuadKey(latBin, longBin: longBin)
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
                return "mi" //"ML"
            case .Km:
                return "km" //"KM"
            }
        }
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

