//
//  ChatMessageType.swift
//  LGCoreKit
//
//  Created by Nestor on 13/04/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public enum ChatMessageType: Equatable {
    case text
    case offer
    case sticker
    case quickAnswer(id: String?, text: String)
    case expressChat
    case favoritedListing
    case phone
    case meeting
    case multiAnswer(question: ChatQuestion, answers: [ChatAnswer])
    case unsupported(defaultText: String?)
    case interlocutorIsTyping
    
    // Some types of messages are not allowed to be sent from client
    var canSend: Bool {
        switch self {
        case .text, .offer, .sticker, .quickAnswer, .expressChat, .favoritedListing, .phone, .meeting:
            return true
        case .interlocutorIsTyping, .unsupported, .multiAnswer:
            return false
        }
    }
    
    var quickAnswerId: String? {
        if case .quickAnswer(let id, _) = self {
            return id
        }
        return nil
    }
    
    // MARK: Equatable
    
    static public func == (lhs: ChatMessageType, rhs: ChatMessageType) -> Bool {
        switch lhs {
        case .text:
            if case .text = rhs { return true }
        case .offer:
            if case .offer = rhs { return true }
        case .sticker:
            if case .sticker = rhs { return true }
        case .quickAnswer:
            if case .quickAnswer = rhs { return true }
        case .expressChat:
            if case .expressChat = rhs { return true }
        case .favoritedListing:
            if case .favoritedListing = rhs { return true }
        case .phone:
            if case .phone = rhs { return true }
        case .meeting:
            if case .meeting = rhs { return true }
        case .multiAnswer(let lhsQuestion, let lhsAnswers):
            if case .multiAnswer(let rhsQuestion, let rhsAnswers) = rhs {
                guard let lgLhsQuestion = lhsQuestion as? LGChatQuestion,
                    let lgRhsQuestion = rhsQuestion as? LGChatQuestion,
                    let lgLhsAnswers = lhsAnswers as? [LGChatAnswer],
                    let lgRhsAnswers = rhsAnswers as? [LGChatAnswer]
                    else { return false }
                return lgLhsQuestion == lgRhsQuestion && lgLhsAnswers == lgRhsAnswers
            }
        case .unsupported(let lhsDefaultText):
            if case .unsupported(let rhsDefaultText) = rhs {
                return lhsDefaultText == rhsDefaultText
            }
        case .interlocutorIsTyping:
            if case .interlocutorIsTyping = rhs { return true }
        }
        return false
    }
}

