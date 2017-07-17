//
//  ChatInterlocutor.swift
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
