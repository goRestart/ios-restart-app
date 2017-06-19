//
//  LGListing.swift
//  LGCoreKit
//
//  Created by Nestor on 21/03/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

extension Listing: Decodable  {
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

    public static func decode(_ j: JSON) -> Decoded<Listing> {

        // to guarantee compatibility with future categories
        var category: ListingCategory = .unassigned

        if let categoryId: Int = j.decode("category_id"),
            let listingCategory: ListingCategory = ListingCategory(rawValue: categoryId) {
            category = listingCategory
        }

        let result: Decoded<Listing>
        switch category {
            // Products or unknown categories
        case .unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
             .fashionAndAccesories, .babyAndChild, .other:
            result = curry(Listing.product)
                <^> LGProduct.decode(j)
            break
            // Cars
        case .cars:
            result = curry(Listing.car)
                <^> LGCar.decode(j)
            break
        }
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "Listing parse error: \(error)")
        }
        return result
    }
}

extension ListingPriceFlag: Decodable {}

