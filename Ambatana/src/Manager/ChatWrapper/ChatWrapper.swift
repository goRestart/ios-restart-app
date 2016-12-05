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

public typealias ChatWrapperResult = Result<Bool, RepositoryError>
public typealias ChatWrapperCompletion = ChatWrapperResult -> Void

enum ChatWrapperMessageType {
    case Text(String)
    case ChatSticker(Sticker)
    case QuickAnswer(String)
    case ExpressChat(String)
    case FavoritedProduct(String)
}

class ChatWrapper {

    private let chatRepository: ChatRepository
    private let oldChatRepository: OldChatRepository
    private let myUserRepository: MyUserRepository
    private let featureFlags: FeatureFlaggeable

    convenience init() {
        self.init(chatRepository: Core.chatRepository, oldChatRepository: Core.oldChatRepository,
                  myUserRepository: Core.myUserRepository, featureFlags: FeatureFlags.sharedInstance)
    }

    init(chatRepository: ChatRepository, oldChatRepository: OldChatRepository, myUserRepository: MyUserRepository,
         featureFlags: FeatureFlaggeable) {
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.myUserRepository = myUserRepository
        self.featureFlags = featureFlags
    }


    func sendMessageForProduct(product: Product, type: ChatWrapperMessageType, completion: ChatWrapperCompletion?) {
        if featureFlags.websocketChat {
            sendWebSocketChatMessage(product, text: type.text, type: type.chatType, completion: completion)
        } else {
            sendOldChatMessage(product, text: type.text, type: type.oldChatType, completion: completion)
        }
    }

    private func sendOldChatMessage(product: Product, text: String?, type: MessageType, completion: ChatWrapperCompletion?) {
        guard let text = text else {
            completion?(Result(error: .Internal(message: "There's no message to send")))
            return
        }
        oldChatRepository.sendMessage(type, message: text, product: product, recipient: product.user) { result in
            if let _ = result.value {
                // Value is true as we can't know (old chat)  if it is first contact or not. (always track)
                completion?(Result(value: true))
            } else if let error = result.error {
                completion?(Result(error: error))
            }
        }
    }

    private func sendWebSocketChatMessage(product: Product, text: String, type: ChatMessageType,
                                          completion: ChatWrapperCompletion?) {
        // get conversation
        guard let sellerId = product.user.objectId else {
            completion?(Result(error: .Internal(message: "There's no recipient to send the message")))
            return
        }
        guard let productId = product.objectId else {
            completion?(Result(error: .Internal(message: "There's no product to send the message")))
            return
        }
        chatRepository.showConversation(sellerId, productId: productId) { [weak self] result in
            if let value = result.value {
                guard let conversationId = value.objectId else {
                    completion?(Result(error: .Internal(message: "There's no conversation info")))
                    return
                }
                guard let userId = self?.myUserRepository.myUser?.objectId else {
                    completion?(Result(error: .Internal(message: "There's no myUser info")))
                    return
                }

                let message = self?.chatRepository.createNewMessage(userId, text: text, type: type)

                guard let messageId = message?.objectId else {
                    completion?(Result(error: .Internal(message: "There's no message info")))
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
        case let .Text(text):
            return text
        case let .ChatSticker(sticker):
            return sticker.name
        case let .QuickAnswer(text):
            return text
        case let .ExpressChat(text):
            return text
        case let .FavoritedProduct(text):
            return text
        }
    }

    var oldChatType: MessageType {
        switch self {
        case .Text:
            return .Text
        case .ChatSticker:
            return .Sticker
        case .QuickAnswer, .ExpressChat, .FavoritedProduct: // Legacy chat doesn't use this types
            return .Text
        }
    }

    var chatType: ChatMessageType {
        switch self {
        case .Text:
            return .Text
        case .ChatSticker:
            return .Sticker
        case .QuickAnswer:
            return .QuickAnswer
        case .ExpressChat:
            return .ExpressChat
        case .FavoritedProduct:
            return .FavoritedProduct
        }
    }
}
