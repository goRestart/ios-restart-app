//
//  ServiceDataTypes.swift
//  LGCoreKit
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

// MARK: - COMPLETION CLOSURES

public typealias NoOutputDataCompletion = (success: Bool, error: NSError?) -> Void

public typealias RetrieveTokenCompletion = (token: SessionToken?, error: NSError?) -> Void
public typealias RetrieveProductsCompletion = (products: NSArray?, lastPage: Bool?, error: NSError?) -> Void
public typealias UserSaveCompletion = NoOutputDataCompletion
public typealias PostalAddressRetrievalCompletion = (address: PostalAddress?, error: NSError?) -> Void

// MARK: - PARAMS

public struct RetrieveTokenParams {
    private(set) var clientId: String
    private(set) var clientSecret: String
    public init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }
}

public struct RetrieveProductsParams: Printable, Equatable {
    public var queryString: String?
    public var coordinates: LGLocationCoordinates2D
    public var categoryIds: [Int]?
    public var sortCriteria: ProductSortCriteria?
    public var distanceType: DistanceType?
    public var offset: Int?                 // skip results
    public var numProducts: Int?            // number products to return
    public var statuses: [ProductStatus]?   // Default 1,3
    public var maxPrice: Int?
    public var minPrice: Int?
    public var distanceRadius: Int?
    public var userObjectId: String?
    
    public var accessToken: String
    
    public init(coordinates: LGLocationCoordinates2D, accessToken: String) {
        self.coordinates = coordinates
        self.accessToken = accessToken
    }
    
    public var description: String { return "queryString: \(queryString); latitude: \(coordinates.latitude); longitude: \(coordinates.longitude); categoryIds: \(categoryIds); sortCriteria: \(sortCriteria); distanceType: \(distanceType); offset: \(offset); numProducts: \(numProducts); statuses: \(statuses); maxPrice: \(maxPrice); minPrice: \(minPrice); distanceRadius: \(distanceRadius); userObjectId: \(userObjectId); accessToken: \(accessToken)" }
}

public func ==(lhs: RetrieveProductsParams, rhs: RetrieveProductsParams) -> Bool {
    return lhs.queryString == rhs.queryString && lhs.coordinates == rhs.coordinates &&
        lhs.categoryIds == rhs.categoryIds && lhs.sortCriteria == rhs.sortCriteria &&
        lhs.distanceType == rhs.distanceType && lhs.offset == rhs.offset &&
        lhs.numProducts == rhs.numProducts && lhs.statuses == rhs.statuses &&
        lhs.maxPrice == rhs.maxPrice && lhs.minPrice == rhs.minPrice &&
        lhs.distanceRadius == rhs.distanceRadius && lhs.userObjectId == rhs.userObjectId
}

// MARK: - ENUMS & STRUCTS

@objc public enum ProductSortCriteria: Int, Equatable {
    case Distance = 1, PriceAsc = 2, PriceDesc = 3, Creation = 4
    var string: String? {
        get {
            switch self {
            case .Distance:
                return nil
            case .PriceAsc:
                return "price asc"
            case .PriceDesc:
                return "price desc"
            case .Creation:
                return "created_at desc"
            }
        }
    }
}