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

public typealias ChatWrapperResult = Result<Void, RepositoryError>
public typealias ChatWrapperCompletion = ChatWrapperResult -> Void

class ChatWrapper {

    private let chatRepository: ChatRepository
    private let oldChatRepository: OldChatRepository
    private let myUserRepository: MyUserRepository

    convenience init() {
        self.init(chatRepository: Core.chatRepository, oldChatRepository: Core.oldChatRepository,
                  myUserRepository: Core.myUserRepository)
    }

    init(chatRepository: ChatRepository, oldChatRepository: OldChatRepository, myUserRepository: MyUserRepository) {
        self.chatRepository = chatRepository
        self.oldChatRepository = oldChatRepository
        self.myUserRepository = myUserRepository
    }


    func sendMessageForProduct(product: Product, text: String?, sticker: Sticker?, type: ChatMessageType, completion: ChatWrapperCompletion?) {
        if FeatureFlags.websocketChat {
            guard let text = text else {
                completion?(Result(error: .Internal(message: "There's no message to send")))
                return
            }
            sendWebSocketChatMessage(product, text: text, type: type, completion: completion)
        } else {
            sendOldChatMessage(product, text: text, sticker: sticker, type: type.oldChatType, completion: completion)
        }
    }

    private func sendOldChatMessage(product: Product, text: String?, sticker: Sticker?, type: MessageType, completion: ChatWrapperCompletion?) {
        guard let text = text else {
            completion?(Result(error: .Internal(message: "There's no message to send")))
            return
        }
        oldChatRepository.sendMessage(type, message: text, product: product, recipient: product.user) { result in
            if let _ = result.value {
                completion?(Result(value: Void()))
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
                self?.chatRepository.sendMessage(conversationId, messageId: messageId, type: type, text: text) { result in
                    if let _ = result.value {
                        completion?(Result(value: Void()))
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


private extension ChatMessageType {
    var oldChatType: MessageType {
        switch self {
        case .Text:
            return .Text
        case .Offer:
            return .Offer
        case .Sticker:
            return .Sticker
        }
    }
}
