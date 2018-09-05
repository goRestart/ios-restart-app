//
//  ChatViewMessage.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

struct ChatUserInfo: Equatable {
    let isDummy: Bool
    let name: String
    let address: String?
    let rating: Float?
    let isFacebookVerified: Bool
    let isGoogleVerified: Bool
    let isEmailVerified: Bool
}

enum ChatViewMessageType {
    case text(text: String)
    case offer(text: String)
    case sticker(url: String)
    case disclaimer(text: NSAttributedString ,action: (() -> ())?)
    case userInfo(userInfo: ChatUserInfo)
    case askPhoneNumber(text: String, action: (() -> Void)?)
    case meeting(type: MeetingMessageType,
                 date: Date?,
                 locationName: String?,
                 coordinates: LGLocationCoordinates2D?,
                 status: MeetingStatus?,
                 text: String)
    case multiAnswer(question: ChatQuestion, answers: [ChatAnswer])
    case interlocutorIsTyping
    case cta(ctaData: ChatCallToActionData, ctas: [ChatCallToAction])
    case carousel(cards: [ChatCarouselCard], answers: [ChatAnswer])
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
        case let .userInfo(userInfo):
            switch rhs {
            case let .userInfo(rhsUserInfo):
                return userInfo == rhsUserInfo
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
        case .cta(let rhsCtaData, let rhsCtas):
            if case .cta(let lhsCtaData, let lhsCtas) = lhs {
                return lhsCtaData.text == rhsCtaData.text && lhsCtaData.key == rhsCtaData.key
                    && lhsCtas.map { $0.objectId } == rhsCtas.map { $0.objectId }
            }
        case .carousel(let rhsCards, let rhsAnswsers):
            if case .carousel(let lhsCards, let lhsAnswsers) = lhs {
                return rhsCards.map { $0.imageURL } == lhsCards.map { $0.imageURL }
                    && rhsCards.map { $0.title } == lhsCards.map { $0.title }
                    && rhsCards.map { $0.text } == lhsCards.map { $0.text }
                    && rhsAnswsers.map { $0.id } == lhsAnswsers.map { $0.id }
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

struct ChatMessageAvatarData {
    var avatarImage: UIImage?
    var avatarAction: (()->Void)?

    init(avatarImage: UIImage? = nil, avatarAction: (()->Void)? = nil) {
        self.avatarImage = avatarImage
        self.avatarAction = avatarAction
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
    var userAvatarData: ChatMessageAvatarData?

    var copyEnabled: Bool {
        switch type {
        case .text, .offer:
            return true
        case .sticker, .disclaimer, .userInfo, .askPhoneNumber, .meeting, .interlocutorIsTyping, .unsupported, .multiAnswer,
             .cta, .carousel:
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
        case .userInfo(let userInfo):
            return userInfo.name
        case .askPhoneNumber(let text, _):
            return text
        case let .meeting(_, _, _, _, _, text):
            return text
        case .multiAnswer(let question, _):
            return question.text
        case .interlocutorIsTyping:
            return "..."
        case .cta(let ctaData, _):
            return ctaData.title ?? ctaData.text ?? ""
        case .carousel:
            return ""
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
                               warningStatus: warningStatus, userAvatarData: userAvatarData)
    }
    
    func markAsReceived(date: Date = Date()) -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt,
                               receivedAt: receivedAt ?? date, readAt: readAt, type: type, status: .received,
                               warningStatus: warningStatus, userAvatarData: userAvatarData)
    }
    
    func markAsRead(date: Date = Date()) -> ChatViewMessage {
        return ChatViewMessage(objectId: objectId, talkerId: talkerId, sentAt: sentAt, receivedAt: receivedAt,
                               readAt: readAt ?? date, type: type, status: .read, warningStatus: warningStatus,
                               userAvatarData: userAvatarData)
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
                                   warningStatus: warningStatus,
                                   userAvatarData: userAvatarData)
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
                                   warningStatus: warningStatus,
                                   userAvatarData: userAvatarData)
        } else {
            return self
        }
    }
}
