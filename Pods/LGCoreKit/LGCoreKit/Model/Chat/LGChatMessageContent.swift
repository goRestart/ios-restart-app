//
//  LGChatMessageContent.swift
//  LGCoreKit
//
//  Created by Nestor on 11/01/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public protocol ChatMessageContent {
    var type: ChatMessageType { get }
    var text: String? { get }
}

struct LGChatMessageContent: ChatMessageContent, Decodable {
    let type: ChatMessageType
    let text: String?
    
    // MARK: Decodable
    
    /*
     {
    "text": "Hi! I'd like to buy it",
    "type": "unknown_type",
    "default": "You've received a message not supported for your app version.\nPlease update your app to use the newest features!"
     }
     */
    
    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let stringChatMessageType = try keyedContainer.decode(String.self, forKey: .type)
        if let typeMessage = ChatMessageType(rawValue: stringChatMessageType) {
            type = typeMessage
            text = try keyedContainer.decodeIfPresent(String.self, forKey: .text)
        } else {
            // ChatMessageType defaults to .text as fallback for future message types
            // and we set as text the unsopported description if there is any
            // if not, the app will have to handle this case and add a custom localized message informing
            // the user that the current version of the does not support this message
            type = .text
            text = try keyedContainer.decodeIfPresent(String.self, forKey: .unsupportedMessageTypeDescription)
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case type
        case text
        case unsupportedMessageTypeDescription = "default"
    }
}
