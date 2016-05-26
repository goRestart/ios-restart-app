//
//  ChatViewMessageAdapter.swift
//  LetGo
//
//  Created by Isaac Roldan on 24/5/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

class ChatViewMessageAdapter {
    let stickersRepository: StickersRepository
    
    convenience init() {
        let stickersRepository = Core.stickersRepository
        self.init(stickersRepository: stickersRepository)
    }
    
    init(stickersRepository: StickersRepository) {
        self.stickersRepository = stickersRepository
    }
    
    func adapt(message: Message) -> ChatViewMessage {
        
        let type: ChatViewMessageType
        switch message.type {
        case .Offer:
            type = ChatViewMessageType.Offer(text: message.text)
        case .Text:
            type = ChatViewMessageType.Text(text: message.text)
        case .Sticker:
            if let sticker = stickersRepository.sticker(message.text) {
                type = ChatViewMessageType.Sticker(url: sticker.url)
            } else {
                type = ChatViewMessageType.Text(text: message.text)
            }
        }
        
        let status = ChatMessageStatus.fromMessageStatus(message.status)
        return ChatViewMessage(objectId: message.objectId ,talkerId: message.userId, sentAt: message.createdAt, receivedAt: nil, readAt: nil,
                               type: type, status: status)
    }
    
    func adapt(message: ChatMessage) -> ChatViewMessage {
        
        let type: ChatViewMessageType
        switch message.type {
        case .Offer:
            type = ChatViewMessageType.Offer(text: message.text)
        case .Text:
            type = ChatViewMessageType.Text(text: message.text)
        case .Sticker:
            if let sticker = stickersRepository.sticker(message.text) {
                type = ChatViewMessageType.Sticker(url: sticker.url)
            } else {
                type = ChatViewMessageType.Text(text: message.text)
            }
        }
        return ChatViewMessage(objectId: message.objectId, talkerId: message.talkerId, sentAt: message.sentAt, receivedAt: message.receivedAt,
                               readAt: message.readAt, type: type, status: message.messageStatus)
    }
}

extension ChatMessageStatus {
    static func fromMessageStatus(messageStatus: MessageStatus?) -> ChatMessageStatus {
        guard let status = messageStatus else { return .Unknown }
        switch status {
        case .Read:
            return .Read
        case .Sent:
            return .Sent
        }
    }
}
