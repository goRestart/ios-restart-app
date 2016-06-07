//
//  PostalAddress.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

public struct PostalAddress: Equatable {
    public let address: String?
    public let city: String?
    public let zipCode: String?
    public let countryCode: String?
    public let country : String?
    public init(address: String?, city: String?, zipCode: String?, countryCode: String?, country: String?) {
        self.address = address
        self.city = city
        self.zipCode = zipCode
        self.countryCode = countryCode
        self.country = country
    }

    public static func emptyAddress() -> PostalAddress {
        return PostalAddress(address: nil, city: nil, zipCode: nil, countryCode: nil, country: nil)
    }
}

public func ==(lhs: PostalAddress, rhs: PostalAddress) -> Bool {
    return lhs.address == rhs.address && lhs.city == rhs.city &&
        lhs.zipCode == rhs.zipCode && lhs.countryCode == rhs.countryCode &&
        lhs.country == rhs.country
}

extension PostalAddress : Decodable {

    /**
    Expects a json in the form:

        {
            "address": "Superhero ave, 3",
            "zip_code": "33948",
            "city": "Gotham",
            "country_code": "ES",
            "country" : "España"
        }
    */
    public static func decode(j: JSON) -> Decoded<PostalAddress> {
        return curry(PostalAddress.init)
            <^> j <|? "address"
            <*> j <|? "city"
            <*> j <|? "zip_code"
            <*> j <|? "country_code"
            <*> j <|? "country"
    }
}
