//
//  LGChatInterlocutor.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

public protocol ChatInterlocutor: BaseModel {
    var name: String { get }
    var avatar: File? { get }
    var isBanned: Bool { get }
    var isMuted: Bool { get }
    var hasMutedYou: Bool { get }
    var status: UserStatus { get }
    var userType: UserType { get }
    
    init(objectId: String?,
         name: String,
         avatar: File?,
         isBanned: Bool,
         isMuted: Bool,
         hasMutedYou: Bool,
         status: UserStatus,
         userType: UserType)
}

extension ChatInterlocutor {
    func updating(isMuted: Bool) -> ChatInterlocutor {
        return type(of: self).init(objectId: objectId,
                                   name: name,
                                   avatar: avatar,
                                   isBanned: isBanned,
                                   isMuted: isMuted,
                                   hasMutedYou: hasMutedYou,
                                   status: status,
                                   userType: userType)
    }
}

struct LGChatInterlocutor: ChatInterlocutor, Decodable {
    private static let statusDefaultValue: UserStatus = .inactive

    let objectId: String?
    let name: String
    let avatar: File?
    let isBanned: Bool
    let isMuted: Bool
    let hasMutedYou: Bool
    let status: UserStatus
    let userType: UserType
    
    init(objectId: String?,
         name: String,
         avatar: File?,
         isBanned: Bool,
         isMuted: Bool,
         hasMutedYou: Bool,
         status: UserStatus,
         userType: UserType) {
        
        self.objectId = objectId
        self.name = name
        self.avatar = avatar
        self.isBanned = isBanned
        self.isMuted = isMuted
        self.hasMutedYou = hasMutedYou
        self.status = status
        self.userType = userType
    }
    
    fileprivate static func make(objectId: String?,
                                 name: String,
                                 avatar: LGFile?,
                                 isBanned: Bool,
                                 isMuted: Bool,
                                 hasMutedYou: Bool,
                                 status: UserStatus,
                                 userType: UserType) -> LGChatInterlocutor {
        
        return LGChatInterlocutor(objectId: objectId,
                                  name: name,
                                  avatar: avatar,
                                  isBanned: isBanned,
                                  isMuted: isMuted,
                                  hasMutedYou: hasMutedYou,
                                  status: status,
                                  userType: userType)
    }
    
    // MARK: Decodable
    
    /*
     {
     "id": [uuid|objectId]
     "name": [string|null],
     "avatar": [url|null],
     "is_banned": [bool|null],
     "status": [string|null],
     "is_muted": [bool|null],
     "has_muted_you": [bool|null],
     "type": [string|null]
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        name = try keyedContainer.decodeIfPresent(String.self, forKey: .name) ?? ""
        if let avatarStringURL = try? keyedContainer.decode(String.self, forKey: .avatar) {
            avatar = LGFile(id: nil, urlString: avatarStringURL)
        } else {
            avatar = nil
        }
        isBanned = try keyedContainer.decodeIfPresent(Bool.self, forKey: .isBanned) ?? false
        isMuted = try keyedContainer.decodeIfPresent(Bool.self, forKey: .isMuted) ?? false
        hasMutedYou = try keyedContainer.decodeIfPresent(Bool.self, forKey: .hasMutedYou) ?? false

        let statusValue = try keyedContainer.decodeIfPresent(String.self, forKey: .status) ??
            LGChatInterlocutor.statusDefaultValue.rawValue
        status = UserStatus(rawValue: statusValue) ?? LGChatInterlocutor.statusDefaultValue

        userType = try keyedContainer.decodeIfPresent(UserType.self, forKey: .type) ?? .user
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case name
        case avatar
        case isBanned = "is_banned"
        case isMuted = "is_muted"
        case hasMutedYou = "has_muted_you"
        case status
        case type
    }
}
