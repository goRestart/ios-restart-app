//
//  CommonDataTypes.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Foundation

@objc public class LGSize {
    public var width: CGFloat
    public var height: CGFloat
    
    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
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
    public var description: String { return "\(string)" }
}

