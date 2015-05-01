//
//  CommonDataTypes.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

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

@objc public enum DistanceType: Int, Printable {
    case Mi, Km
    var string: String {
        get {
            switch self {
            case .Mi:
                return "ML"
            case .Km:
                return "KM"
            }
        }
    }
    
    public static func fromString(string: String) -> DistanceType? {
        switch string {
        case "ML":
            return .Mi
        case "KM":
            return .Km
        default:
            return nil
        }
    }
    
    public var description: String { return "\(string)" }
}

@objc public enum ProductStatus: Int, Printable {
    case Pending = 0, Approved = 1, Discarded = 2, Sold = 3
    var string: String {
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
            }
        }
    }
    
    public var description: String { return "\(string)" }
}

@objc public enum Currency: Int, Printable {
    case EUR, USD
    var string: String {
        get {
            switch self {
            case .EUR:
                return "EUR"
            case .USD:
                return "USD"
            }
        }
    }

    public static func fromString(string: String) -> Currency? {
        switch string {
        case "EUR":
            return .EUR
        case "USD":
            return .USD
        default:
            return nil
        }
    }
    
    public var description: String { return "\(string)" }
}

