//
//  ChatViewMessage.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

enum ChatViewMessageType {
    case text(text: String)
    case offer(text: String)
    case sticker(url: String)
    case disclaimer(showAvatar: Bool, text: NSAttributedString, actionTitle: String? ,action: (() -> ())?)
    case userInfo(name: String, address: String?, facebook: Bool, google: Bool, email: Bool)
    case askPhoneNumber(text: String, action: (() -> Void)?)
    case chatNorris(type: MeetingMessageType, date: Date?, locationName: String?, coordinates: LGLocationCoordinates2D?, status: MeetingStatus?)
    case interlocutorIsTyping

    var isAskPhoneNumber: Bool {
        switch self {
        case .askPhoneNumber:
            return true
        case .text, .offer, .sticker, .disclaimer, .userInfo, .chatNorris, .interlocutorIsTyping:
            return false
        }
    }
    
    public static func ==(lhs: ChatViewMessageType, rhs: ChatViewMessageType) -> Bool {
        switch lhs {
        case let .text(lhsText):
            switch rhs {
            case let .text(rhsText):
                return lhsText == rhsText
            default: return false
            }
        case let .offer(lhsText):
            switch rhs {
            case let .offer(rhsText):
                return lhsText == rhsText
            default: return false
            }
        case let .sticker(lhsURL):
            switch rhs {
            case let .sticker(rhsURL):
                return lhsURL == rhsURL
            default: return false
            }
        case let .disclaimer(lhsShowAvatar, lhsText, lhsActionTitle, _):
            switch rhs {
            case let .disclaimer(rhsShowAvatar, rhsText, rhsActionTitle, _):
                return lhsShowAvatar == rhsShowAvatar && lhsText == rhsText && lhsActionTitle == rhsActionTitle
            default: return false
            }
        case let .userInfo(lhsName, lhsAddress, lhsFacebook, lhsGoogle, lhsEmail):
            switch rhs {
            case let .userInfo(rhsName, rhsAddress, rhsFacebook, rhsGoogle, rhsEmail):
                return lhsName == rhsName && lhsAddress == rhsAddress && lhsFacebook == rhsFacebook
                    && lhsGoogle == rhsGoogle && lhsEmail == rhsEmail
            default: return false
            }
        case let .askPhoneNumber(lhsText, _):
            switch rhs {
            case let .askPhoneNumber(rhsText, _):
                return lhsText == rhsText
            default: return false
            }
        case .interlocutorIsTyping:
            switch rhs {
            case .interlocutorIsTyping:
                return true
            default: return false
            }
        }
    }
}

enum ChatViewMessageWarningStatus: String {
    case normal
    case spam
    
    init(status: MessageWarningStatus) {
        switch status {
        case .normal:
            self = .normal
        case .suspicious:
            self = .spam
        }
    }
    
    init(status: [ChatMessageWarning]) {
        if status.contains(.spam) {
            self = .spam
        } else {
            self = .normal
        }
    }
}

struct ChatViewMessage: BaseModel {
    var objectId: String?
    var talkerId: String
    var sentAt: Date?
    var receivedAt: Date?
    var readAt: Date?
    var type: ChatViewMessageType
    var status: ChatMessageStatus?
    var warningStatus: ChatViewMessageWarningStatus

    var copyEnabled: Bool {
        switch type {
        case .text, .offer:
            return true
        case .sticker, .disclaimer, .userInfo, .askPhoneNumber, .chatNorris, .interlocutorIsTyping:
            return false
        }
    }

    var value: String {
        switch type {
        case .offer(let text):
            return text
        case .text(let text):
            return text
        case .sticker(let url):
            return url
        case .disclaimer(_, let text, _, _):
            return text.string
        case .userInfo(let name, _, _, _, _):
            return name
        case .askPhoneNumber(let text, _):
            return text
        case let .chatNorris(type, date, locationName, coordinates, status):
            let meeting = AssistantMeeting(meetingType: type,
                                           date: date,
                                           locationName: locationName,
                                           coordinates: coordinates,
                                           status: status)
            return MeetingParser.textForMeeting(meeting: meeting)
        case .interlocutorIsTyping:
            return "..."
        }
    }
    
    public static func ==(lhs: ChatViewMessage, rhs: ChatViewMessage) -> Bool {
        return lhs.value == rhs.value
        && lhs.objectId == rhs.objectId
        && lhs.readAt == rhs.readAt
        && lhs.receivedAt == rhs.receivedAt
        && lhs.sentAt == rhs.sentAt
        && lhs.status == rhs.status
        && lhs.talkerId == rhs.talkerId
        && lhs.type == lhs.type
    }
}

extension ChatViewMessage {
    func markAsSent(date: Date = Date()) -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt ?? date,
                               receivedAt: receivedAt, readAt: readAt, type: type, status: .sent,
                               warningStatus: warningStatus)
    }
    
    func markAsReceived(date: Date = Date()) -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt,
                               receivedAt: receivedAt ?? date, readAt: readAt, type: type, status: .received,
                               warningStatus: warningStatus)
    }
    
    func markAsRead(date: Date = Date()) -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt, receivedAt: receivedAt,
                               readAt: readAt ?? date, type: type, status: .read, warningStatus: warningStatus)
    }
}
