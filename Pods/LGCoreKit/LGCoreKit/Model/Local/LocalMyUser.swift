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
    var accounts: [Account]
    var ratingAverage: Float?
    var ratingCount: Int
    var status: UserStatus

    var phone: String?
    var type: UserType

    // MyUser
    var email: String?
    var location: LGLocation?
    var localeIdentifier: String?
    var creationDate: Date?
    var biography: String?
    var reputationPoints: Int
    
    init(objectId: String?, name: String?, avatar: File?, accounts: [LocalAccount],
         ratingAverage: Float?, ratingCount: Int, status: UserStatus, phone: String?, type: UserType?,
         email: String?, location: LGLocation?, localeIdentifier: String?, creationDate: Date?, biography: String?,
         reputationPoints: Int) {
        self.objectId = objectId
        
        self.name = name
        self.avatar = avatar
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.accounts = accounts
        self.status = status

        self.phone = phone
        self.type = type ?? .user
        
        self.email = email
        self.location = location
        self.localeIdentifier = localeIdentifier
        self.creationDate = creationDate
        self.biography = biography
        self.reputationPoints = reputationPoints
    }
    
    init(myUser: MyUser) {
        let localAccounts = myUser.accounts.map { LocalAccount(account: $0) }
        self.init(objectId: myUser.objectId, name: myUser.name, avatar: myUser.avatar, accounts: localAccounts,
                  ratingAverage: myUser.ratingAverage, ratingCount: myUser.ratingCount, status: myUser.status,
                  phone: myUser.phone, type: myUser.type, email: myUser.email, location: myUser.location,
                  localeIdentifier: myUser.localeIdentifier, creationDate: myUser.creationDate,
                  biography: myUser.biography, reputationPoints: myUser.reputationPoints)
    }
}


// MARK: - UserDefaultsDecodable

extension LocalMyUser {
    static func decode(_ dictionary: [String: Any]) -> LocalMyUser? {
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
        let state = dictionary[keys.state] as? String
        let countryCode = dictionary[keys.countryCode] as? String
        let country = dictionary[keys.country] as? String
        let postalAddress = PostalAddress(address: address, city: city, zipCode: zipCode, state: state,
                                            countryCode: countryCode, country: country)
        let email = dictionary[keys.email] as? String
        let locationTypeRaw = dictionary[keys.locationType] as? String ?? ""
        let locationType = LGLocationType(rawValue: locationTypeRaw) ?? .regional
        
        var location: LGLocation? = nil
        if let latitude = dictionary[keys.latitude] as? Double,
            let longitude = dictionary[keys.longitude] as? Double {
            let clLocation = CLLocation(latitude: latitude, longitude: longitude)
            location = LGLocation(location: clLocation, type: locationType, postalAddress: postalAddress)
        }
        var accounts: [LocalAccount] = []
        if let encodedAccounts = dictionary[keys.accounts] as? [[String : Any]] {
            accounts = encodedAccounts.compactMap { LocalAccount.decode($0) }
        }
        let ratingAverage = dictionary[keys.ratingAverage] as? Float
        let ratingCount = dictionary[keys.ratingCount] as? Int ?? 0
        var status = UserStatus.active
        if let statusStr = dictionary[keys.status] as? String,
            let udStatus = UserStatus(rawValue: statusStr) {
            status = udStatus
        }
        let phone = dictionary[keys.phone] as? String

        var type = UserType.user
        if let userTypeString = dictionary[keys.type] as? String,
            let userType = UserType(rawValue: userTypeString) {
            type = userType
        }

        let creationDateString = dictionary[keys.creationDate] as? String
        let creationDate = Date.userCreationDateFrom(string: creationDateString)

        let localeIdentifier = dictionary[keys.localeIdentifier] as? String
        let biography = dictionary[keys.biography] as? String
        let reputationPoints = dictionary[keys.reputationPoints] as? Int ?? 0
        return self.init(objectId: objectId, name: name, avatar: avatar,
                         accounts: accounts, ratingAverage: ratingAverage, ratingCount: ratingCount, status: status,
                         phone: phone, type: type, email: email, location: location, localeIdentifier: localeIdentifier,
                         creationDate: creationDate, biography: biography, reputationPoints: reputationPoints)
    }

    func encode() -> [String: Any] {
        var dictionary: [String: Any] = [:]
        let keys = MyUserUDKeys()
        dictionary[keys.objectId] = objectId
        dictionary[keys.name] = name
        dictionary[keys.avatar] = avatar?.fileURL?.absoluteString
        dictionary[keys.address] = postalAddress.address
        dictionary[keys.city] = postalAddress.city
        dictionary[keys.zipCode] = postalAddress.zipCode
        dictionary[keys.countryCode] = postalAddress.countryCode
        dictionary[keys.country] = postalAddress.country
        dictionary[keys.state] = postalAddress.state
        dictionary[keys.email] = email
        dictionary[keys.locationType] = location?.type.rawValue
        dictionary[keys.latitude] = location?.coordinate.latitude
        dictionary[keys.longitude] = location?.coordinate.longitude
        let encodedAccounts = accounts.map { LocalAccount(account: $0).encode() }
        dictionary[keys.accounts] = encodedAccounts
        dictionary[keys.ratingAverage] = ratingAverage
        dictionary[keys.ratingCount] = ratingCount
        dictionary[keys.status] = status.rawValue
        dictionary[keys.localeIdentifier] = localeIdentifier
        dictionary[keys.phone] = phone
        dictionary[keys.type] = type.rawValue
        dictionary[keys.creationDate] = Date.userCreationStringFrom(date: creationDate)
        dictionary[keys.biography] = biography
        dictionary[keys.reputationPoints] = reputationPoints
        return dictionary
    }
    
    private struct MyUserUDKeys {
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
        let state = "state"
        let countryCode = "countryCode"
        let country = "country"
        let accounts = "accounts"
        let ratingAverage = "ratingAverage"
        let ratingCount = "ratingCount"
        let status = "status"
        let localeIdentifier = "localeIdentifier"
        let phone = "phone"
        let type = "type"
        let creationDate = "creationDate"
        let biography = "biography"
        let reputationPoints = "reputation_points"
    }
}
