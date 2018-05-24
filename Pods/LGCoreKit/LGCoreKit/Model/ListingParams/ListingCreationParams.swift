//
//  ListingParams.swift
//  LGCoreKit
//
//  Created by Nestor on 27/04/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public enum ListingCreationParams {
    case product(ProductCreationParams)
    case car(CarCreationParams)
    case realEstate(RealEstateCreationParams)
    
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
    
    public var productParams: ProductCreationParams? {
        switch self {
        case .product(let productParams): return productParams
        default: return nil
        }
    }
    
    public var carParams: CarCreationParams? {
        switch self {
        case .car(let carParams): return carParams
        default: return nil
        }
    }
    
    public var realEstateParams: RealEstateCreationParams? {
        switch self {
        case .realEstate(let realEstateParams): return realEstateParams
        default: return nil
        }
    }
    
    public func updating(images: [File]) -> ListingCreationParams {
        switch self {
        case .product(let productParams):
            let newParams = productParams
            newParams.images = images
            return ListingCreationParams.product(newParams)
        case .car(let carParams):
            let newParams = carParams
            newParams.images = images
            return ListingCreationParams.car(newParams)
        case .realEstate(let realEstateParams):
            let newParams = realEstateParams
            newParams.images = images
            return ListingCreationParams.realEstate(newParams)
        }
    }

    public func updating(videos: [Video]) -> ListingCreationParams {
        switch self {
        case .product(let productParams):
            let newParams = productParams
            newParams.videos = videos
            return ListingCreationParams.product(newParams)
        case .car(let carParams):
            let newParams = carParams
            newParams.videos = videos
            return ListingCreationParams.car(newParams)
        case .realEstate(let realEstateParams):
            let newParams = realEstateParams
            newParams.videos = videos
            return ListingCreationParams.realEstate(newParams)
        }
    }

    // MARK: - Variables
    
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

    // MARK: - Methods
    
    public func apiEncode(userId: String) -> [String: Any] {
        switch self {
        case .product(let productParams): return productParams.apiCreationEncode(userId: userId)
        case .car(let carParams): return carParams.apiCreationEncode(userId: userId)
        case .realEstate(let realEstateParams): return realEstateParams.apiCreationEncode(userId: userId)
        }
    }
}
