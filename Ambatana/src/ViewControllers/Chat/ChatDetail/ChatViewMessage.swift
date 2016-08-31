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
    case Disclaimer(showAvatar: Bool, text: NSAttributedString, actionTitle: String? ,action: (() -> ())?)
    case UserInfo(name: String, address: String?, facebook: Bool, google: Bool, email: Bool)
}

enum ChatViewMessageWarningStatus: String {
    case Normal
    case Spam
    
    init(status: MessageWarningStatus) {
        switch status {
        case .Normal:
            self = .Normal
        case .Suspicious:
            self = .Spam
        }
    }
    
    init(status: [ChatMessageWarning]) {
        if status.contains(.Spam) {
            self = .Spam
        } else {
            self = .Normal
        }
    }
}

struct ChatViewMessage: BaseModel {
    var objectId: String?
    var talkerId: String
    var sentAt: NSDate?
    var receivedAt: NSDate?
    var readAt: NSDate?
    var type: ChatViewMessageType
    var status: ChatMessageStatus?
    var warningStatus: ChatViewMessageWarningStatus

    var copyEnabled: Bool {
        switch type {
        case .Text, .Offer:
            return true
        case .Sticker, .Disclaimer, .UserInfo:
            return false
        }
    }

    var value: String {
        switch type {
        case .Offer(let text):
            return text
        case .Text(let text):
            return text
        case .Sticker(let url):
            return url
        case .Disclaimer(_, let text, _, _):
            return text.string
        case .UserInfo(let name, _, _, _, _):
            return name
        }
    }
}

extension ChatViewMessage {
    func markAsSent() -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt ?? NSDate(),
                               receivedAt: receivedAt, readAt: readAt, type: type, status: .Sent,
                               warningStatus: warningStatus)
    }
    
    func markAsReceived() -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt,
                               receivedAt: receivedAt ?? NSDate(), readAt: readAt, type: type, status: .Received,
                               warningStatus: warningStatus)
    }
    
    func markAsRead() -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt, receivedAt: receivedAt,
                               readAt: readAt ?? NSDate(), type: type, status: .Read, warningStatus: warningStatus)
    }
}
