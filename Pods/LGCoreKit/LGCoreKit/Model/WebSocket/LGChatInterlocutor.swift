//
//  LGChatInterlocutor.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry
import Runes

struct LGChatInterlocutor: ChatInterlocutor {
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
         status: UserStatus){
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
}

extension LGChatInterlocutor: Decodable {
    
    struct JSONKeys {
        static let objectId = "id"
        static let name = "name"
        static let avatar = "avatar"
        static let isBanned = "is_banned"
        static let isMuted = "is_muted"
        static let hasMutedYou = "has_muted_you"
        static let status = "status"
    }
    
    static func decode(_ j: JSON) -> Decoded<LGChatInterlocutor> {
        let result1 = curry(LGChatInterlocutor.make)
        let result2 = result1 <^> j <|? JSONKeys.objectId
        let result3 = result2 <*> j <| JSONKeys.name
        let result4 = result3 <*> LGArgo.jsonToAvatarFile(j, avatarKey: JSONKeys.avatar)
        let result5 = result4 <*> j <| JSONKeys.isBanned
        let result6 = result5 <*> j <| JSONKeys.isMuted
        let result7 = result6 <*> j <| JSONKeys.hasMutedYou
        let result  = result7 <*> j <| JSONKeys.status
        if let error = result.error {
            logMessage(.error, type: .parsing, message: "LGChatInterlocutor parse error: \(error)")
        }
        return result
    }
    
    static func decodeOptional(_ json: JSON?) -> Decoded<LGChatInterlocutor?> {
        guard let j = json else { return Decoded<LGChatInterlocutor?>.success(nil) }
        return Decoded<LGChatInterlocutor?>.success(LGChatInterlocutor.decode(j).value)
    }
}
