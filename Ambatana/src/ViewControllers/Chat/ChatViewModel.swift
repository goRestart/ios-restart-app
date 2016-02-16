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

protocol ChatViewModelDelegate: class {
    func didFailRetrievingChatMessages()
    func didSucceedRetrievingChatMessages()
    func didFailSendingMessage()
    func didSucceedSendingMessage()
    func didUpdateDirectAnswers()
    func didUpdateProduct(messageToShow message: String?)
    func updateAfterReceivingMessagesAtPositions(positions: [Int])
}

enum AskQuestionSource {
    case ProductList
    case ProductDetail
}

public class ChatViewModel: BaseViewModel, Paginable {

    weak var delegate: ChatViewModelDelegate?

    var chat: Chat
    var product: Product
    var otherUser: User?
    var isNewChat = false
    var alreadyAskedForRating = false
    var fromMakeOffer = false
    var askQuestion: AskQuestionSource?
    var shouldAskProductSold: Bool = false
    var shouldShowDirectAnswers: Bool = true
    var userDefaultsSubKey: String {
        return "\(product.objectId) + \(chat.userTo.objectId)"
    }

    private let chatRepository: ChatRepository
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let tracker: Tracker

    private var loadedMessages: [Message]
    private var buyer: User?
    private var isSendingMessage = false

    private var isBuyer: Bool {
        guard let buyerId = buyer?.objectId, myUserId = myUserRepository.myUser?.objectId else { return false }
        return buyerId == myUserId
    }

    // MARK: Paginable

