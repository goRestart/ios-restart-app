//
//  Listing.swift
//  LGCoreKit
//
//  Created by Nestor on 22/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

public enum Listing: BaseListingModel, Priceable, Decodable {
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
    
    
    // MARK: - Decodable
    
    /**
     Expects a json in the form of (many times):
     
     {
     "id": "0af7ebed-f285-4e84-8630-d1555ddbf102",
     "name": "",
     "category_id": 1,
     "language_code": "US",
     "description": "Selling a brand new, never opened FitBit, I'm asking for $75 negotiable.",
     "price": 75,
     "price_flag": 1,   // Can be 0 (normal), 1 (free), 2 (Negotiable), 3 (Firm price)
     "currency": "USD",
     "status": 1,
     "geo": {
     "lat": 40.733637875435,
     "lng": -73.982275536568,
     "country_code": "US",
     "city": "New York",
     "zip_code": "10003",
     "distance": 11.90776294472
     },
     "owner": {
     "id": "56da24a0-88d4-4956-a568-74739787051f",
     "name": "GeralD1507",
     "avatar_url": null,
     "zip_code": "10003",
     "country_code": "US",
     "is_richy": false,
     "city": "New York",
     "banned": null
     },
     "images": [{
     "url": "http:\/\/cdn.letgo.com\/images\/59\/1d\/f8\/22\/591df822060703afad9834d095ed4c2f.jpg",
     "id": "8ecdfe97-a7ed-4068-b4b8-c68a5ae63540"
     }],
     "thumb": {
     "url": "http:\/\/cdn.letgo.com\/images\/59\/1d\/f8\/22\/591df822060703afad9834d095ed4c2f_thumb.jpg",
     "width": 576,
     "height": 1024
     },
     "created_at": "2016-04-11T12:49:52+00:00",
     "updated_at": "2016-04-11T13:13:23+00:00",
     "image_information": "black fitbit wireless activity wristband",
     "featured": false
     }
     
     
     category_id will decide which type of listing should be parsed to
     
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        // Generic Listings: from Feed, Products search/filters, Cars search/filters
        if let categoryIdFeedAndProductsAndCars: Int = try keyedContainer.decodeIfPresent(Int.self, forKey: .categoryIdFeedAndProductsAndCars) {
            let category: ListingCategory = ListingCategory(rawValue: categoryIdFeedAndProductsAndCars) ?? .unassigned
            switch category {
            case .unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                 .fashionAndAccesories, .babyAndChild, .other:
                let product = try LGProduct(from: decoder)
                self = Listing.product(product)
            case .cars:
                let car = try LGCar(from: decoder)
                self = Listing.car(car)
            case .realEstate:
                let product = try LGProduct(from: decoder)
                let realEstate = LGRealEstate(product: product)
                self = Listing.realEstate(realEstate)
            }
            // New verticals listings, from New verticals search/filters
        } else if let categoryIdRealEstate: Int = try keyedContainer.decodeIfPresent(Int.self, forKey: .categoryIdNewVerticals) {
            if let category: ListingCategory = ListingCategory(rawValue: categoryIdRealEstate) {
                switch category {
                case .unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                     .fashionAndAccesories, .babyAndChild, .other, .cars:
                    throw DecodingError.typeMismatch(
                        Listing.self,
                        DecodingError.Context(codingPath: [],
                                              debugDescription: "invalid category for \(CodingKeys.categoryIdNewVerticals.rawValue)")
                    )
                case .realEstate:
                    let realEstate = try LGRealEstate(from: decoder)
                    self = Listing.realEstate(realEstate)
                }
            } else {
                throw DecodingError.typeMismatch(
                    Listing.self,
                    DecodingError.Context(codingPath: [],
                                          debugDescription: "Category not handled")
                )
            }
        } else {
            throw DecodingError.typeMismatch(
                Listing.self,
                DecodingError.Context(codingPath: [],
                                      debugDescription: "Could not parse category from \(decoder)")
            )
        }
    }
        
    enum CodingKeys: String, CodingKey {
        case categoryIdFeedAndProductsAndCars = "category_id"
        case categoryIdNewVerticals = "categoryId"
    }
}
