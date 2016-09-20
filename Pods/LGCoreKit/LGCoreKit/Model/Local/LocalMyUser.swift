//
//  LocalMyUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 14/04/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import CoreLocation

struct LocalMyUser: MyUser, UserDefaultsDecodable {
    // BaseModel
    var objectId: String?

    // User
    var name: String?
    var avatar: File?
    var postalAddress: PostalAddress

    var accounts: [Account]?    // TODO: When switching to bouncer only make ratings & accounts non-optional
    var ratingAverage: Float?
    var ratingCount: Int?

    var status: UserStatus

    // MyUser
    var email: String?
    var location: LGLocation?
    var localeIdentifier: String?

    init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, accounts: [LocalAccount]?,
         ratingAverage: Float?, ratingCount: Int?, status: UserStatus, email: String?, location: LGLocation?,
         localeIdentifier: String?) {
        self.objectId = objectId

        self.name = name
        self.avatar = avatar
        self.postalAddress = postalAddress

        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.accounts = accounts?.map { $0 as Account }

        self.status = status

        self.email = email
        self.location = location
        self.localeIdentifier = localeIdentifier
    }

    init(myUser: MyUser) {
        let localAccounts = myUser.accounts?.map { LocalAccount(account: $0) }
        self.init(objectId: myUser.objectId, name: myUser.name, avatar: myUser.avatar,
                  postalAddress: myUser.postalAddress, accounts: localAccounts,
                  ratingAverage: myUser.ratingAverage, ratingCount: myUser.ratingCount, status: myUser.status,
                  email: myUser.email, location: myUser.location, localeIdentifier: myUser.localeIdentifier)
    }
}


// MARK: - UserDefaultsDecodable

protocol LGMyUserUDKeys: LGMyUserKeys {
    var country: String { get }
}

private struct MyUserUDKeys: LGMyUserUDKeys {
    let objectId = "objectId"
    let name = "name"
    let email = "email"
    let latitude = "latitude"
    let longitude = "longitude"
    let locationType = "locationType"
    let avatar = "avatar"
    let address = "address"
    let city = "city"
    let zipCode = "zipCode"
    let countryCode = "countryCode"
    let country = "country"
    let accounts = "accounts"
    let ratingAverage = "ratingAverage"
    let ratingCount = "ratingCount"
    let status = "status"
    let localeIdentifier = "localeIdentifier"
}

extension LocalMyUser {
    static func decode(dictionary: [String: AnyObject]) -> LocalMyUser? {
        let keys = MyUserUDKeys()
        let objectId = dictionary[keys.objectId] as? String
        let name = dictionary[keys.name] as? String
        var avatar: File? = nil
        if let avatarURL = dictionary[keys.avatar] as? String {
            avatar = LGFile(id: nil, urlString: avatarURL)
        }
        let address = dictionary[keys.address] as? String
        let city = dictionary[keys.city] as? String
        let zipCode = dictionary[keys.zipCode] as? String
        let countryCode = dictionary[keys.countryCode] as? String
        let country = dictionary[keys.country] as? String
        let postalAddress = PostalAddress(address: address, city: city, zipCode: zipCode, countryCode: countryCode, country: country)
        let email = dictionary[keys.email] as? String
        var locationType: LGLocationType? = nil
        if let locationTypeRaw = dictionary[keys.locationType] as? String {
            locationType = LGLocationType(rawValue: locationTypeRaw)
        }
        var location: LGLocation? = nil
        if let latitude = dictionary[keys.latitude] as? Double, let longitude = dictionary[keys.longitude] as? Double {
            let clLocation = CLLocation(latitude: latitude, longitude: longitude)
            location = LGLocation(location: clLocation, type: locationType)
        }
        var accounts: [LocalAccount]? = nil
        if let encodedAccounts = dictionary[keys.accounts] as? [[String : AnyObject]] {
            accounts = encodedAccounts.flatMap { LocalAccount.decode($0) }
        }
        let ratingAverage = dictionary[keys.ratingAverage] as? Float
        let ratingCount = dictionary[keys.ratingCount] as? Int
        var status = UserStatus.Active
        if let statusStr = dictionary[keys.status] as? String, udStatus = UserStatus(rawValue: statusStr) {
            status = udStatus
        }
        let localeIdentifier = dictionary[keys.localeIdentifier] as? String
        return self.init(objectId: objectId, name: name, avatar: avatar, postalAddress: postalAddress,
                         accounts: accounts, ratingAverage: ratingAverage, ratingCount: ratingCount, status: status,
                         email: email, location: location, localeIdentifier: localeIdentifier)
    }

    func encode() -> [String: AnyObject] {
        let keys = MyUserUDKeys()
        return encode(keys)
    }

    func encode(keys: LGMyUserUDKeys) -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        dictionary[keys.objectId] = objectId
        dictionary[keys.name] = name
        dictionary[keys.avatar] = avatar?.fileURL?.URLString
        dictionary[keys.address] = postalAddress.address
        dictionary[keys.city] = postalAddress.city
        dictionary[keys.zipCode] = postalAddress.zipCode
        dictionary[keys.countryCode] = postalAddress.countryCode
        dictionary[keys.country] = postalAddress.country
        dictionary[keys.email] = email
        dictionary[keys.locationType] = location?.type?.rawValue
        dictionary[keys.latitude] = location?.coordinate.latitude
        dictionary[keys.longitude] = location?.coordinate.longitude
        var encodedAccounts: [[String : AnyObject]]? = nil
        if let accounts = accounts {
            encodedAccounts = accounts.map { LocalAccount(account: $0).encode() }
        }
        dictionary[keys.accounts] = encodedAccounts
        dictionary[keys.ratingAverage] = ratingAverage
        dictionary[keys.ratingCount] = ratingCount
        dictionary[keys.status] = status.rawValue
        dictionary[keys.localeIdentifier] = localeIdentifier

        return dictionary
    }
}
