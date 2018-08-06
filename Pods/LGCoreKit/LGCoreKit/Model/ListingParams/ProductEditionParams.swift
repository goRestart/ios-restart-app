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
        let editedProduct: Product
        switch listing {
        case .car, .realEstate, .service:
            editedProduct = ProductEditionParams.createProductParams(withListing: listing)
        case let .product(product):
            editedProduct = product
        }
        self.init(product: editedProduct)
    }
    
    init?(product: Product) {
        guard let productId = product.objectId, let userId = product.user.objectId else { return nil }
        self.productId = productId
        self.userId = userId
        let videos: [Video] = product.media.compactMap(LGVideo.init)
        super.init(name: product.name,
                   description: product.descr,
                   price: product.price,
                   category: product.category,
                   currency: product.currency,
                   location: product.location,
                   postalAddress: product.postalAddress,
                   images: product.images,
                   videos: videos)
        if let languageCode = product.languageCode {
            self.languageCode = languageCode
        }
    }
    
    func apiEditionEncode() -> [String: Any] {
        return super.apiCreationEncode(userId: userId)
    }
    
    static private func createProductParams(withListing listing: Listing) -> Product {
        let category: ListingCategory = listing.isCar ? .motorsAndAccessories : .unassigned
        let product = LGProduct(objectId: listing.objectId,
                                updatedAt: listing.updatedAt,
                                createdAt: listing.createdAt,
                                name: listing.name,
                                nameAuto: listing.nameAuto,
                                descr: listing.descr,
                                price: listing.price,
                                currency: listing.currency,
                                location: listing.location,
                                postalAddress: listing.postalAddress,
                                languageCode: listing.languageCode,
                                category: category,
                                status: listing.status,
                                thumbnail: listing.thumbnail,
                                thumbnailSize: listing.thumbnailSize,
                                images: listing.images,
                                media: listing.media,
                                mediaThumbnail: listing.mediaThumbnail,
                                user: listing.user,
                                featured: listing.featured)
        return product
    }
}
