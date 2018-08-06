//
//  LGChatAnswerContent.swift
//  LGCoreKit
//
//  Created by Nestor on 17/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public protocol ChatAnswerContent {
    var textToShow: String { get }
    var textToReply: String { get }
    var deeplinkURL: URL? { get }
}

struct LGChatAnswerContent: ChatAnswerContent, Decodable, Equatable {
    
    let textToShow: String
    let textToReply: String
    let deeplinkURL: URL?
    
    init(textToShow: String,
         textToReply: String,
         deeplinkURL: URL?) {
        self.textToShow = textToShow
        self.textToReply = textToReply
        self.deeplinkURL = deeplinkURL
    }
    
    // MARK: Decodable
    
    /*
     {
     "text_to_show": "Response 1",
     "text_to_reply": "Reply 1",
     "deeplink": "", // mobile deeplink
     "link": "" // web deeplink
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        textToShow = try keyedContainer.decode(String.self, forKey: .textToShow)
        textToReply = try keyedContainer.decode(String.self, forKey: .textToReply)
        if let deeplinkString = try keyedContainer.decodeIfPresent(String.self, forKey: .deeplink),
            let escapedString = deeplinkString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let deeplinkURLValue = URL(string: escapedString) {
                deeplinkURL = deeplinkURLValue
        } else {
            deeplinkURL = nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case textToShow = "text_to_show"
        case textToReply = "text_to_reply"
        case deeplink
    }

    // MARK: Equatable
    
    static func ==(lhs: LGChatAnswerContent, rhs: LGChatAnswerContent) -> Bool {
        return lhs.textToShow == rhs.textToShow
        && lhs.textToReply == rhs.textToReply
        && lhs.deeplinkURL == rhs.deeplinkURL
    }
}
