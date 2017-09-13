//
//  Listing.swift
//  LGCoreKit
//
//  Created by Nestor on 22/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public enum Listing: BaseListingModel, Priceable {
    case product(Product)
    case car(Car)
    case realEstate(RealEstate)
    
    public var isProduct: Bool {
        switch self {
        case .product: return true
        default: return false
        }
    }
    
    public var isCar: Bool {
        switch self {
        case .car: return true
        default: return false
        }
    }
    
    public var isRealEstate: Bool {
        switch self {
        case .realEstate: return true
        default: return false
        }
    }
    
    public var product: Product? {
        switch self {
        case .product(let product): return product
        default: return nil
        }
    }
    public var car: Car? {
        switch self {
        case .car(let car): return car
        default: return nil
        }
    }
    public var realEstate: RealEstate? {
        switch self {
        case .realEstate(let realEstate): return realEstate
        default: return nil
        }
    }
    
    // Variables
    
    public var objectId: String? {
        switch self {
        case .product(let product): return product.objectId
        case .car(let car): return car.objectId
        case .realEstate(let realEstate): return realEstate.objectId
        }
    }
    
    public var name: String? {
        switch self {
        case .product(let product): return product.name
        case .car(let car): return car.name
        case .realEstate(let realEstate): return realEstate.name
        }
    }
    public var nameAuto: String? {
        switch self {
        case .product(let product): return product.nameAuto
        case .car(let car): return car.nameAuto
        case .realEstate(let realEstate): return realEstate.nameAuto
        }
    }
    public var descr: String? {
        switch self {
        case .product(let product): return product.descr
        case .car(let car): return car.descr
        case .realEstate(let realEstate): return realEstate.descr
        }
    }
    public var price: ListingPrice {
        switch self {
        case .product(let product): return product.price
        case .car(let car): return car.price
        case .realEstate(let realEstate): return realEstate.price
        }
    }
    public var currency: Currency {
        switch self {
        case .product(let product): return product.currency
        case .car(let car): return car.currency
        case .realEstate(let realEstate): return realEstate.currency
        }
    }
    public var location: LGLocationCoordinates2D {
        switch self {
        case .product(let product): return product.location
        case .car(let car): return car.location
        case .realEstate(let realEstate): return realEstate.location
        }
    }
    public var postalAddress: PostalAddress {
        switch self {
        case .product(let product): return product.postalAddress
        case .car(let car): return car.postalAddress
        case .realEstate(let realEstate): return realEstate.postalAddress
        }
    }
    public var languageCode: String? {
        switch self {
        case .product(let product): return product.languageCode
        case .car(let car): return car.languageCode
        case .realEstate(let realEstate): return realEstate.languageCode
        }
    }
    public var category: ListingCategory {
        switch self {
        case .product(let product): return product.category
        case .car(let car): return car.category
        case .realEstate(let realEstate): return realEstate.category
        }
    }
    public var status: ListingStatus {
        switch self {
        case .product(let product): return product.status
        case .car(let car): return car.status
        case .realEstate(let realEstate): return realEstate.status
        }
    }
    public var thumbnail: File? {
        switch self {
        case .product(let product): return product.thumbnail
        case .car(let car): return car.thumbnail
        case .realEstate(let realEstate): return realEstate.thumbnail
        }
    }
    public var thumbnailSize: LGSize? {
        switch self {
        case .product(let product): return product.thumbnailSize
        case .car(let car): return car.thumbnailSize
        case .realEstate(let realEstate): return realEstate.thumbnailSize
        }
    }
    public var images: [File] {
        switch self {
        case .product(let product): return product.images
        case .car(let car): return car.images
        case .realEstate(let realEstate): return realEstate.images
        }
    }
    public var user: UserListing {
        switch self {
        case .product(let product): return product.user
        case .car(let car): return car.user
        case .realEstate(let realEstate): return realEstate.user
        }
    }
    public var updatedAt: Date? {
        switch self {
        case .product(let product): return product.updatedAt
        case .car(let car): return car.updatedAt
        case .realEstate(let realEstate): return realEstate.updatedAt
        }
    }
    public var createdAt: Date? {
        switch self {
        case .product(let product): return product.createdAt
        case .car(let car): return car.createdAt
        case .realEstate(let realEstate): return realEstate.createdAt
        }
    }
    public var featured: Bool? {
        switch self {
        case .product(let product): return product.featured
        case .car(let car): return car.featured
        case .realEstate(let realEstate): return realEstate.featured
        }
    }
    public var favorite: Bool {
        switch self {
        case .product(let product): return product.favorite
        case .car(let car): return car.favorite
        case .realEstate(let realEstate): return realEstate.favorite
        }
    }
    
    // Methods
    
    func updating(category: ListingCategory) -> Listing {
        switch self {
        case .product(let product):
            let lgProduct = LGProduct(product: product)
            let newProduct = lgProduct.updating(category: category)
            return Listing.product(newProduct)
        case .car(let car):
            let lgCar = LGCar(car: car)
            let newCar = lgCar.updating(category: category)
            return Listing.car(newCar)
        case .realEstate(let realEstate):
            let lgRealEstate = LGRealEstate(realEstate: realEstate)
            let newRealEstate = lgRealEstate.updating(category: category)
            return Listing.realEstate(newRealEstate)
        }
    }
    
    func updating(status: ListingStatus) -> Listing {
        switch self {
        case .product(let product):
            let lgProduct = LGProduct(product: product)
            let newProduct = lgProduct.updating(status: status)
            return Listing.product(newProduct)
        case .car(let car):
            let lgCar = LGCar(car: car)
            let newCar = lgCar.updating(status: status)
            return Listing.car(newCar)
        case .realEstate(let realEstate):
            let lgRealEstate = LGRealEstate(realEstate: realEstate)
            let newRealEstate = lgRealEstate.updating(status: status)
            return Listing.realEstate(newRealEstate)
        }
    }
}
