//
//  ProductsService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

// MARK: - Completion closure definitions

public typealias RetrieveProductsCompletion = (products: [PartialProduct]?, error: LGError?) -> Void

//public typealias 

// MARK: - Enums & Structss

@objc public enum ProductSortCriteria: Int {
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

public class RetrieveProductsParams: Printable {
    public var queryString: String?
    public var coordinates: CLLocationCoordinate2D
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
    
    public init?(coordinates: CLLocationCoordinate2D, accessToken: String) {
        self.coordinates = coordinates
        self.accessToken = accessToken
        if !CLLocationCoordinate2DIsValid(coordinates) { return nil }
    }
    
    // MARK: - Printable
    
    public var description: String { return "queryString: \(queryString); latitude: \(coordinates.latitude); longitude: \(coordinates.longitude); categoryIds: \(categoryIds); sortCriteria: \(sortCriteria); distanceType: \(distanceType); offset: \(offset); numProducts: \(numProducts); statuses: \(statuses); maxPrice: \(maxPrice); minPrice: \(minPrice); distanceRadius: \(distanceRadius); userObjectId: \(userObjectId); accessToken: \(accessToken)" }
}

// MARK: - ProductsService

public protocol ProductsService {
    func retrieveProductsWithParams(params: RetrieveProductsParams, completion: RetrieveProductsCompletion)
}