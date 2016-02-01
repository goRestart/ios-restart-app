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
    func updateAfterReceivingMessagesAtPositions(positions: [NSIndexPath])
}

public enum AskQuestionSource {
    case ProductList
    case ProductDetail
}

public class ChatViewModel: BaseViewModel, Paginable {
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

    // MARK: Paginable

    var resultsPerPage: Int = Constants.numMessagesPerPage
    var firstPage: Int = 0
    var nextPage: Int = 0
    var isLastPage: Bool = false
    var isLoading: Bool = false

    var objectCount: Int {
        return loadedMessages.count
    }

    var loadedMessages: [Message]


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
        self.loadedMessages = []
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

    public func getNewMessagesWhileChatting() {
        retrieveNewMessagesWithOffset(10)
    }

    public func sendMessage(text: String) {
        if isSendingMessage { return }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let toUser = otherUser else { return }
        self.isSendingMessage = true

        chatRepository.sendText(message, product: chat.product, recipient: toUser) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let sentMessage = result.value {
                strongSelf.chat.prependMessage(sentMessage)
                strongSelf.loadedMessages.insert(sentMessage, atIndex: 0)
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


    // MARK: - private methods

    /**
    Retrieves the specified number of the newest messages
    
    - parameter offset: the num of messages to retrieve
    */
    private func retrieveNewMessagesWithOffset(offset: Int) {

        guard let userBuyer = buyer else { return }

        isLoading = true
        chatRepository.retrieveMessagesWithProduct(chat.product, buyer: userBuyer, page: 0,
            numResults: offset) { [weak self] (result: Result<Chat, RepositoryError>) -> Void in
                guard let strongSelf = self else { return }
                if let chat = result.value {
                    guard strongSelf.loadedMessages[0].objectId != chat.messages[0].objectId else { return }
                    let insertedMessagesStruct = strongSelf.insertNewMessagesAt(strongSelf.loadedMessages,
                        newMessages: chat.messages)
                    strongSelf.loadedMessages = insertedMessagesStruct.messages
                    strongSelf.delegate?.updateAfterReceivingMessagesAtPositions(insertedMessagesStruct.indexes)
                } else if let error = result.error {
                    switch (error) {
                    case .NotFound:
                        //New chat!! this is success
                        strongSelf.isNewChat = true
                        strongSelf.delegate?.didSucceedRetrievingChatMessages()
                    case .Network, .Unauthorized, .Internal:
                        // if fails to update messages, do nothing
                        break
                    }
                }
                strongSelf.isLoading = false
        }
    }

    /**
    Inserts messages from one array to another, avoiding to insert repetitions.

    - parameter mainMessages: the array with old items
    - parameter newMessages: the array with new items

    - returns: a struct with the FULL array (old + new) and the indexes of the NEW items
    */
    private func insertNewMessagesAt(mainMessages: [Message], newMessages: [Message])
        -> (messages: [Message], indexes: [NSIndexPath]) {
            var idxs: [NSIndexPath] = []
            guard mainMessages.count > 0 else {
                for i in 0..<newMessages.count { idxs.insert(NSIndexPath(forRow: i, inSection: 0), atIndex: i) }
                return (newMessages, idxs)
            }

            guard let indexOfFirstItem = newMessages.indexOf({$0.objectId == mainMessages[0].objectId}) else {
                return (mainMessages, [])
            }

            let reallyNewMessages = newMessages[0..<indexOfFirstItem]
            for i in 0..<reallyNewMessages.count { idxs.insert(NSIndexPath(forRow: i, inSection: 0), atIndex: i) }
            return (reallyNewMessages + mainMessages, idxs)
    }


    // MARK: - Paginable

    internal func retrievePage(page: Int) {

        guard let userBuyer = buyer else { return }

        isLoading = true
        chatRepository.retrieveMessagesWithProduct(chat.product, buyer: userBuyer, page: page,
            numResults: resultsPerPage) { [weak self] (result: Result<Chat, RepositoryError>) -> Void in
                guard let strongSelf = self else { return }
                if let chat = result.value {
                    if page == 0 {
                        strongSelf.loadedMessages = chat.messages
                    } else {
                        strongSelf.loadedMessages += chat.messages
                    }
                    strongSelf.isLastPage = chat.messages.count < strongSelf.resultsPerPage
                    strongSelf.chat = chat
                    strongSelf.nextPage = page + 1
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
                strongSelf.isLoading = false
        }
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
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        let maxPageSeen = max(idxLastPageSeen, page)
        UserDefaultsManager.sharedInstance.saveChatSafetyTipsLastPageSeen(maxPageSeen)
    }
}
