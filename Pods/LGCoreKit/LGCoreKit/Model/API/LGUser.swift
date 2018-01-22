//
//  LGUser.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 02/06/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

struct LGUser: User, Decodable {
    private static let statusDefaultValue: UserStatus = .active
    
    let objectId: String?

    let name: String?
    let avatar: File?
    let postalAddress: PostalAddress

    let ratingAverage: Float?
    let ratingCount: Int
    let accounts: [Account]

    let status: UserStatus

    var isDummy: Bool

    var phone: String?
    var type: UserType


    // MARK: - Lifecycle

    init(objectId: String?,
         name: String?,
         avatar: String?,
         postalAddress: PostalAddress,
         ratingAverage: Float?,
         ratingCount: Int,
         accounts: [LGAccount],
         status: UserStatus?,
         isDummy: Bool,
         phone: String?,
         type: UserType) {
        self.objectId = objectId
        self.name = name
        self.avatar = LGFile(id: nil, urlString: avatar)
        self.postalAddress = postalAddress
        self.ratingAverage = ratingAverage
        self.ratingCount = ratingCount
        self.accounts = accounts
        self.status = status ?? .active
        self.isDummy = isDummy
        self.phone = phone
        self.type = type
    }
    
    init(chatInterlocutor: ChatInterlocutor) {
        let postalAddress = PostalAddress.emptyAddress()
        self.init(objectId: chatInterlocutor.objectId,
                  name: chatInterlocutor.name,
                  avatar: chatInterlocutor.avatar?.fileURL?.absoluteString,
                  postalAddress: postalAddress,
                  ratingAverage: nil,
                  ratingCount: 0,
                  accounts: [],
                  status: chatInterlocutor.status,
                  isDummy: false,
                  phone: nil,
                  type: .user)
    }
    
    
    // MARK: - Decodable
    
    /**
    Decodes a json in the form:
    {
        "id": "d67a38d4-6a80-4ca7-a54e-ccf0c57076a3",
        "username": "119750508403100",      // not parsed
        "name": "Sara G.",
        "email": "aras_0212@hotmail.com",
        "phone": string,
        "type": string ("professional"/"user"),
        "avatar_url": "https:\/\/s3.amazonaws.com\/letgo-avatars-pro\/images\/98\/ef\/d3\/4a\/98efd34ae8ba6a879dba60706152b131b8a64d45bf0c4ae043a39caa5d3774bc.jpg",
        "zip_code": "",
        "address": "New York NY",
        "city": "New York",
        "country_code": "US",
        "is_richy": false,
        "rating_value": "number"|null,      // an unrated user or one whose ratings have been deleted will have a null
        "num_ratings": "integer",           // an unrated user or one whose ratings have been deleted will have a 0
        "accounts": [{
            "type": "facebook",
            "verified": false
        }, {
            "type": "letgo",
            "verified": true
        }],
        "status": "active"
    }
    */

    
    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        self.objectId = try keyedContainer.decodeIfPresent(String.self, forKey: .id)
        self.name = try keyedContainer.decodeIfPresent(String.self, forKey: .name)
        if let avatarRawURL = try keyedContainer.decodeIfPresent(String.self, forKey: .avatarURL),
            let avatarURL = URL(string: avatarRawURL) {
            self.avatar = LGFile(id: nil, url: avatarURL)
        } else {
            self.avatar = nil
        }
        self.postalAddress = (try? PostalAddress(from: decoder)) ?? PostalAddress.emptyAddress()
        self.ratingAverage = try keyedContainer.decodeIfPresent(Float.self, forKey: .ratingAverage)
        self.ratingCount = try keyedContainer.decodeIfPresent(Int.self, forKey: .ratingCount) ?? 0
        if let accounts = try keyedContainer.decodeIfPresent(FailableDecodableArray<LGAccount>.self, forKey: .accounts) {
            self.accounts = accounts.validElements
        } else {
            self.accounts = []
        }
        let statusValue = try keyedContainer.decodeIfPresent(String.self, forKey: .status) ?? LGUser.statusDefaultValue.rawValue
        self.status = UserStatus(rawValue: statusValue) ?? LGUser.statusDefaultValue
        self.isDummy = try keyedContainer.decodeIfPresent(Bool.self, forKey: .isDummy) ?? false

        self.phone = try keyedContainer.decodeIfPresent(String.self, forKey: .phone)
        let typeValue = try keyedContainer.decodeIfPresent(String.self, forKey: .type) ?? UserType.user.rawValue
        self.type = UserType(rawValue: typeValue) ?? UserType.user
    }
    
    enum CodingKeys: String, CodingKey {
        case id             = "id"
        case name           = "name"
        case email          = "email"
        case avatarURL      = "avatar_url"
        case isDummy        = "is_richy"
        case ratingAverage  = "rating_value"
        case ratingCount    = "num_ratings"
        case accounts       = "accounts"
        case status         = "status"
        case phone          = "phone"
        case type           = "type"
    }
}
