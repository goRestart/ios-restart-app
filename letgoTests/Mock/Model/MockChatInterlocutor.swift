//
//  MockChatInterlocutor.swift
//  LetGo
//
//  Created by Juan Iglesias on 31/01/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//


import LGCoreKit

final class MockChatInterlocutor: MockBaseModel, ChatInterlocutor {
    
    var name: String
    var avatar: File?
    var isBanned: Bool
    var isMuted: Bool
    var hasMutedYou: Bool
    var status: UserStatus
    
    // Lifecycle
    
    override init() {
        self.name = ""
        self.avatar = nil
        self.isBanned = false
        self.isMuted = false
        self.hasMutedYou = false
        self.status = .active
        super.init()
    }
    
    required init(name: String, avatar: File?, isBanned: Bool, isMuted: Bool, hasMutedYou: Bool, status: UserStatus) {
        self.name = name
        self.avatar = avatar
        self.isBanned = isBanned
        self.isMuted = isMuted
        self.hasMutedYou = hasMutedYou
        self.status = status
    }
}

