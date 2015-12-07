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

public protocol ChatViewModelDelegate {
    func didFailRetrievingChatMessages(error: ChatRetrieveServiceError)
    func didSucceedRetrievingChatMessages()
    func didFailSendingMessage(error: ChatSendMessageServiceError)
    func didSucceedSendingMessage()
}

public class ChatViewModel: BaseViewModel {
    var chatManager: ChatManager
    var userManager: MyUserManager

    public var chat: Chat
    public var otherUser: User?
    public var buyer: User?
    public var delegate: ChatViewModelDelegate?
    public var isNewChat = false
    var isSendingMessage = false
    var askQuestion = false
    public var alreadyAskedForRating = false
    
    public var shouldAskForRating: Bool {
        return !alreadyAskedForRating && !UserDefaultsManager.sharedInstance.loadAlreadyRated()
    }
    
    public var shouldShowSafetyTipes: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen()
        return idxLastPageSeen == nil && didReceiveMessageFromOtherUser
    }
    
    public var safetyTipsCompleted: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        return idxLastPageSeen >= (ChatSafetyTipsView.tipsCount - 1)
    }
    
    public var didReceiveMessageFromOtherUser: Bool {
        guard let otherUserId = otherUser?.objectId else { return false }
        return chat.didReceiveMessageFrom(otherUserId)
    }
    
    public var productViewModel: ProductViewModel {
        return ProductViewModel(product: chat.product, tracker: TrackerProxy.sharedInstance)
    }
    
    public convenience init?(chat: Chat) {
        self.init(chat: chat, userManager: MyUserManager.sharedInstance, chatManager: ChatManager.sharedInstance)
    }
    
    public convenience init?(product: Product, askQuestion: Bool) {
        guard let chatFromProduct = ChatManager.sharedInstance.newChatWithProduct(product) else { return nil }
        self.init(chat: chatFromProduct)
        isNewChat = true
        self.askQuestion = askQuestion
    }
    
    public init?(chat: Chat, userManager: MyUserManager, chatManager: ChatManager) {
        self.chat = chat
        self.userManager = userManager
        self.chatManager = chatManager
        super.init()
        initUsers()
        if otherUser == nil { return nil }
        if buyer == nil { return nil }
    }
    
    
    func initUsers() {
        guard let myUser = userManager.myUser() else { return }
        guard let myUserId = myUser.objectId else { return }
        guard let userFromId = chat.userFrom.objectId else { return }
        guard let productOwnerId = chat.product.user.objectId else { return }
        
        self.otherUser = myUserId == userFromId ? chat.userTo : chat.userFrom
        self.buyer = productOwnerId == userFromId ? chat.userTo : chat.userFrom
    }
    
    public func loadMessages() {
        guard let userBuyer = buyer else { return }
        chatManager.retrieveChatWithProduct(chat.product, buyer: userBuyer) { [weak self] (result: Result<Chat, ChatRetrieveServiceError>) -> Void in
            guard let strongSelf = self else { return }
            if let chat = result.value {
                strongSelf.chat = chat
                strongSelf.delegate?.didSucceedRetrievingChatMessages()
            }
            else if let error = result.error {
                strongSelf.delegate?.didFailRetrievingChatMessages(error)
            }
        }
    }
    
    public func sendMessage(text: String) {
        if isSendingMessage { return }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let toUser = otherUser else { return }
        self.isSendingMessage = true
        
        chatManager.sendText(message, product: chat.product, recipient: toUser) { [weak self] (result: ChatSendMessageServiceResult) -> Void in
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
    
    public func receivedUserInteractionIsValid(userInfo: [NSObject: AnyObject]) -> Bool {
        guard let productId = userInfo["p"] as? String else { return false }
        return chat.product.objectId == productId
    }

    
    // MARK: Tracking
    
    func trackQuestion() {
        let myUser = userManager.myUser()
        let askQuestionEvent = TrackerEvent.productAskQuestion(chat.product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
    }
    
    func trackMessageSent() {
        let myUser = userManager.myUser()
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





