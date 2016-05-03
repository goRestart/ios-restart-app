//
//  ChatViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 27/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift
import CollectionVariable

protocol ChatViewModelDelegate: BaseViewModelDelegate {
    func vmDidUpdateDirectAnswers()
    
    func vmShowProduct(productVC: UIViewController)
    func vmShowProductRemovedError()
    func vmShowProductSoldError()
    func vmShowUser(userVM: UserViewModel)
    
    func vmShowSafetyTips()
    
    func vmAskForRating()
    func vmShowPrePermissions()
    func vmShowMessage(message: String, completion: (() -> ())?)
    func vmShowOptionsList(options: [String], actions: [()->Void])
    func vmShowQuestion(title title: String, message: String, positiveText: String, positiveAction: (()->Void)?,
                              positiveActionStyle: UIAlertActionStyle?, negativeText: String, negativeAction: (()->Void)?,
                              negativeActionStyle: UIAlertActionStyle?)
    
    func vmClose()
}

struct EmptyConversation: ChatConversation {
    var objectId: String?
    var unreadMessageCount: Int = 0
    var lastMessageSentAt: NSDate? = nil
    var product: ChatProduct? = nil
    var interlocutor: ChatInterlocutor? = nil
    var amISelling: Bool 
}

class ChatViewModel: BaseViewModel {
    
    
    // MARK: - Properties
    
    // Protocols
    weak var delegate: ChatViewModelDelegate?
    
