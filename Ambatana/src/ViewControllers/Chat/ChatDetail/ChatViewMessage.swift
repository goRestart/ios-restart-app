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
    case disclaimer(text: NSAttributedString ,action: (() -> ())?)
    case userInfo(isDummy: Bool, name: String, address: String?, facebook: Bool, google: Bool, email: Bool)
    case askPhoneNumber(text: String, action: (() -> Void)?)
    case meeting(type: MeetingMessageType,
                 date: Date?,
                 locationName: String?,
                 coordinates: LGLocationCoordinates2D?,
                 status: MeetingStatus?,
                 text: String)
    case multiAnswer(question: ChatQuestion, answers: [ChatAnswer])
    case interlocutorIsTyping
    case unsupported(text: String)

    var isAskPhoneNumber: Bool {
        if case .askPhoneNumber = self {
            return true
        }
        return false
    }

    var isMeeting: Bool {
        if case .meeting = self {
            return true
        }
        return false
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
        case let .disclaimer(lhsText, _):
            switch rhs {
            case let .disclaimer(rhsText, _):
                return lhsText == rhsText
            default: return false
            }
        case let .userInfo(lhsIsDummy, lhsName, lhsAddress, lhsFacebook, lhsGoogle, lhsEmail):
            switch rhs {
            case let .userInfo(rhsIsDummy, rhsName, rhsAddress, rhsFacebook, rhsGoogle, rhsEmail):
                return lhsIsDummy == rhsIsDummy && lhsName == rhsName && lhsAddress == rhsAddress
                    && lhsFacebook == rhsFacebook && lhsGoogle == rhsGoogle && lhsEmail == rhsEmail
            default: return false
            }
        case let .askPhoneNumber(lhsText, _):
            switch rhs {
            case let .askPhoneNumber(rhsText, _):
                return lhsText == rhsText
            default: return false
            }
        case let .meeting(lhsType, lhsDate, lhsLocationName, lhsCoordinates, lhsStatus, lhsText):
            switch rhs {
            case let .meeting(rhsType, rhsDate, rhsLocationName, rhsCoordinates, rhsStatus, rhsText):
                return lhsType == rhsType &&
                    lhsDate == rhsDate &&
                    lhsLocationName == rhsLocationName &&
                    lhsCoordinates == rhsCoordinates &&
                    lhsStatus == rhsStatus &&
                    lhsText == rhsText
            default: return false
            }
        case .multiAnswer(let rhsQuestion, let rhsAnswers):
            if case .multiAnswer(let lhsQuestion, let lhsAnswers) = lhs {
                return rhsQuestion.text == lhsQuestion.text && rhsQuestion.key == lhsQuestion.key
                    && rhsAnswers.map { $0.id } == lhsAnswers.map { $0.id }
            }
        case .interlocutorIsTyping:
            switch rhs {
            case .interlocutorIsTyping:
                return true
            default: return false
            }
        case .unsupported(let lhsText):
            switch rhs {
            case .unsupported(let rhsText):
                return lhsText == rhsText
            default: return false
            }
        }
        return false
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
        case .sticker, .disclaimer, .userInfo, .askPhoneNumber, .meeting, .interlocutorIsTyping, .unsupported, .multiAnswer:
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
        case .disclaimer(let text, _):
            return text.string
        case .userInfo(_, let name, _, _, _, _):
            return name
        case .askPhoneNumber(let text, _):
            return text
        case let .meeting(_, _, _, _, _, text):
            return text
        case .multiAnswer(let question, _):
            return question.text
        case .interlocutorIsTyping:
            return "..."
        case .unsupported(let text):
            return text
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


extension ChatViewMessage {
    func markAsAccepted() -> ChatViewMessage {
        if case let .meeting(meetingType, meetingDate, locationName, coordinates, _, text) = type,
            meetingType == .requested {
            let acceptedMessageType: ChatViewMessageType = .meeting(type: meetingType,
                                                                    date: meetingDate,
                                                                    locationName: locationName,
                                                                    coordinates: coordinates,
                                                                    status: .accepted,
                                                                    text: text)
            return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt,
                                   receivedAt: receivedAt,
                                   readAt: readAt,
                                   type: acceptedMessageType,
                                   status: status,
                                   warningStatus: warningStatus)
        } else {
            return self
        }
    }
    
    func markAsRejected() -> ChatViewMessage {
        if case let .meeting(meetingType, meetingDate, locationName, coordinates, _, text) = type,
            meetingType == .requested {
            let rejectedMessageType: ChatViewMessageType = .meeting(type: meetingType,
                                                                    date: meetingDate,
                                                                    locationName: locationName,
                                                                    coordinates: coordinates,
                                                                    status: .rejected,
                                                                    text: text)
            return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt,
                                   receivedAt: receivedAt,
                                   readAt: readAt,
                                   type: rejectedMessageType,
                                   status: status,
                                   warningStatus: warningStatus)
        } else {
            return self
        }
    }
}
