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
    var nameAuto: String?
    var descr: String?
    var price: ProductPrice
    var currency: Currency
    
    var location: LGLocationCoordinates2D
    var distance: NSNumber?
    
    var postalAddress: PostalAddress
    
    var languageCode: String?

    var category: ProductCategory
    var status: ProductStatus
    
    var thumbnail: File?
    var thumbnailSize: LGSize?
    var images: [File]
    
    var user: User
    
    var processed: NSNumber?
    var favorite: Bool

    // MARK: - Lifecycle
    
    override init() {
        self.images = []
        self.location = LGLocationCoordinates2D(latitude:0,longitude:0)
        self.postalAddress = PostalAddress.emptyAddress()
        self.status = .pending
        self.category = .Electronics
        self.user = MockUser()
        self.favorite = false
        self.price = .Negotiable(100)
        self.currency = Currency(code: "USD", symbol: "$")
        super.init()
    }
    
    // MARK: - Product methods
    
    func formattedPrice() -> String {
        return ""
    }
    
    func formattedDistance() -> String {
        return ""
    }
    
    func updateWithProduct(_ product: Product) {
        name = product.name
        nameAuto = product.nameAuto
        descr = product.descr
        price = product.price
        currency = product.currency
        
        location = product.location
        postalAddress = product.postalAddress
        languageCode = product.languageCode
        
        category = product.category
        status = product.status
        
        thumbnail = product.thumbnail
        images = product.images
        favorite = product.favorite
        
        user = product.user
    }
    
    
    // MARK: - Public methods
    
    static func productFromProduct(_ product: Product) -> MockProduct {
        let mockProduct = MockProduct()
        mockProduct.name = product.name
        mockProduct.nameAuto = product.nameAuto
        mockProduct.descr = product.descr
        mockProduct.price = product.price
        mockProduct.currency = product.currency
        
        mockProduct.location = product.location
        mockProduct.postalAddress = product.postalAddress
        
        mockProduct.languageCode = product.languageCode

        mockProduct.category = product.category
        mockProduct.status = product.status
        
        mockProduct.thumbnail = product.thumbnail
        mockProduct.images = product.images
        mockProduct.favorite = product.favorite
        mockProduct.user = product.user
        
        return mockProduct
    }
}
