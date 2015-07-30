//
//  LGPartialProduct.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 30/04/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

@objc public class LGProduct: LGBaseModel, Product {
    
    // Product iVars
    public var name: String?
    public var descr: String?
    public var price: NSNumber?
    public var currency: Currency?
    
    public var location: LGLocationCoordinates2D?
    public var distance: NSNumber?
    public var distanceType: DistanceType
    
    public var postalAddress: PostalAddress
    
    public var languageCode: String?
    
    public var categoryId: NSNumber?
    public var status: ProductStatus
    
    public var thumbnail: File?
    public var thumbnailSize: LGSize?
    public var images: [File]
    
    public var user: User?
    
    public var processed: NSNumber?
    
    // MARK: - Lifecycle
    
    public override init() {
        self.images = []
        self.postalAddress = PostalAddress()
        self.status = .Pending
        self.distanceType = .Km
        super.init()
    }
    
    // MARK: - Product methods
    
    public func formattedPrice() -> String {
        let actualCurrencyCode = currency?.code ?? LGCoreKitConstants.defaultCurrencyCode
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