    // Paginable
    var resultsPerPage: Int = Constants.numMessagesPerPage
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return messages.value.count
    }

    // Public Model info
    var title = Variable<String>("")
    var productName = Variable<String>("")
    var productImageUrl = Variable<NSURL?>(nil)
    var productPrice = Variable<String>("")
    var interlocutorAvatarURL = Variable<NSURL?>(nil)
    var interlocutorName = Variable<String>("")
    var interlocutorId = Variable<String?>(nil)
    var keyForTextCaching: String { return userDefaultsSubKey }
    
    // Helper computed vars
    var safetyTipsCompleted: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        return idxLastPageSeen >= (ChatSafetyTipsView.tipsCount - 1)
    }
    
    private var shouldAskForRating: Bool {
        return !alreadyAskedForRating && !UserDefaultsManager.sharedInstance.loadAlreadyRated()
    }
    
    private var shouldShowSafetyTips: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen()
        return idxLastPageSeen == nil && didReceiveMessageFromOtherUser
    }
    
    private var didReceiveMessageFromOtherUser: Bool {
        for message in messages.value {
            if message.talkerId == conversation.value.interlocutor?.objectId {
                return true
            }
        }
        return false
    }
    
    var shouldShowDirectAnswers: Bool {
        return chatEnabled.value && UserDefaultsManager.sharedInstance.loadShouldShowDirectAnswers(userDefaultsSubKey)
    }
    
    // Rx Variables
    var interlocutorIsMuted = Variable<Bool>(false)
    var interlocutorHasMutedYou = Variable<Bool>(false)
    var chatStatus = Variable<ChatInfoViewStatus>(.Available)
    var chatEnabled = Variable<Bool>(false)
    var interlocutorTyping = Variable<Bool>(false)
    var messages = CollectionVariable<ChatMessage>([])
    private var conversation: Variable<ChatConversation>
    
    // Private    
    private let myUserRepository: MyUserRepository
    private let chatRepository: ChatRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let tracker: Tracker
    
    private var isDeleted = false
    private var alreadyAskedForRating = false
    private var shouldAskProductSold: Bool = false
    private var isSendingMessage = false

    private var disposeBag = DisposeBag()
    
    private var userDefaultsSubKey: String {
        return "\(conversation.value.product?.objectId) + \(conversation.value.interlocutor?.objectId)"
    }
    
    convenience init?(conversation: ChatConversation) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(conversation: conversation, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository, tracker: tracker)
    }
    
    convenience init?(productId: String, sellerId: String) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        
        let amISelling = myUserRepository.myUser?.objectId == sellerId
        let empty = EmptyConversation(objectId: nil, unreadMessageCount: 0, lastMessageSentAt: nil, product: nil,
                                      interlocutor: nil, amISelling: amISelling)
        self.init(conversation: empty, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository, tracker: tracker)
        self.syncConversation(productId, sellerId: sellerId)
    }
    
    init?(conversation: ChatConversation, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
          productRepository: ProductRepository, userRepository: UserRepository, tracker: Tracker) {
        self.conversation = Variable<ChatConversation>(conversation)
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.tracker = tracker
        
        super.init()
        setupRx()
    }
    
    override func didBecomeActive(firstTime: Bool) {
        retrieveMoreMessages()
    }
    
    func didAppear() {
        // TODO: Should we ask for push permission?
        //            if fromMakeOffer &&
        //                PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat){
        //                    fromMakeOffer = false
        //                    delegate?.vmShowPrePermissions()
        //            }
    }
    
    func syncConversation(productId: String, sellerId: String) {
        chatRepository.showConversation(sellerId, productId: productId) { [weak self] result in
            if let value = result.value {
                self?.conversation.value = value
                self?.retrieveMoreMessages()
            } else if let _ = result.error {
                // Handle error
            }
        }
    }
    
    func setupRx() {
        conversation.asObservable().subscribeNext { [weak self] conversation in
            self?.chatStatus.value = conversation.chatStatus
            self?.chatEnabled.value = conversation.chatEnabled
            self?.interlocutorIsMuted.value = conversation.interlocutor?.isMuted ?? false
            self?.interlocutorHasMutedYou.value = conversation.interlocutor?.hasMutedYou ?? false
            self?.title.value = conversation.product?.name ?? ""
            self?.productName.value = conversation.product?.name ?? ""
            self?.productImageUrl.value = conversation.product?.image?.fileURL
            self?.productPrice.value = conversation.product?.priceString() ?? ""
            self?.interlocutorAvatarURL.value = conversation.interlocutor?.avatar?.fileURL
            self?.interlocutorName.value = conversation.interlocutor?.name ?? ""
            self?.interlocutorId.value = conversation.interlocutor?.objectId
        }.addDisposableTo(disposeBag)
        
        guard let convId = conversation.value.objectId else { return }
        chatRepository.chatEventsIn(convId).subscribeNext { [weak self] event in
            switch event.type {
            case let .InterlocutorMessageSent(messageId, sentAt, text):
                self?.handleNewMessageFromInterlocutor(messageId, sentAt: sentAt, text: text)
            case let .InterlocutorReadConfirmed(messagesIds):
                self?.markMessagesAsRead(messagesIds)
            case let .InterlocutorReceptionConfirmed(messagesIds):
                self?.markMessagesAsReceived(messagesIds)
            case .InterlocutorTypingStarted:
                self?.interlocutorTyping.value = true
            case .InterlocutorTypingStopped:
                self?.interlocutorTyping.value = false
            }
        }.addDisposableTo(disposeBag)
    }

    
    // MARK: - Public Methods
    
    func productInfoPressed() {
        guard let product = conversation.value.product else { return }
        switch product.status {
        case .Deleted:
            delegate?.vmShowProductRemovedError()
        case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
            guard let productVC = ProductDetailFactory.productDetailFromChatProduct(product, thumbnailImage: nil)
                else { return }
            delegate?.vmShowProduct(productVC)
        }
    }
    
    func userInfoPressed() {
        // TODO: Create a UserVC Factory that allows to create a UserVC with a ChatInterlocutor
    }
    
    func safetyTipsBtnPressed() {
        updateChatSafetyTipsLastPageSeen(0)
        delegate?.vmShowSafetyTips()
    }
    
    func updateChatSafetyTipsLastPageSeen(page: Int) {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        let maxPageSeen = max(idxLastPageSeen, page)
        UserDefaultsManager.sharedInstance.saveChatSafetyTipsLastPageSeen(maxPageSeen)
    }
    
    func messageAtIndex(index: Int) -> ChatMessage? {
        guard 0..<messages.value.count ~= index else { return nil }
        return messages.value[index]
    }
    
    func textOfMessageAtIndex(index: Int) -> String? {
        return messageAtIndex(index)?.text
    }
}


// MARK: - Private methods

extension ChatViewModel {
    
    func setupDeepLinksRx() {
        DeepLinksRouter.sharedInstance.chatDeepLinks.subscribeNext { [weak self] deepLink in
            switch deepLink {
            case .Conversation(let data):
                guard self?.isMatchingConversationData(data) ?? false else { return }
                self?.retrieveMoreMessages()
//                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
            case .Message(_, let data):
                guard self?.isMatchingConversationData(data) ?? false else { return }
                self?.retrieveMoreMessages()
//                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
            default: break
            }
            }.addDisposableTo(disposeBag)
    }
    
