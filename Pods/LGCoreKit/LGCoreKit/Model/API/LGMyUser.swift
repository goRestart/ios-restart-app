//
//  LGMyUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 04/12/15.
//  Copyright © 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation

public protocol User: BaseModel {
    var name: String? { get }
    var avatar: File? { get }
    var postalAddress: PostalAddress { get }
    
    var accounts: [Account] { get }
    var ratingAverage: Float? { get }
    var ratingCount: Int { get }
    
    var status: UserStatus { get }
    
    var isDummy: Bool { get }
}

public protocol MyUser: User {
    var email: String? { get }
    var location: LGLocation? { get }
    var localeIdentifier: String? { get }
}

public extension MyUser {
    var coordinates: LGLocationCoordinates2D? {
        guard let coordinates = location?.coordinate else { return nil }
        return LGLocationCoordinates2D(coordinates: coordinates)
    }
    var isDummy: Bool {
        let dummyRange = (email ?? "").range(of: "usercontent")
        if let isDummyRange = dummyRange, isDummyRange.lowerBound == (email ?? "").startIndex {
            return true
        } else {
            return false
        }
    }
    var postalAddress: PostalAddress {
        return location?.postalAddress ?? PostalAddress.emptyAddress()
    }
}

struct LGMyUser: MyUser, Decodable {
    var objectId: String?
    var name: String?
    var avatar: File?
    var accounts: [Account]
    var ratingAverage: Float?
    var ratingCount: Int
    var status: UserStatus
    var email: String?
    var location: LGLocation?
    var localeIdentifier: String?

    init(objectId: String?,
         name: String?,
         avatar: LGFile?,
         accounts: [Account],
         ratingAverage: Float?,
         ratingCount: Int,
         status: UserStatus?,
         email: String?,
         location: LGLocation?,
         localeIdentifier: String?) {
        
        self.objectId = objectId
        self.name = name
        self.avatar = avatar
        self.accounts = accounts
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.status = status ?? .active
        self.email = email
        self.location = location
        self.localeIdentifier = localeIdentifier
    }
    
    init(myUser: MyUser) {
        let accounts = myUser.accounts.map { LGAccount(account: $0) }
        let avatar = LGFile(id: myUser.avatar?.objectId, url: myUser.avatar?.fileURL)
        self.init(objectId: myUser.objectId,
                  name: myUser.name,
                  avatar: avatar,
                  accounts: accounts,
                  ratingAverage: myUser.ratingAverage,
                  ratingCount: myUser.ratingCount,
                  status: myUser.status,
                  email: myUser.email,
                  location: myUser.location,
                  localeIdentifier: myUser.localeIdentifier)
    }
    
    // MARK: - Decodable
    
    /*
     {
     "id": "string",
     "latitude": "decimal",
     "longitude": "decimal",
     "username": "string",
     "name": "string",
     "email": "string",
     "avatar_url": "string",
     "zip_code": "string",
     "address": "string",
     "city": "string",
     "country_code": "string",
     "is_richy": "boolean",
     "location_type": "string",
     "rating_value": "number"|null, // an unrated user or one whose ratings have been deleted will have a null
     "num_ratings": "integer",      // an unrated user or one whose ratings have been deleted will have a 0
     "accounts": [
     {
     "type": "string",
     "verified": "boolean"
     },
     {
     "type": "string",
     "verified": "boolean"
     }
     ],
     "locale": "string",
     "country": "string",
     "state": "string",
     "timezone": "string|null",
     "status": "string|null"
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decodeIfPresent(String.self, forKey: .objectId)
        name = try keyedContainer.decodeIfPresent(String.self, forKey: .name)
        email = try keyedContainer.decodeIfPresent(String.self, forKey: .email)
        if let latitude = try? keyedContainer.decode(Double.self, forKey: .latitude),
            let longitude = try? keyedContainer.decode(Double.self, forKey: .longitude),
            let postalAddress = try? PostalAddress(from: decoder) {
            let locationType = (try? keyedContainer.decode(LGLocationType.self, forKey: .locationType)) ?? .regional
            location = LGLocation(latitude: latitude,
                                  longitude: longitude,
                                  type: locationType,
                                  postalAddress: postalAddress)
        }

        if let avatarStringURL = try keyedContainer.decodeIfPresent(String.self, forKey: .avatar) {
            self.avatar = LGFile(id: nil, urlString: avatarStringURL)
        } else {
            self.avatar = nil
        }
        ratingAverage = try keyedContainer.decodeIfPresent(Float.self, forKey: .ratingAverage)
        ratingCount = try keyedContainer.decode(Int.self, forKey: .ratingCount)
        if let accounts = try keyedContainer.decodeIfPresent(FailableDecodableArray<LGAccount>.self, forKey: .accounts) {
            self.accounts = accounts.validElements
        } else {
            self.accounts = []
        }
        status = (try keyedContainer.decodeIfPresent(UserStatus.self, forKey: .status)) ?? .active
        localeIdentifier = try keyedContainer.decodeIfPresent(String.self, forKey: .localeIdentifier)
    }
    
    // TODO: some keys are only being used in repository, we may want to re-think this
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case name
        case email
        case password
        case latitude
        case longitude
        case locationType = "location_type"
        case avatar = "avatar_url"
        case address
        case city
        case state
        case zipCode = "zip_code"
        case countryCode = "country_code"
        case newsletter
        case ratingAverage = "rating_value"
        case ratingCount = "num_ratings"
        case accounts
        case status
        case localeIdentifier = "locale"
    }
}
