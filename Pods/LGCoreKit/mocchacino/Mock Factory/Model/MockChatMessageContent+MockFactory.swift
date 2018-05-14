//
//  MockChatMessageContent+MockFactory.swift
//  LGCoreKit
//
//  Created by Nestor on 15/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension MockChatMessageContent: MockFactory {
    public static func makeMock() -> MockChatMessageContent {
        return MockChatMessageContent(type: ChatMessageType.makeMock(),
                                      defaultText: String.makeRandom(),
                                      text: String.makeRandom())
    }
}
