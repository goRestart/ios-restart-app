//
//  MockChatAnswerContent.swift
//  LGCoreKit
//
//  Created by Nestor on 18/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct MockChatAnswerContent: ChatAnswerContent {
    public var textToShow: String
    public var textToReply: String
    public var deeplinkURL: URL?
    
    public init(textToShow: String,
                textToReply: String,
                deeplinkURL: URL?) {
        
        self.textToShow = textToShow
        self.textToReply = textToReply
        self.deeplinkURL = deeplinkURL
    }
    
    init(from chatAnswerContent: ChatAnswerContent) {
        self.textToShow = chatAnswerContent.textToShow
        self.textToReply = chatAnswerContent.textToReply
        self.deeplinkURL = chatAnswerContent.deeplinkURL
    }
    
    init(from type: ChatAnswerType) {
        switch type {
        case .replyText(let textToShow, let textToReply):
            self.textToShow = textToShow
            self.textToReply = textToReply
        case .callToAction(let textToShow, let textToReply, let deeplinkURL):
            self.textToShow = textToShow
            self.textToReply = textToReply
            self.deeplinkURL = deeplinkURL
        }
    }
    
    public func makeDictionary() -> [String: Any] {
        var result = [String: Any]()
        result[LGChatAnswerContent.CodingKeys.textToShow.rawValue] = textToShow
        result[LGChatAnswerContent.CodingKeys.textToReply.rawValue] = textToReply
        result[LGChatAnswerContent.CodingKeys.deeplink.rawValue] = deeplinkURL?.absoluteString
        return result
    }
}