    func isMatchingConversationData(data: ConversationData) -> Bool {
        switch data {
        case .Conversation(let conversationId):
            return conversationId == conversation.value.objectId
        case let .ProductBuyer(productId, buyerId):
            let myUserId = myUserRepository.myUser?.objectId
            let interlocutorId = conversation.value.interlocutor?.objectId
            let currentBuyer = conversation.value.amISelling ? myUserId : interlocutorId
            return productId == conversation.value.product?.objectId && buyerId == currentBuyer
        }
    }
}


// MARK: - Message operations

extension ChatViewModel {
    
    func sendMessage(text: String, isQuickAnswer: Bool) {
//        if isSendingMessage { return }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let convId = conversation.value.objectId else { return }
        guard let userId = myUserRepository.myUser?.objectId else { return }
//        isSendingMessage = true
        
        let newMessage = chatRepository.createNewMessage(userId, text: text)
        messages.insert(newMessage, atIndex: 0)
        chatRepository.sendMessage(convId, messageId: newMessage.objectId!, type: newMessage.type, text: text) {
            [weak self] result in
            if let _ = result.value {
                guard let id = newMessage.objectId else { return }
                let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
                self?.markMessageAsSent(id)

                // TODO: Should we track askQuestion?
                // TODO: Track Message Sent
                self?.afterSendMessageEvents()
                
            } else if let _ = result.error {
                // TODO: Handle error sending message
            }
        }
    }
    
    private func afterSendMessageEvents() {
        if shouldAskForRating {
            alreadyAskedForRating = true
            delegate?.vmAskForRating()
        } else if shouldAskProductSold {
            shouldAskProductSold = false
            delegate?.vmShowQuestion(title: LGLocalizedString.directAnswerSoldQuestionTitle,
                                     message: LGLocalizedString.directAnswerSoldQuestionMessage,
                                     positiveText: LGLocalizedString.directAnswerSoldQuestionOk,
                                     positiveAction: { [weak self] in
                                        self?.markProductAsSold()
                },
                                     positiveActionStyle: nil,
                                     negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
        } else if PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat) {
            delegate?.vmShowPrePermissions()
        }
    }
    
    private func markMessageAsSent(messageId: String) {
        updateMessageWithAction(messageId) { $0.markAsSent() }
    }
    
    private func markMessagesAsReceived(messagesIds: [String]) {
        messagesIds.forEach { [weak self] messageId in
            self?.updateMessageWithAction(messageId) { $0.markAsReceived() }
        }
    }
    
    private func markMessagesAsRead(messagesIds: [String]) {
        messagesIds.forEach { [weak self] messageId in
            self?.updateMessageWithAction(messageId) { $0.markAsRead() }
        }
    }
    
    private func updateMessageWithAction(messageId: String, action: ChatMessage -> ChatMessage) {
        guard let index = messages.value.indexOf({$0.objectId == messageId}) else { return }
        let message = messages.value[index]
        let newMessage = action(message)
        let range = index..<(index+1)
        messages.replace(range, with: [newMessage])
    }
    
    private func handleNewMessageFromInterlocutor(messageId: String, sentAt: NSDate, text: String) {
        guard let convId = conversation.value.objectId else { return }
        guard let interlocutorId = conversation.value.interlocutor?.objectId else { return }
        let message = chatRepository.createNewMessage(interlocutorId, text: text).markAsReceived().markAsRead()
        messages.insert(message, atIndex: 0)
        chatRepository.confirmReception(convId, messageIds: [messageId], completion: nil)
        chatRepository.confirmRead(convId, messageIds: [messageId], completion: nil)
    }
}


// MARK: - Product Operations

extension ChatViewModel {
    private func markProductAsSold() {
        // TODO: Add a way to mark a product as sold pasing only the productId to the productRepository
    }
}


// MARK: - Options Menu

extension ChatViewModel {
    
    func openOptionsMenu() {
        var texts: [String] = []
        var actions: [()->Void] = []
        //Direct answers
        if chatEnabled.value {
            texts.append(shouldShowDirectAnswers ? LGLocalizedString.directAnswersHide :
                LGLocalizedString.directAnswersShow)
            actions.append({ [weak self] in self?.toggleDirectAnswers() })
        }
        //Delete
        if !isDeleted {
            texts.append(LGLocalizedString.chatListDelete)
            actions.append({ [weak self] in self?.deleteAction() })
        }
        //Report
        texts.append(LGLocalizedString.reportUserTitle)
        actions.append({ [weak self] in self?.reportUserAction() })
        
        
        if interlocutorIsMuted.value {
            texts.append(LGLocalizedString.chatUnblockUser)
            actions.append({ [weak self] in self?.unblockUserAction() })
        } else {
            texts.append(LGLocalizedString.chatBlockUser)
            actions.append({ [weak self] in self?.blockUserAction() })
        }
        
        delegate?.vmShowOptionsList(texts, actions: actions)
    }

