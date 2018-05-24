//
//  WebSocketSendMessageType+MockFactory.swift
//  LGCoreKit
//
//  Created by Nestor on 16/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension WebSocketSendMessageType: MockFactory {
    public static func makeMock() -> WebSocketSendMessageType {
        let allValues: [WebSocketSendMessageType] = [.text,
                                                     .offer,
                                                     .sticker,
                                                     .quickAnswer,
                                                     .expressChat,
                                                     .favoritedListing,
                                                     .phone,
                                                     .meeting]
        return allValues.random()!
    }
}
