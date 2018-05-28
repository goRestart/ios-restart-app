//
//  MockChatInactiveConversation+MockFactory.swift
//  LGCoreKit
//
//  Created by Nestor on 15/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension MockChatInactiveConversation: MockFactory {
    public static func makeMock() -> MockChatInactiveConversation {
        return MockChatInactiveConversation(objectId: String.makeRandom(),
                                            lastMessageSentAt: Date.makeRandom(),
                                            listing: MockChatListing.makeMock(),
                                            seller: MockInactiveInterlocutor.makeMock(),
                                            buyer: MockInactiveInterlocutor.makeMock(),
                                            messages: MockChatInactiveMessage.makeMocks())
    }
}
