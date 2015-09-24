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
    
    public var reported: NSNumber?
    public var favorited: NSNumber?
    
    
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

    public func updateWithProduct(product: Product) {
        name = product.name
        descr = product.descr
        price = product.price
        currency = product.currency
        
        location = product.location
        postalAddress = product.postalAddress
        
        languageCode = product.languageCode
        
        categoryId = product.categoryId
        status = product.status
        
        thumbnail = product.thumbnail
        images = product.images
        
        user = product.user
    }
    
    // MARK: - Public methods
    
    public static func productFromProduct(product: Product) -> LGProduct {
        var letgoProduct = LGProduct()
        letgoProduct.name = product.name
        letgoProduct.descr = product.descr
        letgoProduct.price = product.price
        letgoProduct.currency = product.currency
        
        letgoProduct.location = product.location
        letgoProduct.postalAddress = product.postalAddress
        
        letgoProduct.languageCode = product.languageCode
        
        letgoProduct.categoryId = product.categoryId
        letgoProduct.status = product.status
        
        letgoProduct.thumbnail = product.thumbnail
        letgoProduct.images = product.images
        
        letgoProduct.user = product.user
        
        return letgoProduct
    }
}

extension LGProduct: Printable {
    public var description: String {
        return "name: \(name); descr: \(descr); price: \(price); currency: \(currency); location: \(location); distance: \(distance); distanceType: \(distanceType); postalAddress: \(postalAddress); languageCode: \(languageCode); categoryId: \(categoryId); status: \(status); thumbnail: \(thumbnail); thumbnailSize: \(thumbnailSize); images: \(images); user: \(user); descr: \(descr);reported: \(reported); favorited: \(favorited);"
    }
}