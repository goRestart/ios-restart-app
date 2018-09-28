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
        case .interested:
            result[typeKey] = ChatMessageTypeDecodable.interested.rawValue
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
        case let .cta(ctaData, ctas):
            result[typeKey] = ChatMessageTypeDecodable.cta.rawValue
            result[textKey] = ctaData.text
            result[LGChatMessageContent.CodingKeys.key.rawValue] = ctaData.key
            let ctas = ctas.map { MockChatCallToAction(from: $0).makeDictionary() }
            result[LGChatMessageContent.CodingKeys.cta.rawValue] = ctas
        case .carousel(let cards, let answers):
            result[typeKey] = ChatMessageTypeDecodable.carousel.rawValue
            result[textKey] = text
            let cards = cards.map { MockChatCarouselCard(from: $0).makeDictionary() }
            result[LGChatMessageContent.CodingKeys.cards.rawValue] = cards
            let answers = answers.map { MockChatAnswer(from: $0).makeDictionary() }
            result[LGChatMessageContent.CodingKeys.answers.rawValue] = answers
        case .system(let message):
            result[typeKey] = ChatMessageTypeDecodable.system.rawValue
            result[textKey] = text
            result[LGChatMessageContent.CodingKeys.localizedKey.rawValue] = message.localizedKey
            result[LGChatMessageContent.CodingKeys.localizedText.rawValue] = message.localizedText
            result[LGChatMessageContent.CodingKeys.severity.rawValue] = message.severity
        case .unsupported, .interlocutorIsTyping:
            result[typeKey] = "an_unsupported_type"
        }
        result[LGChatMessageContent.CodingKeys.unsupportedMessageTypeDescription.rawValue] = defaultText
        return result
    }
}
