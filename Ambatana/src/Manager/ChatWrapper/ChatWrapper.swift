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
}

protocol ChatWrapper {
    func sendMessageFor(listing: Listing, type: ChatWrapperMessageType, completion: ChatWrapperCompletion?)
}

class LGChatWrapper: ChatWrapper {

    private let chatRepository: ChatRepository
    private let myUserRepository: MyUserRepository
    private let featureFlags: FeatureFlaggeable

    convenience init() {
        self.init(chatRepository: Core.chatRepository, myUserRepository: Core.myUserRepository,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(chatRepository: ChatRepository, myUserRepository: MyUserRepository,
         featureFlags: FeatureFlaggeable) {
        self.chatRepository = chatRepository
        self.myUserRepository = myUserRepository
        self.featureFlags = featureFlags
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

        sendWebSocketChatMessage(listingId, sellerId: sellerId, text: type.text, type: type.chatType, completion: completion)
    }

    private func sendWebSocketChatMessage(_ listingId: String, sellerId: String, text: String, type: ChatMessageType,
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

                let message = self?.chatRepository.createNewMessage(userId, text: text, type: type)

                guard let messageId = message?.objectId else {
                    completion?(Result(error: .internalError(message: "There's no message info")))
                    return
                }
                let shouldSendFirstMessageEvent = value.lastMessageSentAt == nil
                self?.chatRepository.sendMessage(conversationId, messageId: messageId, type: type, text: text) { result in
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
            return quickAnswer.text
        case let .expressChat(text):
            return text
        case let .favoritedListing(text):
            return text
        case let .periscopeDirect(text):
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
        case .quickAnswer:
            return .quickAnswer
        case .expressChat:
            return .expressChat
        case .favoritedListing:
            return .favoritedListing
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
        }
    }

    var quickAnswerType: EventParameterQuickAnswerType? {
        switch self {
        case let .quickAnswer(quickAnswer):
            return quickAnswer.quickAnswerType
        case .text, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect:
            return nil
        }
    }

    var isUserText: Bool {
        switch self {
        case .text:
            return true
        case .quickAnswer, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect:
            return false
        }
    }

    var isQuickAnswer: Bool {
        switch self {
        case .quickAnswer:
            return true
        case .text, .chatSticker, .expressChat, .favoritedListing, .periscopeDirect:
            return false
        }
    }
}
