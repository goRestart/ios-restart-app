//
//  ListingCreationParams.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 19/09/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public enum ListingEditionParams {
    case product(ProductEditionParams)
    case car(CarEditionParams)
    case realEstate(RealEstateEditionParams)
    
    // MARK: - Helpers
    
    public var isProductParams: Bool {
        switch self {
        case .product: return true
        default: return false
        }
    }
    
    public var isCarParams: Bool {
        switch self {
        case .car: return true
        default: return false
        }
    }
    
    public var isRealEstateParams: Bool {
        switch self {
        case .realEstate: return true
        default: return false
        }
    }
    
    public var productParams: ProductEditionParams? {
        switch self {
        case .product(let productParams): return productParams
        default: return nil
        }
    }
    
    public var carParams: CarEditionParams? {
        switch self {
        case .car(let carParams): return carParams
        default: return nil
        }
    }
    
    public var realEstateParams: RealEstateEditionParams? {
        switch self {
        case .realEstate(let realEstateParams): return realEstateParams
        default: return nil
        }
    }
    
    // MARK: - Variables
    
    public var listingId: String? {
        switch self {
        case .product(let productParams): return productParams.productId
        case .car(let carParams): return carParams.carId
        case .realEstate(let realEstateParams): return realEstateParams.realEstateId
        }
    }
    
    public var userId: String? {
        switch self {
        case .product(let productParams): return productParams.userId
        case .car(let carParams): return carParams.userId
        case .realEstate(let realEstateParams): return realEstateParams.userId
        }
    }
    
    public var name: String? {
        switch self {
        case .product(let productParams): return productParams.name
        case .car(let carParams): return carParams.name
        case .realEstate(let realEstateParams): return realEstateParams.name
        }
    }
    
    public var descr: String? {
        switch self {
        case .product(let productParams): return productParams.descr
        case .car(let carParams): return carParams.descr
        case .realEstate(let realEstateParams): return realEstateParams.descr
        }
    }
    
    public var price: ListingPrice {
        switch self {
        case .product(let productParams): return productParams.price
        case .car(let carParams): return carParams.price
        case .realEstate(let realEstateParams): return realEstateParams.price
        }
    }
    
    public var category: ListingCategory {
        switch self {
        case .product(let productParams): return productParams.category
        case .car(let carParams): return carParams.category
        case .realEstate(let realEstateParams): return realEstateParams.category
        }
    }
    
    public var currency: Currency {
        switch self {
        case .product(let productParams): return productParams.currency
        case .car(let carParams): return carParams.currency
        case .realEstate(let realEstateParams): return realEstateParams.currency
        }
    }
    
    public var location: LGLocationCoordinates2D {
        switch self {
        case .product(let productParams): return productParams.location
        case .car(let carParams): return carParams.location
        case .realEstate(let realEstateParams): return realEstateParams.location
        }
    }
    
    public var postalAddress: PostalAddress {
        switch self {
        case .product(let productParams): return productParams.postalAddress
        case .car(let carParams): return carParams.postalAddress
        case .realEstate(let realEstateParams): return realEstateParams.postalAddress
        }
    }
    
    public var images: [File] {
        switch self {
        case .product(let productParams): return productParams.images
        case .car(let carParams): return carParams.images
        case .realEstate(let realEstateParams): return realEstateParams.images
        }
    }

    public var videos: [Video] {
        switch self {
        case .product(let productParams): return productParams.videos
        case .car(let carParams): return carParams.videos
        case .realEstate(let realEstateParams): return realEstateParams.videos
        }
    }
    
    var languageCode: String {
        switch self {
        case .product(let productParams): return productParams.languageCode
        case .car(let carParams): return carParams.languageCode
        case .realEstate(let realEstateParams): return realEstateParams.languageCode
        }
    }
    
    // MARK: - Methods
    
    public func apiEncode(userId: String) -> [String: Any] {
        switch self {
        case .product(let productParams): return productParams.apiEditionEncode()
        case .car(let carParams): return carParams.apiEditionEncode()
        case .realEstate(let realEstateParams): return realEstateParams.apiEditionEncode()
        }
    }
    
    public func updating(images: [File]) -> ListingEditionParams {
        switch self {
        case .product(let productParams):
            let newParams = productParams
            newParams.images = images
            return ListingEditionParams.product(newParams)
        case .car(let carParams):
            let newParams = carParams
            newParams.images = images
            return ListingEditionParams.car(newParams)
        case .realEstate(let realEstateParams):
            let newParams = realEstateParams
            newParams.images = images
            return ListingEditionParams.realEstate(newParams)
        }
    }

    public func updating(videos: [Video]) -> ListingEditionParams {
        switch self {
        case .product(let productParams):
            let newParams = productParams
            newParams.videos = videos
            return ListingEditionParams.product(newParams)
        case .car(let carParams):
            let newParams = carParams
            newParams.videos = videos
            return ListingEditionParams.car(newParams)
        case .realEstate(let realEstateParams):
            let newParams = realEstateParams
            newParams.videos = videos
            return ListingEditionParams.realEstate(newParams)
        }
    }
}
