//
//  ChatViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Result

protocol ChatViewModelDelegate {
    func didFailRetrievingChatMessages(error: ChatRetrieveServiceError)
    func didSucceedRetrievingChatMessages()
    func didFailSendingMessage(error: ChatSendMessageServiceError)
    func didSucceedSendingMessage()
}

public class ChatViewModel: BaseViewModel {
    let chatManager = ChatManager.sharedInstance

    var chat: Chat
    var otherUser: User?
    var buyer: User?
    var delegate: ChatViewModelDelegate?
    var isNewChat = false
    var isSendingMessage = false
    var askQuestion = false
    
    var shouldShowSafetyTipes: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen()
        return idxLastPageSeen == nil && didReceiveMessageFromOtherUser
    }
    
    var safetyTypesCompleted: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        return idxLastPageSeen >= (ChatSafetyTipsView.tipsCount - 1)
    }
    
    var didReceiveMessageFromOtherUser: Bool {
        guard let otherUserId = otherUser?.objectId else { return false }
        return chat.didReceiveMessageFrom(otherUserId)
    }
    
    init(chat: Chat) {
        self.chat = chat
        super.init()
        initUsers()
    }
    
    convenience init?(product: Product, askQuestion: Bool) {
        guard let chatFromProduct = ChatManager.sharedInstance.newChatWithProduct(product) else { return nil }
        self.init(chat: chatFromProduct)
        isNewChat = true
        self.askQuestion = askQuestion
    }
    
    func initUsers() {
        guard let myUser = MyUserManager.sharedInstance.myUser() else { return }
        guard let myUserId = myUser.objectId else { return }
        guard let userFromId = chat.userFrom.objectId else { return }
        guard let productOwnerId = chat.product.user.objectId else { return }
        
        self.otherUser = myUserId == userFromId ? chat.userTo : chat.userFrom
        self.buyer = productOwnerId == userFromId ? chat.userTo : chat.userFrom
    }
    
    func loadMessages() {
        guard let userBuyer = buyer else { return }
        chatManager.retrieveChatWithProduct(chat.product, buyer: userBuyer) { [weak self] (result: Result<Chat, ChatRetrieveServiceError>) -> Void in
            guard let strongSelf = self else { return }
            
            // Success
            if let chat = result.value {
                strongSelf.chat = chat
                strongSelf.delegate?.didSucceedRetrievingChatMessages()
            }
                // Error
            else if let error = result.error {
                strongSelf.delegate?.didFailRetrievingChatMessages(error)
            }
        }
    }
    
    func sendMessage(text: String) {
        if isSendingMessage { return }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let toUser = otherUser else { return }
        self.isSendingMessage = true
        
        ChatManager.sharedInstance.sendText(message, product: chat.product, recipient: toUser) { [weak self] (result: ChatSendMessageServiceResult) -> Void in
            guard let strongSelf = self else { return }
            if let sentMessage = result.value {
                strongSelf.chat.prependMessage(sentMessage)
                strongSelf.delegate?.didSucceedSendingMessage()
                
                if strongSelf.askQuestion {
                    strongSelf.askQuestion = false
                    strongSelf.trackQuestion()
                }
                strongSelf.trackMessageSent()
            }
            else if let error = result.error {
                strongSelf.delegate?.didFailSendingMessage(error)
            }
            
            strongSelf.isSendingMessage = false
        }
    }
    
    
    // MARK: Tracking
    
    func trackQuestion() {
        let myUser = MyUserManager.sharedInstance.myUser()
        let askQuestionEvent = TrackerEvent.productAskQuestion(chat.product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
    }
    
    func trackMessageSent() {
        let myUser = MyUserManager.sharedInstance.myUser()
        let messageSentEvent = TrackerEvent.userMessageSent(chat.product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
    }
    
    
    // MARK: Safety Tips
    
    public func updateChatSafetyTipsLastPageSeen(page: Int) {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        let maxPageSeen = max(idxLastPageSeen, page)
        UserDefaultsManager.sharedInstance.saveChatSafetyTipsLastPageSeen(maxPageSeen)
    }
}





