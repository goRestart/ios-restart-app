//
//  MockProduct.swift
//  LetGo
//
//  Created by Albert Hernández López on 06/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

class MockProduct: MockBaseModel, Product {
   
    // Product iVars
    var name: String?
    var descr: String?
    var price: NSNumber?
    var currency: Currency?
    
    var location: LGLocationCoordinates2D?
    var distance: NSNumber?
    var distanceType: DistanceType
    
    var postalAddress: PostalAddress
    
    var languageCode: String?
    
    var categoryId: NSNumber?
    var status: ProductStatus
    
    var thumbnail: File?
    var thumbnailSize: LGSize?
    var images: [File]
    
    var user: User?
    
    var processed: NSNumber?

    var reported: NSNumber?
    var favorited: NSNumber?

    
    // MARK: - Lifecycle
    
    override init() {
        self.images = []
        self.postalAddress = PostalAddress()
        self.status = .Pending
        self.distanceType = .Km
        super.init()
    }
    
    // MARK: - Product methods
    
    func formattedPrice() -> String {
        return ""
    }
    
    func formattedDistance() -> String {
        return ""
    }
    
    func updateWithProduct(product: Product) {
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
        
        processed = product.processed
    }
    
    // MARK: - Public methods
    
    static func productFromProduct(product: Product) -> MockProduct {
        var mockProduct = MockProduct()
        mockProduct.name = product.name
        mockProduct.descr = product.descr
        mockProduct.price = product.price
        mockProduct.currency = product.currency
        
        mockProduct.location = product.location
        mockProduct.postalAddress = product.postalAddress
        
        mockProduct.languageCode = product.languageCode
        
        mockProduct.categoryId = product.categoryId
        mockProduct.status = product.status
        
        mockProduct.thumbnail = product.thumbnail
        mockProduct.images = product.images
        
        mockProduct.user = product.user
        
        mockProduct.processed = product.processed
        return mockProduct
    }
}
