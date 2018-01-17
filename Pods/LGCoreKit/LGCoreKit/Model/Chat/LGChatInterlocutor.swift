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
    
    init(objectId: String?,
         name: String,
         avatar: File?,
         isBanned: Bool,
         isMuted: Bool,
         hasMutedYou: Bool,
         status: UserStatus)
}

extension ChatInterlocutor {
    func updating(isMuted: Bool) -> ChatInterlocutor {
        return type(of: self).init(objectId: objectId,
                                   name: name,
                                   avatar: avatar,
                                   isBanned: isBanned,
                                   isMuted: isMuted,
                                   hasMutedYou: hasMutedYou,
                                   status: status)
    }
}

struct LGChatInterlocutor: ChatInterlocutor, Decodable {
    let objectId: String?
    let name: String
    let avatar: File?
    let isBanned: Bool
    let isMuted: Bool
    let hasMutedYou: Bool
    let status: UserStatus
    
    init(objectId: String?,
         name: String,
         avatar: File?,
         isBanned: Bool,
         isMuted: Bool,
         hasMutedYou: Bool,
         status: UserStatus) {
        self.objectId = objectId
        self.name = name
        self.avatar = avatar
        self.isBanned = isBanned
        self.isMuted = isMuted
        self.hasMutedYou = hasMutedYou
        self.status = status
    }
    
    fileprivate static func make(objectId: String?,
                                 name: String,
                                 avatar: LGFile?,
                                 isBanned: Bool,
                                 isMuted: Bool,
                                 hasMutedYou: Bool,
                                 status: UserStatus) -> LGChatInterlocutor {
        return LGChatInterlocutor(objectId: objectId,
                                  name: name,
                                  avatar: avatar,
                                  isBanned: isBanned,
                                  isMuted: isMuted,
                                  hasMutedYou: hasMutedYou,
                                  status: status)
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
     "has_muted_you": [bool|null]
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        objectId = try keyedContainer.decode(String.self, forKey: .objectId)
        name = try keyedContainer.decode(String.self, forKey: .name)
        if let avatarStringURL = try? keyedContainer.decode(String.self, forKey: .avatar) {
            avatar = LGFile(id: nil, urlString: avatarStringURL)
        } else {
            avatar = nil
        }
        isBanned = try keyedContainer.decode(Bool.self, forKey: .isBanned)
        isMuted = try keyedContainer.decode(Bool.self, forKey: .isMuted)
        hasMutedYou = try keyedContainer.decode(Bool.self, forKey: .hasMutedYou)
        status = try keyedContainer.decode(UserStatus.self, forKey: .status)
    }
    
    enum CodingKeys: String, CodingKey {
        case objectId = "id"
        case name
        case avatar
        case isBanned = "is_banned"
        case isMuted = "is_muted"
        case hasMutedYou = "has_muted_you"
        case status
    }
}
