//
//  ChatViewMessage.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum ChatViewMessageType {
    case Text(text: String)
    case Offer(text: String)
    case Sticker(url: String)
    case Disclaimer(text: NSAttributedString, actionTitle: String? ,action: (() -> ())?)
}

struct ChatViewMessage: BaseModel {
    var objectId: String?
    var talkerId: String
    var sentAt: NSDate?
    var receivedAt: NSDate?
    var readAt: NSDate?
    var type: ChatViewMessageType
    var status: ChatMessageStatus?
    
    var value: String {
        switch type {
        case .Offer(let text):
            return text
        case .Text(let text):
            return text
        case .Sticker(let url):
            return url
        case .Disclaimer(let text, _, _):
            return text.string
        }
    }
}

extension ChatViewMessage {
    func markAsSent() -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt ?? NSDate(),
                               receivedAt: receivedAt, readAt: readAt, type: type, status: .Sent)
    }
    
    func markAsReceived() -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt,
                               receivedAt: receivedAt ?? NSDate(), readAt: readAt, type: type, status: .Received)
    }
    
    func markAsRead() -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt, receivedAt: receivedAt,
                               readAt: readAt ?? NSDate(), type: type, status: .Read)
    }
}
