//
//  LGPartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public class LGProduct: Product {
    
    // Product iVars
    public var objectId: String!
    public var createdAt: NSDate!
    public var updatedAt: NSDate!
    
    public var name: String?
    public var descr: String?
    public var price: NSNumber?
    public var currencyCode: String?
    
    public var location: LGLocationCoordinates2D?
    public var distance: NSNumber?
    public var distanceType: DistanceType
    
    public var postalAddress: PostalAddress
    
    public var languageCode: String?
    
    public var categoryId: NSNumber?
    public var status: ProductStatus
    
    public var thumbnailURL: NSURL?
    public var thumbnailSize: LGSize?
    public var imageURLs: [NSURL]
    
    public var user: User?
    
    
    
    // MARK: - Lifecycle
    
    public init() {
        self.imageURLs = []
        self.postalAddress = PostalAddress()
        self.status = .Pending
        self.distanceType = .Km
    }
    
    // MARK: - Product methods
    
    public func formattedPrice() -> String {
        let actualCurrencyCode = currencyCode ?? LGCoreKitConstants.defaultCurrencyCode
        if let actualPrice = price {
            let formattedPrice = CurrencyHelper.sharedInstance.formattedAmountWithCurrencyCode(actualCurrencyCode, amount: actualPrice)
            return formattedPrice ?? "\(actualPrice)"
        }
        else {
            return ""
        }
    }
    
    public func formattedDistance() -> String {
        if let actualDistance = distance {
            let actualDistanceType = distanceType ?? LGCoreKitConstants.defaultDistanceType
            return actualDistanceType.formatDistance(actualDistance.floatValue)
        }
        else {
            return ""
        }
    }
}