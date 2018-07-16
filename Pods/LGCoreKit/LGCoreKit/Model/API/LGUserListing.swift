//
//  LGUserListing.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 26/01/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

struct LGUserListing: UserListing, Decodable {
    private static let statusDefaultValue = UserStatus.active
    
    let objectId: String?
    let name: String?
    let avatar: File?
    let postalAddress: PostalAddress
    let isDummy: Bool
    let banned: Bool?
    let status: UserStatus
    let type: UserType
    
    
    // MARK: - Lifecycle
    
    init(objectId: String?,
         name: String?,
         avatar: String?,
         postalAddress: PostalAddress,
         isDummy: Bool,
         banned: Bool?,
         status: UserStatus?,
         type: UserType) {
        self.objectId = objectId
        self.name = name
        self.avatar = LGFile(id: nil, urlString: avatar)
        self.postalAddress = postalAddress
        self.isDummy = isDummy
        self.banned = banned
        self.status = status ?? LGUserListing.statusDefaultValue
        self.type = type
    }
    
    init(chatInterlocutor: ChatInterlocutor) {
        let postalAddress = PostalAddress.emptyAddress()
        self.init(objectId: chatInterlocutor.objectId,
                  name: chatInterlocutor.name,
                  avatar: chatInterlocutor.avatar?.fileURL?.absoluteString,
                  postalAddress: postalAddress,
                  isDummy: false,
                  banned: false,
                  status: chatInterlocutor.status,
                  type: chatInterlocutor.userType)
    }
    
    init(user: User) {
        self.init(objectId: user.objectId,
                  name: user.name,
                  avatar: user.avatar?.fileURL?.absoluteString,
                  postalAddress: user.postalAddress,
                  isDummy: user.isDummy,
                  banned: false,
                  status: user.status,
                  type: user.type)
    }
    
    
    // MARK: - Decodable
    
    /*
     {
         "id": "DCOefspN3I",
         "name": "DDLG",
         "avatar_url": "https://s3.amazonaws.com/letgo-avatars-stg/images/15/a4/db/90/15a4db909cb440d02c31d3596726d83f7801112f058f0c5c5b3e9585eac7d143.jpg",
         "zip_code": "",
         "country_code": "ES",
         "is_richy": false,
         "city": "",
         "banned": false,
         "status": "active"
     }
     */
    init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let keyedContainerCamelCase = try decoder.container(keyedBy: CodingKeysCamelCase.self)
        let keyedContainerSnakeCase = try decoder.container(keyedBy: CodingKeysSnakeCase.self)
        
        self.objectId = try keyedContainer.decodeIfPresent(String.self, forKey: .id)
        self.name = try keyedContainer.decodeIfPresent(String.self, forKey: .name)
        if let avatarURL = try keyedContainerSnakeCase.decodeIfPresent(String.self, forKey: .avatarURL) {
            self.avatar = LGFile(id: nil, urlString: avatarURL)
        } else if let avatarUrl = try keyedContainerCamelCase.decodeIfPresent(String.self, forKey: .avatarURL) {
            self.avatar = LGFile(id: nil, urlString: avatarUrl)
        } else {
            self.avatar = nil
        }
        self.postalAddress = (try? PostalAddress(from: decoder)) ?? PostalAddress.emptyAddress()
        if let dummyValue = try keyedContainerSnakeCase.decodeIfPresent(Bool.self, forKey: .isDummy) {
            self.isDummy = dummyValue
        } else {
            self.isDummy = try keyedContainerCamelCase.decodeIfPresent(Bool.self, forKey: .isDummy) ?? false
        }
        self.banned = try keyedContainer.decodeIfPresent(Bool.self, forKey: .isBanned)
        let statusValue = try keyedContainer.decodeIfPresent(String.self, forKey: .status) ?? LGUserListing.statusDefaultValue.rawValue
        self.status = UserStatus(rawValue: statusValue) ?? LGUserListing.statusDefaultValue
        self.type = try keyedContainer.decodeIfPresent(UserType.self, forKey: .type) ?? UserType.unknown
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, type
        case isBanned = "banned"
    }
    
    enum CodingKeysCamelCase: String, CodingKey {
        case avatarURL = "avatarUrl"
        case isDummy = "isRichy"
    }
    
    enum CodingKeysSnakeCase: String, CodingKey {
        case avatarURL = "avatar_url"
        case isDummy = "is_richy"
    }
}
