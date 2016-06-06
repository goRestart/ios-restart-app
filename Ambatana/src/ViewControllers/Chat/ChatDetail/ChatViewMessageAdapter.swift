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
    let myUserRepository: MyUserRepository
    
    convenience init() {
        let stickersRepository = Core.stickersRepository
        let myUserRepository = Core.myUserRepository
        self.init(stickersRepository: stickersRepository, myUserRepository: myUserRepository)
    }
    
    init(stickersRepository: StickersRepository, myUserRepository: MyUserRepository) {
        self.stickersRepository = stickersRepository
        self.myUserRepository = myUserRepository
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
        
        let status: ChatMessageStatus = message.isRead ? .Read : .Sent
<<<<<<< HEAD
        return ChatViewMessage(objectId: message.objectId ,talkerId: message.userId, sentAt: message.createdAt,
                               receivedAt: nil, readAt: nil, type: type, status: status,
                               warningStatus: message.warningStatus)
=======
        return ChatViewMessage(objectId: message.objectId ,talkerId: message.userId, sentAt: message.createdAt, receivedAt: nil, readAt: nil,
                               type: type, status: status)
>>>>>>> develop
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
        return ChatViewMessage(objectId: message.objectId, talkerId: message.talkerId, sentAt: message.sentAt,
                               receivedAt: message.receivedAt, readAt: message.readAt, type: type,
                               status: message.messageStatus, warningStatus: .Normal)
    }
<<<<<<< HEAD
    
    func addDisclaimers(messages: [ChatViewMessage], disclaimerMessage: ChatViewMessage) -> [ChatViewMessage] {
        var newMessages: [ChatViewMessage] = []
        messages.forEach { [weak self] message in
            if message.warningStatus == .Suspicious && message.talkerId != self?.myUserRepository.myUser?.objectId {
                newMessages.append(disclaimerMessage)
            }
            newMessages.append(message)
        }
        return newMessages
    }
    
    func createDisclaimerMessage(disclaimerText: NSAttributedString, actionTitle: String?, action: (() -> ())?) -> ChatViewMessage {
        let disclaimer = ChatViewMessageType.Disclaimer(text: disclaimerText, actionTitle: actionTitle, action: action)
        let disclaimerMessage = ChatViewMessage(objectId: nil, talkerId: "", sentAt: nil, receivedAt: nil, readAt: nil,
                                                type: disclaimer, status: nil, warningStatus: .Normal)
        return disclaimerMessage
    }
=======
>>>>>>> develop
}
