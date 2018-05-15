//
//  MockChatAnswer.swift
//  LGCoreKit
//
//  Created by Nestor on 18/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct MockChatAnswer: ChatAnswer {
    public var id: String
    public var key: String
    public var type: ChatAnswerType
    
    public init(id: String,
                key: String,
                type: ChatAnswerType) {
        
        self.id = id
        self.key = key
        self.type = type
    }
    
    init(from chatAnswer: ChatAnswer) {
        self.id = chatAnswer.id
        self.key = chatAnswer.key
        self.type = chatAnswer.type
    }
    
    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatAnswer.CodingKeys.id.rawValue] = id
        result[LGChatAnswer.CodingKeys.key.rawValue] = key
        let content: MockChatAnswerContent
        let decodableType: ChatAnswerTypeDecodable
        switch type {
        case .replyText(let textToShow, let textToReply):
            content = MockChatAnswerContent(textToShow: textToShow, textToReply: textToReply, deeplinkURL: nil)
            decodableType = ChatAnswerTypeDecodable.replyText
        case .callToAction(let textToShow, let textToReply, let deeplinkURL):
            content = MockChatAnswerContent(textToShow: textToShow, textToReply: textToReply, deeplinkURL: deeplinkURL)
            decodableType = ChatAnswerTypeDecodable.callToAction
        }
        result[LGChatAnswer.CodingKeys.content.rawValue] = MockChatAnswerContent(from: content).makeDictionary()
        result[LGChatAnswer.CodingKeys.type.rawValue] = decodableType.rawValue
        return result
    }
}
