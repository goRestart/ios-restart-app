//
//  MockChatWrapper.swift
//  LetGo
//
//  Created by Eli Kohen on 07/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

@testable import LetGo
import LGCoreKit

class MockChatWrapper: ChatWrapper {

    let chatRepo: MockChatRepository
    let oldChatRepo: MockOldChatRepository
    let myUserRepo: MockMyUserRepository
    let featureFlags: MockFeatureFlags

    init() {
        chatRepo = MockChatRepository()
        oldChatRepo = MockOldChatRepository()
        myUserRepo = MockMyUserRepository()
        featureFlags = MockFeatureFlags()
        super.init(chatRepository: chatRepo, oldChatRepository: oldChatRepo, myUserRepository: myUserRepo, featureFlags: featureFlags)
    }
}
