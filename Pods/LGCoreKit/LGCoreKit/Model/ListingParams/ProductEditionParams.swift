//
//  ProductEditionParams.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 19/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public class ProductEditionParams: ProductCreationParams {
    let productId: String
    let userId: String
    
    public convenience init?(listing: Listing) {
        guard let productId = listing.objectId, let userId = listing.user.objectId else { return nil }
        let editedProduct: Product
        switch listing {
        case .car, .realEstate:
            editedProduct = ProductEditionParams.createProductParams(withListing: listing)
        case let .product(product):
            editedProduct = product
        }
        self.init(product: editedProduct,
                  productId: productId,
                  userId: userId)
    }
    
    public convenience init?(product: Product) {
        guard let productId = product.objectId, let userId = product.user.objectId else { return nil }
        self.init(product: product,
                  productId: productId,
                  userId: userId)
    }
    
    init(product: Product,
         productId: String,
         userId: String) {
        self.productId = productId
        self.userId = userId
        super.init(name: product.name,
                   description: product.descr,
                   price: product.price,
                   category: product.category,
                   currency: product.currency,
                   location: product.location,
                   postalAddress: product.postalAddress,
                   images: product.images)
        if let languageCode = product.languageCode {
            self.languageCode = languageCode
        }
    }
    
    func apiEditionEncode() -> [String: Any] {
        return super.apiCreationEncode(userId: userId)
    }
    
    static private func createProductParams(withListing listing: Listing) -> Product {
        let category: ListingCategory = listing.isCar ? .motorsAndAccessories : .unassigned
        let product = LGProduct(objectId: listing.objectId, updatedAt: listing.updatedAt, createdAt: listing.createdAt,
                                name: listing.name, nameAuto: listing.nameAuto, descr: listing.descr,
                                price: listing.price, currency: listing.currency, location: listing.location,
                                postalAddress: listing.postalAddress, languageCode: listing.languageCode,
                                category: category, status: listing.status, thumbnail: listing.thumbnail,
                                thumbnailSize: listing.thumbnailSize, images: listing.images, user: listing.user,
                                featured: listing.featured)
        return product
    }
}
