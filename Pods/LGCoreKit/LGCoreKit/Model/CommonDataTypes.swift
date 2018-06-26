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
        let maxLength = max(latBin.count, longBin.count)

        for i in 0...maxLength-1 {
            let lat = latBin.getCharInt(at: i)
            let long = longBin.getCharInt(at: i)
            let n = lat * 2 + long

            finalString += "\(Int(n))"
        }
        return finalString
    }

    public func coordsToQuadKey(_ zoomLevel: Int) -> String {

        let π = Double.pi

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

public enum DistanceType: String, Decodable {
    case mi, km
}

public enum ListingStatusCode: Int, Decodable {
    case pending = 0, approved = 1, discarded = 2, sold = 3, soldOld = 5, deleted = 6
}

// @see: https://ambatana.atlassian.net/wiki/display/BAPI/IDs+reference
public enum ListingStatus: CustomStringConvertible {
    case pending
    case approved
    case discarded(reason: DiscardedReason?)
    case sold
    case soldOld
    case deleted
    
    var apiCode: Int {
        get {
            switch self {
            case .pending: return ListingStatusCode.pending.rawValue
            case .approved: return ListingStatusCode.approved.rawValue
            case .discarded: return ListingStatusCode.discarded.rawValue
            case .sold: return ListingStatusCode.sold.rawValue
            case .soldOld: return ListingStatusCode.soldOld.rawValue
            case .deleted: return ListingStatusCode.deleted.rawValue
            }
        }
    }
    
    public var string: String {
        get {
            switch self {
            case .pending: return "Pending"
            case .approved: return "Approved"
            case .discarded: return "Discarded"
            case .sold: return "Sold"
            case .soldOld: return "Sold Old"
            case .deleted: return "Deleted"
            }
        }
    }
    
    public init?(statusCode: ListingStatusCode, discardedReason: DiscardedReason? = nil) {
        switch statusCode {
        case .pending: self = .pending
        case .approved: self = .approved
        case .discarded: self = .discarded(reason: discardedReason)
        case .sold: self = .sold
        case .soldOld: self = .soldOld
        case .deleted: self = .deleted
        }
    }

    public var description: String { return "\(string)" }
    
    public var discardedReason: DiscardedReason? {
        switch self {
        case .discarded(let reason): return reason
        default: return nil
        }
    }
    
    public var isDiscarded: Bool {
        switch self {
        case .discarded: return true
        default: return false
        }
    }
}

extension ListingStatus: Equatable {
    
    public static func==(lhs: ListingStatus, rhs: ListingStatus) -> Bool {
        return lhs.apiCode == rhs.apiCode
    }
}

extension ListingStatus: Hashable {
    
    public var hashValue: Int {
        return apiCode
    }
    
}
