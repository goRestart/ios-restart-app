//
//  MockChatEvent.swift
//  LetGo
//
//  Created by Eli Kohen on 20/03/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

struct MockChatEvent: ChatEvent {
    var objectId: String?
    var type: ChatEventType
    var conversationId: String?
}

extension MockChatEvent: MockFactory {
    public static func makeMock() -> MockChatEvent {
        return MockChatEvent(objectId: String?.makeRandom(),
                             type: .interlocutorTypingStarted,
                             conversationId: String.makeRandom())
    }

    public static func makeMessageSentMock() -> MockChatEvent {
        return MockChatEvent(objectId: String.makeRandom(),
                             type: .interlocutorMessageSent(messageId: String.makeRandom(),
                                                           sentAt: Date.makeRandom(),
                                                           text: String.makeRandom(),
                                                           type: .text),
                             conversationId: String.makeRandom())
    }

}
