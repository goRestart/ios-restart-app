//
//  MockChatMessageContent.swift
//  LGCoreKit
//
//  Created by Nestor on 15/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct MockChatMessageContent: ChatMessageContent {
    public var type: ChatMessageType
    public var defaultText: String?
    public var text: String?
    
    public init(type: ChatMessageType,
                defaultText: String? = String.makeRandom(),
                text: String?) {
        self.type = type
        self.defaultText = defaultText
        self.text = text
    }
    
    init(from chatMessageContent: ChatMessageContent) {
        self.type = chatMessageContent.type
        self.defaultText = chatMessageContent.defaultText
        self.text = chatMessageContent.text
    }
    
    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        let typeKey = LGChatMessageContent.CodingKeys.type.rawValue
        let textKey = LGChatMessageContent.CodingKeys.text.rawValue
        switch type {
        case .text:
            result[typeKey] = ChatMessageTypeDecodable.text.rawValue
            result[textKey] = text
        case .offer:
            result[typeKey] = ChatMessageTypeDecodable.offer.rawValue
            result[textKey] = text
        case .sticker:
            result[typeKey] = ChatMessageTypeDecodable.sticker.rawValue
            result[textKey] = text
        case .quickAnswer:
            result[typeKey] = ChatMessageTypeDecodable.sticker.rawValue
            result[textKey] = text
        case .expressChat:
            result[typeKey] = ChatMessageTypeDecodable.expressChat.rawValue
            result[textKey] = text
        case .favoritedListing:
            result[typeKey] = ChatMessageTypeDecodable.favoritedListing.rawValue
            result[textKey] = text
        case .phone:
            result[typeKey] = ChatMessageTypeDecodable.phone.rawValue
            result[textKey] = text
        case .meeting:
            result[typeKey] = ChatMessageTypeDecodable.meeting.rawValue
        case .multiAnswer(let question, let answers):
            result[typeKey] = ChatMessageTypeDecodable.multiAnswer.rawValue
            result[textKey] = question.text
            result[LGChatMessageContent.CodingKeys.key.rawValue] = question.key
            let answers = answers.map { MockChatAnswer(from: $0).makeDictionary() }
            result[LGChatMessageContent.CodingKeys.answers.rawValue] = answers
        case .unsupported, .interlocutorIsTyping:
            result[typeKey] = "an_unsupported_type"
        }
        result[LGChatMessageContent.CodingKeys.unsupportedMessageTypeDescription.rawValue] = defaultText
        return result
    }
}