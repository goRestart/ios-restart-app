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

    init(objectId: String?, name: String?, avatar: File?, postalAddress: PostalAddress, accounts: [LocalAccount]?,
         ratingAverage: Float?, ratingCount: Int?, status: UserStatus, email: String?, location: LGLocation?) {
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
    }

    init(myUser: MyUser) {
        let localAccounts = myUser.accounts?.map { LocalAccount(account: $0) }
        self.init(objectId: myUser.objectId, name: myUser.name, avatar: myUser.avatar,
                  postalAddress: myUser.postalAddress, accounts: localAccounts,
                  ratingAverage: myUser.ratingAverage, ratingCount: myUser.ratingCount, status: myUser.status,
                  email: myUser.email, location: myUser.location)
    }
}


// MARK: - UserDefaultsDecodable

private struct MyUserUDKeys {
    static let objectId = "objectId"
    static let name = "name"
    static let email = "email"
    static let latitude = "latitude"
    static let longitude = "longitude"
    static let locationType = "locationType"
    static let avatar = "avatar"
    static let address = "address"
    static let city = "city"
    static let zipCode = "zipCode"
    static let countryCode = "countryCode"
    static let country = "country"
    static let accounts = "accounts"
    static let ratingAverage = "ratingAverage"
    static let ratingCount = "ratingCount"
    static let status = "status"
}

extension LocalMyUser {
    static func decode(dictionary: [String: AnyObject]) -> LocalMyUser? {
        let objectId = dictionary[MyUserUDKeys.objectId] as? String
        let name = dictionary[MyUserUDKeys.name] as? String
        var avatar: File? = nil
        if let avatarURL = dictionary[MyUserUDKeys.avatar] as? String {
            avatar = LGFile(id: nil, urlString: avatarURL)
        }
        let address = dictionary[MyUserUDKeys.address] as? String
        let city = dictionary[MyUserUDKeys.city] as? String
        let zipCode = dictionary[MyUserUDKeys.zipCode] as? String
        let countryCode = dictionary[MyUserUDKeys.countryCode] as? String
        let country = dictionary[MyUserUDKeys.country] as? String
        let postalAddress = PostalAddress(address: address, city: city, zipCode: zipCode, countryCode: countryCode, country: country)
        let email = dictionary[MyUserUDKeys.email] as? String
        var locationType: LGLocationType? = nil
        if let locationTypeRaw = dictionary[MyUserUDKeys.locationType] as? String {
            locationType = LGLocationType(rawValue: locationTypeRaw)
        }
        var location: LGLocation? = nil
        if let latitude = dictionary[MyUserUDKeys.latitude] as? Double, let longitude = dictionary[MyUserUDKeys.longitude] as? Double {
            let clLocation = CLLocation(latitude: latitude, longitude: longitude)
            location = LGLocation(location: clLocation, type: locationType)
        }
        var accounts: [LocalAccount]? = nil
        if let encodedAccounts = dictionary[MyUserUDKeys.accounts] as? [[String : AnyObject]] {
            accounts = encodedAccounts.flatMap { LocalAccount.decode($0) }
        }
        let ratingAverage = dictionary[MyUserUDKeys.ratingAverage] as? Float
        let ratingCount = dictionary[MyUserUDKeys.ratingCount] as? Int
        var status = UserStatus.Active
        if let statusStr = dictionary[MyUserUDKeys.status] as? String, udStatus = UserStatus(rawValue: statusStr) {
            status = udStatus
        }
        return self.init(objectId: objectId, name: name, avatar: avatar, postalAddress: postalAddress,
                         accounts: accounts, ratingAverage: ratingAverage, ratingCount: ratingCount, status: status,
                         email: email, location: location)
    }

    func encode() -> [String: AnyObject] {
        var dictionary: [String: AnyObject] = [:]
        dictionary[MyUserUDKeys.objectId] = objectId
        dictionary[MyUserUDKeys.name] = name
        dictionary[MyUserUDKeys.avatar] = avatar?.fileURL?.URLString
        dictionary[MyUserUDKeys.address] = postalAddress.address
        dictionary[MyUserUDKeys.city] = postalAddress.city
        dictionary[MyUserUDKeys.zipCode] = postalAddress.zipCode
        dictionary[MyUserUDKeys.countryCode] = postalAddress.countryCode
        dictionary[MyUserUDKeys.country] = postalAddress.country
        dictionary[MyUserUDKeys.email] = email
        dictionary[MyUserUDKeys.locationType] = location?.type?.rawValue
        dictionary[MyUserUDKeys.latitude] = location?.coordinate.latitude
        dictionary[MyUserUDKeys.longitude] = location?.coordinate.longitude
        var encodedAccounts: [[String : AnyObject]]? = nil
        if let accounts = accounts {
            encodedAccounts = accounts.map { LocalAccount(account: $0).encode() }
        }
        dictionary[MyUserUDKeys.accounts] = encodedAccounts
        dictionary[MyUserUDKeys.ratingAverage] = ratingAverage
        dictionary[MyUserUDKeys.ratingCount] = ratingCount
        dictionary[MyUserUDKeys.status] = status.rawValue

        return dictionary
    }
}
