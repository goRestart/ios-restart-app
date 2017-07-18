//
//  PostalAddress.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

public struct PostalAddress: Equatable {
    public let address: String?
    public let city: String?
    public let zipCode: String?
    public let state: String?
    public let countryCode: String?
    public let country : String?
    public init(address: String?, city: String?, zipCode: String?, state: String?, countryCode: String?, country: String?) {
        self.address = address
        self.city = city
        self.zipCode = zipCode
        self.state = state
        self.countryCode = countryCode
        self.country = country
    }

    public static func emptyAddress() -> PostalAddress {
        return PostalAddress(address: nil, city: nil, zipCode: nil, state: nil, countryCode: nil, country: nil)
    }
}

public func ==(lhs: PostalAddress, rhs: PostalAddress) -> Bool {
    return lhs.address == rhs.address && lhs.city == rhs.city &&
        lhs.zipCode == rhs.zipCode && lhs.state == rhs.state &&
        lhs.countryCode == rhs.countryCode && lhs.country == rhs.country
}

extension PostalAddress : Decodable {

    /**
    Expects a json in the form:

        {
            "address": "Superhero ave, 3",
            "zip_code": "33948",
            "city": "Gotham",
            "state" : "Quieto"
            "country_code": "ES",
            "country" : "España"
        }
    */
    public static func decode(_ j: JSON) -> Decoded<PostalAddress> {
        let result1 = curry(PostalAddress.init)
        let result2 = result1 <^> j <|? "address"
        let result3 = result2 <*> j <|? "city"
        let result4 = result3 <*> j <|? "zip_code"
        let result5 = result4 <*> j <|? "state"
        let result6 = result5 <*> j <|? "country_code"
        let result  = result6 <*> j <|? "country"
        if let error = result.error {
            logMessage(.error, type: CoreLoggingOptions.parsing, message: "PostalAddress parse error: \(error)")
        }
        return result
    }
}