    private func toggleDirectAnswers() {
        showDirectAnswers(!shouldShowDirectAnswers)
    }
    
    private func deleteAction() {
        guard !isDeleted else { return }
        
        delegate?.vmShowQuestion(title: LGLocalizedString.chatListDeleteAlertTitleOne,
                                 message: LGLocalizedString.chatListDeleteAlertTextOne,
                                 positiveText: LGLocalizedString.chatListDeleteAlertSend,
                                 positiveAction: { [weak self] in
                                    self?.delete() { [weak self] success in
                                        if success {
                                            self?.isDeleted = true
                                        }
                                        let message = success ? LGLocalizedString.chatListDeleteOkOne : LGLocalizedString.chatListDeleteErrorOne
                                        self?.delegate?.vmShowMessage(message) { [weak self] in
                                            self?.delegate?.vmClose()
                                        }
                                    }
            },
                                 positiveActionStyle: .Destructive,
                                 negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
    }
    
    private func delete(completion: (success: Bool) -> ()) {
        guard let chatId = conversation.value.objectId else {
            completion(success: false)
            return
        }
        self.chatRepository.archiveConversations([chatId]) { result in
            completion(success: result.value != nil)
        }
    }
    
    private func reportUserAction() {
        guard let _ = conversation.value.interlocutor else { return }
        // TODO: Modify ReportUsersViewModel to work with only the UserID (no need for a User model)
        //        let reportVM = ReportUsersViewModel(origin: .Chat, userReported: otherUser)
        //        delegate?.vmShowReportUser(reportVM)
    }
    
    private func blockUserAction() {
        
        delegate?.vmShowQuestion(title: LGLocalizedString.chatBlockUserAlertTitle,
                                 message: LGLocalizedString.chatBlockUserAlertText,
                                 positiveText: LGLocalizedString.chatBlockUserAlertBlockButton,
                                 positiveAction: { [weak self] in
                                    self?.blockUser() { [weak self] success in
                                        if success {
                                            self?.interlocutorIsMuted.value = true
                                        } else {
                                            self?.delegate?.vmShowMessage(LGLocalizedString.blockUserErrorGeneric, completion: nil)
                                        }
                                    }
            },
                                 positiveActionStyle: .Destructive,
                                 negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
    }
    
    private func blockUser(completion: (success: Bool) -> ()) {
        
        guard let userId = conversation.value.interlocutor?.objectId else {
            completion(success: false)
            return
        }
        
        trackBlockUsers([userId])
        
        self.userRepository.blockUserWithId(userId) { result -> Void in
            completion(success: result.value != nil)
        }
    }
    
    private func unblockUserAction() {
        unBlockUser() { [weak self] success in
            if success {
                self?.interlocutorIsMuted.value = false
            } else {
                self?.delegate?.vmShowMessage(LGLocalizedString.unblockUserErrorGeneric, completion: nil)
            }
        }
    }
    
    private func unBlockUser(completion: (success: Bool) -> ()) {
        guard let userId = conversation.value.interlocutor?.objectId else {
            completion(success: false)
            return
        }
        
        trackUnblockUsers([userId])
        
        self.userRepository.unblockUserWithId(userId) { result -> Void in
            completion(success: result.value != nil)
        }
    }
}


// MARK: - Paginable

extension ChatViewModel {
    
    func setCurrentIndex(index: Int) {
        let threshold = Int(Float(objectCount) * 0.7)
        let shouldRetrieveNextPage = index >= threshold
        if shouldRetrieveNextPage && !isLastPage && !isLoading {
            retrieveMoreMessages()
        }
    }
    
    func retrieveMoreMessages() {
        guard let convId = conversation.value.objectId else { return }
        guard !isLoading && !isLastPage else { return }
        isLoading = true
        if messages.value.count == 0 {
            downloadFirstPage(convId)
        } else if let lastId = messages.value.last?.objectId {
            downloadMoreMessages(convId, fromMessageId: lastId)
        }
    }

    private func downloadFirstPage(conversationId: String) {
        chatRepository.indexMessages(conversationId, numResults: resultsPerPage, offset: 0) {
            [weak self] result in
            self?.isLoading = false
            if let value = result.value {
                self?.messages.removeAll()
                self?.messages.appendContentsOf(value)
                self?.afterRetrieveChatMessagesEvents()
                self?.isLastPage = value.count == 0
            } else if let _ = result.error {
                //TODO: Handle Error
            }
        }
    }
    
    private func downloadMoreMessages(convId: String, fromMessageId: String) {
        chatRepository.indexMessagesOlderThan(fromMessageId, conversationId: convId, numResults: resultsPerPage) {
            [weak self] result in
            self?.isLoading = false
            if let value = result.value {
                if value.count == 0 {
                    self?.isLastPage = true
                } else {
                    self?.messages.appendContentsOf(value)
                }
            } else if let _ = result.error {
                //TODO: Handle Error
            }
        }
    }
    
    private func afterRetrieveChatMessagesEvents() {
        if shouldShowSafetyTips {
            safetyTipsBtnPressed()
        }
    }
}


// MARK: - Tracking

private extension ChatViewModel {

    // TODO: Tracking!
    
//    private func trackQuestion(source: AskQuestionSource) {
//        // only track ask question if there were no previous messages
//        guard objectCount == 0 else { return }
//        let typePageParam: EventParameterTypePage
//        switch source {
//        case .ProductDetail:
//            typePageParam = .ProductDetail
//        case .ProductList:
//            typePageParam = .ProductList
//        }
//        guard let product = conversation.value.product else { return }
//        let askQuestionEvent = TrackerEvent.productAskQuestion(product, typePage: typePageParam, directChat: .False,
//                                                               longPress: .False)
//        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
//    }
//    
//    private func trackMessageSent(isQuickAnswer: Bool) {
//        guard let product = conversation.value.product else { return }
//        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: otherUser,
//                                                            isQuickAnswer: isQuickAnswer ? .True : .False, directChat: .False, longPress: .False)
//        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
//    }
//    
    private func trackBlockUsers(userIds: [String]) {
        let blockUserEvent = TrackerEvent.profileBlock(.Chat, blockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(blockUserEvent)
    }
    
    private func trackUnblockUsers(userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.Chat, unblockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(unblockUserEvent)
    }
}


// MARK: - Private ChatConversation Extension

private extension ChatConversation {
    var chatStatus: ChatInfoViewStatus {
        guard let interlocutor = interlocutor else { return .Forbidden }
        guard let product = product else { return .Forbidden }
        if interlocutor.isBlocked { return .Forbidden }
        if interlocutor.isMuted { return .Blocked }
        if interlocutor.hasMutedYou { return .BlockedBy }
        switch product.status {
        case .Deleted, .Discarded:
            return .ProductDeleted
        case .Sold, .SoldOld:
            return .ProductSold
        case .Approved, .Pending:
            return .Available
        }
    }
    
    var chatEnabled: Bool {
        switch chatStatus {
        case .Forbidden, .Blocked, .BlockedBy:
            return false
        case .Available, .ProductSold, .ProductDeleted:
            return true
        }
    }
}


//// MARK: - DirectAnswers

extension ChatViewModel: DirectAnswersPresenterDelegate {
    
    var directAnswers: [DirectAnswer] {
        let emptyAction: ()->Void = { [weak self] in
            self?.clearProductSoldDirectAnswer()
        }
        if conversation.value.amISelling {
            return [DirectAnswer(text: LGLocalizedString.directAnswerInterested, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerIsNegotiable, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerLikeToBuy, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction)]
        } else {
            return [DirectAnswer(text: LGLocalizedString.directAnswerStillForSale, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerWhatsOffer, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerNegotiableYes, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerNegotiableNo, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction),
                    DirectAnswer(text: LGLocalizedString.directAnswerProductSold, action: { [weak self] in
                        self?.onProductSoldDirectAnswer()
                    })]
        }
    }
    
    func directAnswersDidTapAnswer(controller: DirectAnswersPresenter, answer: DirectAnswer) {
        if let actionBlock = answer.action {
            actionBlock()
        }
        sendMessage(answer.text, isQuickAnswer: true)
    }
    
    func directAnswersDidTapClose(controller: DirectAnswersPresenter) {
        showDirectAnswers(false)
    }
    
    private func showDirectAnswers(show: Bool) {
        UserDefaultsManager.sharedInstance.saveShouldShowDirectAnswers(show, subKey: userDefaultsSubKey)
        delegate?.vmDidUpdateDirectAnswers()
    }
    
    private func clearProductSoldDirectAnswer() {
        shouldAskProductSold = false
    }
    
    private func onProductSoldDirectAnswer() {
        if chatStatus.value != .ProductSold {
            shouldAskProductSold = true
        }
    }
}
