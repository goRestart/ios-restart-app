//
//  LGChatAnswer.swift
//  LGCoreKit
//
//  Created by Nestor on 17/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public enum ChatAnswerTypeDecodable: String, Decodable {
    case replyText = "reply_text"
    case callToAction = "call_to_action"
}

public protocol ChatAnswer {
    var id: String { get }
    var key: String { get }
    var type: ChatAnswerType { get }
}

struct LGChatAnswer: ChatAnswer, Decodable, Equatable {
    let id: String
    let key: String
    let type: ChatAnswerType
    
    init(id: String,
         key: String,
         type: ChatAnswerType) {
        self.id = id
        self.key = key
        self.type = type
    }
    
    init(from chatAnswer: ChatAnswer) {
        id = chatAnswer.id
        key = chatAnswer.key
        type = chatAnswer.type
    }
    
    // MARK: Decodable
    
    /*
     {
     "id": "0c33bd13-f293-4856-805d-5aa8dc8a8816",
     "key": "the_key_to_rule_the_world_of_tracking",
     "type": ChatAnswerTypeDecodable,
     "content": {
        "text_to_show": "Response 1",
        "text_to_reply": "Reply 1",
        "deeplink": "valid_url",
        "link": ""
     }
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        id = try keyedContainer.decode(String.self, forKey: .id)
        key = try keyedContainer.decode(String.self, forKey: .key)
        let content = try keyedContainer.decode(LGChatAnswerContent.self, forKey: .content)
        let chatAnswerTypeDecodable = try keyedContainer.decode(ChatAnswerTypeDecodable.self, forKey: .type)
        switch chatAnswerTypeDecodable {
        case .replyText:
            type = ChatAnswerType.replyText(textToShow: content.textToShow,
                                            textToReply: content.textToReply)
        case .callToAction:
            guard let deeplinkURL = content.deeplinkURL else {
                throw DecodingError.valueNotFound(Int.self,
                                                  DecodingError.Context(codingPath: [CodingKeys.content],
                                                                        debugDescription: "deeplink not found: \(content)"))
            }
            type = ChatAnswerType.callToAction(textToShow: content.textToShow,
                                               textToReply: content.textToReply,
                                               deeplinkURL: deeplinkURL)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case key
        case type
        case content
    }
    
    // MARK: Equatable
    
    static func ==(lhs: LGChatAnswer, rhs: LGChatAnswer) -> Bool {
        return lhs.id == rhs.id && lhs.key == rhs.key && lhs.type == rhs.type
    }
}