    var resultsPerPage: Int = Constants.numMessagesPerPage
    var firstPage: Int = 0
    var nextPage: Int = 0
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return loadedMessages.count
    }


    // MARK: - Lifecycle

    convenience init?(chat: Chat) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(chat: chat, myUserRepository: myUserRepository, chatRepository: chatRepository,
            productRepository: productRepository, tracker: tracker)
    }

    convenience init?(product: Product) {
        guard let chatFromProduct = Core.chatRepository.newChatWithProduct(product) else { return nil }
        self.init(chat: chatFromProduct)
    }

    init?(chat: Chat, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
        productRepository: ProductRepository, tracker: Tracker) {
            self.chat = chat
            self.myUserRepository = myUserRepository
            self.chatRepository = chatRepository
            self.productRepository = productRepository
            self.tracker = tracker
            self.loadedMessages = []
            self.product = chat.product
            super.init()
            initUsers()
            if otherUser == nil { return nil }
            if buyer == nil { return nil }
            shouldShowDirectAnswers = UserDefaultsManager.sharedInstance.loadShouldShowDirectAnswers(userDefaultsSubKey)
    }


    // MARK: - Public

    var shouldAskForRating: Bool {
        return !alreadyAskedForRating && !UserDefaultsManager.sharedInstance.loadAlreadyRated()
    }

    var shouldShowSafetyTips: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen()
        return idxLastPageSeen == nil && didReceiveMessageFromOtherUser
    }

    var safetyTipsCompleted: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        return idxLastPageSeen >= (ChatSafetyTipsView.tipsCount - 1)
    }

    var didReceiveMessageFromOtherUser: Bool {
        guard let otherUserId = otherUser?.objectId else { return false }
        return chat.didReceiveMessageFrom(otherUserId)
    }

    var productViewModel: ProductViewModel {
        return ProductViewModel(product: product, thumbnailImage: nil)
    }

    var directAnswers: [DirectAnswer] {
        if isBuyer {
            return [DirectAnswer(text: LGLocalizedString.directAnswerInterested, action: nil),
                DirectAnswer(text: LGLocalizedString.directAnswerLikeToBuy, action: nil),
                DirectAnswer(text: LGLocalizedString.directAnswerMorePhotos, action: nil),
                DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: nil)]
        } else {
            return [DirectAnswer(text: LGLocalizedString.directAnswerStillForSale, action: nil),
                DirectAnswer(text: LGLocalizedString.directAnswerWhatsOffer, action: nil),
                DirectAnswer(text: LGLocalizedString.directAnswerProductSold, action: { [weak self] in
                    self?.onProductSoldDirectAnswer()
                })]
        }
    }

    func messageAtIndex(index: Int) -> Message {
        return loadedMessages[index]
    }

    func textOfMessageAtIndex(index: Int) -> String {
        return loadedMessages[index].text
    }

    func avatarForMessage() -> File? {
        return otherUser?.avatar
    }

    func sendMessage(text: String) {
        if isSendingMessage { return }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let toUser = otherUser else { return }
        self.isSendingMessage = true

        chatRepository.sendText(message, product: product, recipient: toUser) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let sentMessage = result.value {
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

    func didReceiveUserInteractionWithInfo(userInfo: [NSObject: AnyObject]) {
        guard let productId = userInfo["p"] as? String where product.objectId == productId else { return }
        retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
    }

    func viewModelForReport() -> ReportUsersViewModel? {
        guard let otherUser = otherUser else { return nil }
        return ReportUsersViewModel(origin: .Chat, userReported: otherUser)
    }

    func toggleDirectAnswers() {
        showDirectAnswers(!shouldShowDirectAnswers)
    }

    func markProductAsSold() {
        productRepository.markProductAsSold(product) { [weak self] result in
            if let value = result.value {
                self?.product = value
                self?.delegate?.didUpdateProduct(messageToShow: LGLocalizedString.productMarkAsSoldSuccessMessage)
            } else {
                self?.delegate?.didUpdateProduct(messageToShow: LGLocalizedString.productMarkAsSoldErrorGeneric)
            }
        }
    }


    // MARK: - private methods

    private func initUsers() {
        guard let myUser = myUserRepository.myUser else { return }
        guard let myUserId = myUser.objectId else { return }
        guard let userFromId = chat.userFrom.objectId else { return }
        guard let productOwnerId = product.user.objectId else { return }

        self.otherUser = myUserId == userFromId ? chat.userTo : chat.userFrom
        self.buyer = productOwnerId == userFromId ? chat.userTo : chat.userFrom
    }

    /**
    Retrieves the specified number of the newest messages

    - parameter numResults: the num of messages to retrieve
    */
    private func retrieveFirstPageWithNumResults(numResults: Int) {

        guard let userBuyer = buyer else { return }

        guard canRetrieve else { return }

        isLoading = true
        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, page: 0,
            numResults: numResults) { [weak self] result in
                guard let strongSelf = self else { return }
                if let chat = result.value {
                    let insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(strongSelf.loadedMessages,
                        newMessages: chat.messages)
                    strongSelf.loadedMessages = insertedMessagesInfo.messages
                    strongSelf.delegate?.updateAfterReceivingMessagesAtPositions(insertedMessagesInfo.indexes)
                }
                strongSelf.isLoading = false
        }
    }

    /**
    Inserts messages from one array to another, avoiding to insert repetitions.

    Since messages sent are inserted at the table, but don't have Id, those messages are filtered
    when updating the table.

    - parameter mainMessages: the array with old items
    - parameter newMessages: the array with new items

    - returns: a struct with the FULL array (old + new) and the indexes of the NEW items
    */
    static func insertNewMessagesAt(mainMessages: [Message], newMessages: [Message])
        -> (messages: [Message], indexes: [Int]) {

            guard !newMessages.isEmpty else { return (mainMessages, []) }

            // - idxs: the positions of the table that will be inserted
            var idxs: [Int] = []

            var firstMsgWithId: Message? = nil
            var messagesWithId: [Message] = mainMessages

            // - messages sent don't have Id until the list is refreshed (push received or view appears)
            for message in mainMessages {
                if message.objectId != nil {
                    firstMsgWithId = message
                    break
                }
                // last "sent messages" are removed, if any
                messagesWithId.removeFirst()
            }
            // myMessagesWithoutIdCount : num of positions that shouldn't be updated in the table
            let myMessagesWithoutIdCount = mainMessages.count - messagesWithId.count

            guard let firstMsgId = firstMsgWithId?.objectId,
                let indexOfFirstNewItem = newMessages.indexOf({$0.objectId == firstMsgId}) else {
                    for i in 0..<newMessages.count-myMessagesWithoutIdCount { idxs.append(i) }
                    return (newMessages + messagesWithId, idxs)
            }

            // newMessages can be a whole page, so "reallyNewMessages" are only the ones
            // that come as newMessages and haven't been loaded before
            let reallyNewMessages = newMessages[0..<indexOfFirstNewItem]
            for i in 0..<reallyNewMessages.count-myMessagesWithoutIdCount { idxs.append(i) }

            return (reallyNewMessages + messagesWithId, idxs)
    }

    private func onProductSoldDirectAnswer() {
        if chat.status != ChatStatus.Sold {
            shouldAskProductSold = true
        }
    }


    // MARK: - Paginable

    internal func retrievePage(page: Int) {

        guard let userBuyer = buyer else { return }

        isLoading = true
        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, page: page,
            numResults: resultsPerPage) { [weak self] result in
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
                        strongSelf.isLastPage = true
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
        let askQuestionEvent = TrackerEvent.productAskQuestion(product, user: myUser, typePage: typePageParam)
        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
    }

    func trackMessageSent() {
        let myUser = myUserRepository.myUser
        let messageSentEvent = TrackerEvent.userMessageSent(product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
    }
    
    
    // MARK: Safety Tips
    
    func updateChatSafetyTipsLastPageSeen(page: Int) {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        let maxPageSeen = max(idxLastPageSeen, page)
        UserDefaultsManager.sharedInstance.saveChatSafetyTipsLastPageSeen(maxPageSeen)
    }
}


// MARK: - DirectAnswers

extension ChatViewModel: DirectAnswersViewControllerDelegate {
    func directAnswersDidTapAnswer(controller: DirectAnswersViewController, answer: DirectAnswer) {
        sendMessage(answer.text)
        guard let actionBlock = answer.action else { return }
        actionBlock()
    }

    func directAnswersDidTapClose(controller: DirectAnswersViewController) {
        showDirectAnswers(false)
    }

    private func showDirectAnswers(show: Bool) {
        shouldShowDirectAnswers = show
        UserDefaultsManager.sharedInstance.saveShouldShowDirectAnswers(show, subKey: userDefaultsSubKey)
        delegate?.didUpdateDirectAnswers()
    }
}
