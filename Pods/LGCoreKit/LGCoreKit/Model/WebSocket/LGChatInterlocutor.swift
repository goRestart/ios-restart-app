//
//  LGChatInterlocutor.swift
//  LGCoreKit
//
//  Created by Isaac Roldan on 21/3/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Argo
import Curry

struct LGChatInterlocutor: ChatInterlocutor {
    var objectId: String?
    var name: String
    var avatar: File?
    var isBlocked: Bool
    var isMuted: Bool
    var hasMutedYou: Bool
}

extension LGChatInterlocutor: Decodable {
    
    struct JSONKeys {
        static let objectId = "id"
        static let name = "name"
        static let avatar = "avatar"
        static let isBlocked = "is_blocked"
        static let isMuted = "is_muted"
        static let hasMutedYou = "has_muted_you"
    }
    
    static func decode(j: JSON) -> Decoded<LGChatInterlocutor> {
        let init1 = curry(LGChatInterlocutor.init)
            <^> j <|? JSONKeys.objectId
            <*> j <| JSONKeys.name
            <*> LGArgo.jsonToAvatarFile(j, avatarKey: JSONKeys.avatar)
            <*> j <| JSONKeys.isBlocked
            <*> j <| JSONKeys.isMuted
            <*> j <| JSONKeys.hasMutedYou
        return init1
    }
    
    static func decodeOptional(json: JSON?) -> Decoded<LGChatInterlocutor?> {
        guard let j = json else { return Decoded<LGChatInterlocutor?>.Success(nil) }
        return Decoded<LGChatInterlocutor?>.Success(LGChatInterlocutor.decode(j).value)
    }
}
