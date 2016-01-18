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

public protocol ChatViewModelDelegate: class {
    func didFailRetrievingChatMessages()
    func didSucceedRetrievingChatMessages()
    func didFailSendingMessage()
    func didSucceedSendingMessage()
}

public enum AskQuestionSource {
    case ProductList
    case ProductDetail
}

public class ChatViewModel: BaseViewModel {
    let chatRepository: ChatRepository
    let myUserRepository: MyUserRepository
    let tracker: Tracker

    public var chat: Chat
    public var otherUser: User?
    public var buyer: User?
    public weak var delegate: ChatViewModelDelegate?
    public var isNewChat = false
    var isSendingMessage = false
    var askQuestion: AskQuestionSource?
    public var alreadyAskedForRating = false
    public var fromMakeOffer = false

    public var shouldAskForRating: Bool {
        return !alreadyAskedForRating && !Core.userDefaultsManager.loadAlreadyRated()
    }
    
    public var shouldShowSafetyTipes: Bool {
        let idxLastPageSeen = Core.userDefaultsManager.loadChatSafetyTipsLastPageSeen()
        return idxLastPageSeen == nil && didReceiveMessageFromOtherUser
    }
    
    public var safetyTipsCompleted: Bool {
        let idxLastPageSeen = Core.userDefaultsManager.loadChatSafetyTipsLastPageSeen() ?? 0
        return idxLastPageSeen >= (ChatSafetyTipsView.tipsCount - 1)
    }
    
    public var didReceiveMessageFromOtherUser: Bool {
        guard let otherUserId = otherUser?.objectId else { return false }
        return chat.didReceiveMessageFrom(otherUserId)
    }
    
    public var productViewModel: ProductViewModel {
        return ProductViewModel(product: chat.product, thumbnailImage: nil)
    }
    
    public convenience init?(chat: Chat) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(chat: chat, myUserRepository: myUserRepository, chatRepository: chatRepository, tracker: tracker)
    }
    
    public convenience init?(product: Product) {
        guard let chatFromProduct = Core.chatRepository.newChatWithProduct(product) else { return nil }
        self.init(chat: chatFromProduct)
    }
    
    public init?(chat: Chat, myUserRepository: MyUserRepository, chatRepository: ChatRepository, tracker: Tracker) {
        self.chat = chat
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.tracker = tracker
        super.init()
        initUsers()
        if otherUser == nil { return nil }
        if buyer == nil { return nil }
    }
    
    
    func initUsers() {
        guard let myUser = myUserRepository.myUser else { return }
        guard let myUserId = myUser.objectId else { return }
        guard let userFromId = chat.userFrom.objectId else { return }
        guard let productOwnerId = chat.product.user.objectId else { return }

        self.otherUser = myUserId == userFromId ? chat.userTo : chat.userFrom
        self.buyer = productOwnerId == userFromId ? chat.userTo : chat.userFrom
    }
    
    public func loadMessages() {
        guard let userBuyer = buyer else { return }
        chatRepository.retrieveChatWithProduct(chat.product, buyer: userBuyer) { [weak self] (result: Result<Chat, RepositoryError>) -> Void in
            guard let strongSelf = self else { return }
            if let chat = result.value {
                strongSelf.chat = chat
                strongSelf.delegate?.didSucceedRetrievingChatMessages()
            } else if let error = result.error {
                switch (error) {
                case .NotFound:
                    //New chat!! this is success
                    strongSelf.isNewChat = true
                    strongSelf.delegate?.didSucceedRetrievingChatMessages()
                case .Network, .Unauthorized, .Internal:
                    strongSelf.delegate?.didFailRetrievingChatMessages()
                }
            }
        }
    }
    
    public func sendMessage(text: String) {
        if isSendingMessage { return }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let toUser = otherUser else { return }
        self.isSendingMessage = true
        
        chatRepository.sendText(message, product: chat.product, recipient: toUser) { [weak self] (result: Result<Message, RepositoryError>) -> Void in
            guard let strongSelf = self else { return }
            if let sentMessage = result.value {
                strongSelf.chat.prependMessage(sentMessage)
                strongSelf.delegate?.didSucceedSendingMessage()

                if let askQuestion = strongSelf.askQuestion {
                    strongSelf.askQuestion = nil
                    strongSelf.trackQuestion(askQuestion)
                }
                strongSelf.trackMessageSent()
            } else if let _ = result.error {
                strongSelf.delegate?.didFailSendingMessage()
            }
            strongSelf.isSendingMessage = false
        }
    }
    
    public func receivedUserInteractionIsValid(userInfo: [NSObject: AnyObject]) -> Bool {
        guard let productId = userInfo["p"] as? String else { return false }
        return chat.product.objectId == productId
    }

    
    // MARK: Tracking
    
    func trackQuestion(source: AskQuestionSource) {
        let myUser = myUserRepository.myUser
        let typePageParam: EventParameterTypePage
        switch source {
        case .ProductDetail:
            typePageParam = .ProductDetail
        case .ProductList:
            typePageParam = .ProductList
        }
        let askQuestionEvent = TrackerEvent.productAskQuestion(chat.product, user: myUser, typePage: typePageParam)
        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
    }
    
    func trackMessageSent() {
        let myUser = myUserRepository.myUser
        let messageSentEvent = TrackerEvent.userMessageSent(chat.product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
    }
    
    
    // MARK: Safety Tips
    
    public func updateChatSafetyTipsLastPageSeen(page: Int) {
        let idxLastPageSeen = Core.userDefaultsManager.loadChatSafetyTipsLastPageSeen() ?? 0
        let maxPageSeen = max(idxLastPageSeen, page)
        Core.userDefaultsManager.saveChatSafetyTipsLastPageSeen(maxPageSeen)
    }
}





