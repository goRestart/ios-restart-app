//
//  ListingParams.swift
//  LGCoreKit
//
//  Created by Nestor on 27/04/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public class BaseListingParams {
    public var name: String?
    public var descr: String?
    public var price: ListingPrice
    public var category: ListingCategory
    public var currency: Currency
    public var location: LGLocationCoordinates2D
    public var postalAddress: PostalAddress
    public var images: [File]
    var languageCode: String

    public init(name: String?,
                description: String?,
                price: ListingPrice,
                category: ListingCategory,
                currency: Currency,
                location: LGLocationCoordinates2D,
                postalAddress: PostalAddress,
                languageCode: String,
                images: [File]) {
        self.name = name
        self.descr = description
        self.price = price
        self.category = category
        self.currency = currency
        self.location = location
        self.postalAddress = postalAddress
        self.languageCode = languageCode
        self.images = images
    }

    func apiCreationEncode(userId: String) -> [String: Any] {
        var params: [String: Any] = [:]
        params["name"] = name
        params["category"] = category.rawValue
        params["languageCode"] = languageCode
        params["userId"] = userId
        params["description"] = descr
        params["price"] = price.value
        params["price_flag"] = price.priceFlag.rawValue
        params["currency"] = currency.code
        params["latitude"] = location.latitude
        params["longitude"] = location.longitude
        params["countryCode"] = postalAddress.countryCode
        params["city"] = postalAddress.city
        params["address"] = postalAddress.address
        params["zipCode"] = postalAddress.zipCode

        let tokensString = images.flatMap{$0.objectId}.map{"\"" + $0 + "\""}.joined(separator: ",")
        params["images"] = "[" + tokensString + "]"

        return params
    }
}

public enum ListingEditionParams {
    case product(ProductEditionParams)
    case car(CarEditionParams)
    
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
    
    // MARK: - Variables
    
    public var listingId: String? {
        switch self {
        case .product(let productParams): return productParams.productId
        case .car(let carParams): return carParams.carId
        }
    }
    
    public var userId: String? {
        switch self {
        case .product(let productParams): return productParams.userId
        case .car(let carParams): return carParams.userId
        }
    }
    
    public var name: String? {
        switch self {
        case .product(let productParams): return productParams.name
        case .car(let carParams): return carParams.name
        }
    }
    
    public var descr: String? {
        switch self {
        case .product(let productParams): return productParams.descr
        case .car(let carParams): return carParams.descr
        }
    }
    
    public var price: ListingPrice {
        switch self {
        case .product(let productParams): return productParams.price
        case .car(let carParams): return carParams.price
        }
    }
    
    public var category: ListingCategory {
        switch self {
        case .product(let productParams): return productParams.category
        case .car(let carParams): return carParams.category
        }
    }
    
    public var currency: Currency {
        switch self {
        case .product(let productParams): return productParams.currency
        case .car(let carParams): return carParams.currency
        }
    }
    
    public var location: LGLocationCoordinates2D {
        switch self {
        case .product(let productParams): return productParams.location
        case .car(let carParams): return carParams.location
        }
    }
    
    public var postalAddress: PostalAddress {
        switch self {
        case .product(let productParams): return productParams.postalAddress
        case .car(let carParams): return carParams.postalAddress
        }
    }
    
    public var images: [File] {
        switch self {
        case .product(let productParams): return productParams.images
        case .car(let carParams): return carParams.images
        }
    }

    var languageCode: String {
        switch self {
        case .product(let productParams): return productParams.languageCode
        case .car(let carParams): return carParams.languageCode
        }
    }
    
    // MARK: - Methods
    
    public func apiEncode(userId: String) -> [String: Any] {
        switch self {
        case .product(let productParams): return productParams.apiEditionEncode()
        case .car(let carParams): return carParams.apiEditionEncode()
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
        }
    }
}

public enum ListingCreationParams {
    case product(ProductCreationParams)
    case car(CarCreationParams)
    
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
        }
    }

    // MARK: - Variables
    
    public var name: String? {
        switch self {
        case .product(let productParams): return productParams.name
        case .car(let carParams): return carParams.name
        }
    }
    
    public var descr: String? {
        switch self {
        case .product(let productParams): return productParams.descr
        case .car(let carParams): return carParams.descr
        }
    }
    
    public var price: ListingPrice {
        switch self {
        case .product(let productParams): return productParams.price
        case .car(let carParams): return carParams.price
        }
    }
    
    public var category: ListingCategory {
        switch self {
        case .product(let productParams): return productParams.category
        case .car(let carParams): return carParams.category
        }
    }
    
    public var currency: Currency {
        switch self {
        case .product(let productParams): return productParams.currency
        case .car(let carParams): return carParams.currency
        }
    }
    
    public var location: LGLocationCoordinates2D {
        switch self {
        case .product(let productParams): return productParams.location
        case .car(let carParams): return carParams.location
        }
    }
    
    public var postalAddress: PostalAddress {
        switch self {
        case .product(let productParams): return productParams.postalAddress
        case .car(let carParams): return carParams.postalAddress
        }
    }
    
    public var images: [File] {
        switch self {
        case .product(let productParams): return productParams.images
        case .car(let carParams): return carParams.images
        }
    }
    
    // MARK: - Methods
    
    public func apiEncode(userId: String) -> [String: Any] {
        switch self {
        case .product(let productParams): return productParams.apiCreationEncode(userId: userId)
        case .car(let carParams): return carParams.apiCreationEncode(userId: userId)
        }
    }
}
