//
//  MockChatInactiveMessage+MockFactory.swift
//  LGCoreKit
//
//  Created by Nestor on 15/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension MockChatInactiveMessage: MockFactory {
    public static func makeMock() -> MockChatInactiveMessage {
        return MockChatInactiveMessage(objectId: String.makeRandom(),
                                       talkerId: String.makeRandom(),
                                       sentAt: Date?.makeRandom(),
                                       warnings: ChatMessageWarning.makeMocks(count: Int.makeRandom(min: 0, max: 10)),
                                       content: MockChatMessageContent.makeMock())
    }
}
