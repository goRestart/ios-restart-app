//
//  ChatWrapper.swift
//  LetGo
//
//  Created by Dídac on 10/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Result

typealias ChatWrapperResult = Result<Bool, RepositoryError>
typealias ChatWrapperCompletion = (ChatWrapperResult) -> Void

enum ChatWrapperMessageType {
    case text(String)
    case periscopeDirect(String)
    case chatSticker(Sticker)
    case quickAnswer(QuickAnswer)
    case expressChat(String)
    case favoritedListing(String)
    case interested(String)
    case phone(String)
    case meeting(meeting: AssistantMeeting, text: String, isSuggestedPlace: Bool?)
    
    var quickAnswerKey: String? {
        if case .quickAnswer(let quickAnswer) = self {
            return quickAnswer.key
        }
        return nil
    }
}

protocol ChatWrapper {
    func sendMessageFor(listing: Listing, type: ChatWrapperMessageType, completion: ChatWrapperCompletion?)
}

class LGChatWrapper: ChatWrapper {

    private let chatRepository: ChatRepository
    private let myUserRepository: MyUserRepository

    convenience init() {
        self.init(chatRepository: Core.chatRepository, myUserRepository: Core.myUserRepository)
    }

    init(chatRepository: ChatRepository, myUserRepository: MyUserRepository) {
        self.chatRepository = chatRepository
        self.myUserRepository = myUserRepository
    }

    func sendMessageFor(listing: Listing, type: ChatWrapperMessageType, completion: ChatWrapperCompletion?) {
        guard let sellerId = listing.user.objectId else {
            completion?(Result(error: .internalError(message: "There's no recipient to send the message")))
            return
        }
        guard let listingId = listing.objectId else {
            completion?(Result(error: .internalError(message: "There's no listing to send the message")))
            return
        }

        sendChatMessage(listingId, sellerId: sellerId, text: type.text, type: type, completion: completion)
    }

    private func sendChatMessage(_ listingId: String, sellerId: String, text: String, type: ChatWrapperMessageType,
                                          completion: ChatWrapperCompletion?) {
        // get conversation
        chatRepository.showConversation(sellerId, listingId: listingId) { [weak self] result in
            if let value = result.value {
                guard let conversationId = value.objectId else {
                    completion?(Result(error: .internalError(message: "There's no conversation info")))
                    return
                }
                guard let userId = self?.myUserRepository.myUser?.objectId else {
                    completion?(Result(error: .internalError(message: "There's no myUser info")))
                    return
                }

                let message = self?.chatRepository.createNewMessage(messageId: nil,
                                                                    talkerId: userId,
                                                                    text: text,
                                                                    type: type.chatType)
                
                guard let messageId = message?.objectId else {
                    completion?(Result(error: .internalError(message: "There's no message info")))
                    return
                }
                let shouldSendFirstMessageEvent = value.lastMessageSentAt == nil
                self?.chatRepository.sendMessage(conversationId, messageId: messageId, type: type.websocketType, text: text, answerKey: type.quickAnswerKey) { result in
                    if let _ = result.value {
                        completion?(Result(value: shouldSendFirstMessageEvent))
                    } else if let error = result.error {
                        completion?(Result(error: error))
                    }
                }
            } else if let error = result.error {
                completion?(Result(error: error))
            }
        }
    }
}

extension ChatWrapperMessageType {
    var text: String {
        switch self {
        case let .text(text):
            return text
        case let .chatSticker(sticker):
            return sticker.name
        case let .quickAnswer(quickAnswer):
            return quickAnswer.textToReply
        case let .expressChat(text):
            return text
        case let .favoritedListing(text):
            return text
        case let .periscopeDirect(text):
            return text
        case let .interested(text):
            return text
        case let .phone(text):
            return text
        case let .meeting(_,text, _):
            return text
        }
    }

    var chatType: ChatMessageType {
        switch self {
        case .text:
            return .text
        case .periscopeDirect:
            return .text
        case .chatSticker:
            return .sticker
        case .quickAnswer(let quickAnswer):
            return .quickAnswer(id: quickAnswer.id, text: quickAnswer.textToReply)
        case .expressChat:
            return .expressChat
        case .favoritedListing:
            return .favoritedListing
        case .interested:
            return .interested
        case .phone:
            return .phone
        case .meeting:
            return .meeting
        }
    }
    
    var websocketType: WebSocketSendMessageType {
        switch self {
        case .text:
            return .text
        case .periscopeDirect:
            return .text
        case .chatSticker:
            return .sticker
        case .quickAnswer:
            return .quickAnswer
        case .expressChat:
            return .expressChat
        case .favoritedListing:
            return .favoritedListing
        case .interested:
            return .interested
        case .phone:
            return .phone
        case .meeting:
            return .meeting
        }
    }

    var chatTrackerType: EventParameterMessageType {
        switch self {
        case .text:
            return .text
        case .chatSticker:
            return .sticker
        case .quickAnswer:
            return .quickAnswer
        case .expressChat:
            return .expressChat
        case .favoritedListing:
            return .favorite
        case .periscopeDirect:
            return .periscopeDirect
        case .interested:
            return .interested
        case .phone:
            return .phone
        case .meeting:
            return .meeting
        }
    }

    var quickAnswerTypeParameter: String? {
        switch self {
        case let .quickAnswer(quickAnswer):
            return quickAnswer.quickAnswerTypeParameter
        case .text, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect, .interested, .phone, .meeting:
            return nil
        }
    }

    var isUserText: Bool {
        switch self {
        case .text:
            return true
        case .quickAnswer, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect, .interested, .phone, .meeting:
            return false
        }
    }

    var isQuickAnswer: Bool {
        switch self {
        case .quickAnswer:
            return true
        case .text, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect, .interested, .phone, .meeting:
            return false
        }
    }

    var isPhone: Bool {
        switch self {
        case .phone:
            return true
        case .text, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect, .interested, .quickAnswer, .meeting:
            return false
        }
    }

    var assistantMeeting: AssistantMeeting? {
        switch self {
        case let .meeting(assistantMeeting, _, _):
            return assistantMeeting
        case .text, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect, .interested, .phone, .quickAnswer:
            return nil
        }
    }

    var isSuggestedPlace: Bool? {
        switch self {
        case let .meeting(_, _, isSuggestedPlace):
            return isSuggestedPlace
        case .text, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect, .phone, .quickAnswer, .interested:
            return nil
        }
    }
}
