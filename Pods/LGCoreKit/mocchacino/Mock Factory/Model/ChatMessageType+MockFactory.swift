//
//  ChatMessageType+MockFactory.swift
//  LGCoreKit
//
//  Created by Nestor on 16/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension ChatMessageType: MockFactory {
    public static func makeMock() -> ChatMessageType {
        let allValues: [ChatMessageType] = [.text,
                                            .offer,
                                            .sticker,
                                            .quickAnswer(id: String?.makeRandom(), text: String.makeRandom()),
                                            .expressChat,
                                            .favoritedListing,
                                            .phone,
                                            .meeting,
                                            .unsupported(defaultText: String?.makeRandom()),
                                            .interlocutorIsTyping,
                                            .cta(ctaData: MockChatCallToActionData.makeMock(),
                                                 ctas: MockChatCallToAction.makeMocks())
        ]
        return allValues.random()!
    }
}

