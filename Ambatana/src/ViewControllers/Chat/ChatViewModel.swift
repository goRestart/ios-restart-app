//
//  ChatViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 27/4/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol ChatViewModelDelegate: BaseViewModelDelegate {
    
}

class ChatViewModel: BaseViewModel, Paginable {
    
    
    // MARK: - Properties
    
    // Protocols
    weak var delegate: ChatViewModelDelegate?
    
    // Paginable
    var resultsPerPage: Int = Constants.numMessagesPerPage
    var nextPage: Int = 0
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int { return messages.count }

    // Public Model info
    var title: String? { return conversation.value.product?.name }
    var productName: String? { return conversation.value.product?.name }
    var productImageUrl: NSURL? { return conversation.value.product?.image?.fileURL }
    var productPrice: String? { return conversation.value.product?.priceString() }
    var interlocutorAvatarURL: NSURL? { return conversation.value.interlocutor?.avatar?.fileURL }
    var interlocutorName: String? { return conversation.value.interlocutor?.name }
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
        return false // TODO: implement
//        guard let otherUserId = otherUser?.objectId else { return false }
//        return chat.didReceiveMessageFrom(otherUserId)
    }
        
    // Rx Variables
    var shouldShowDirectAnswers = Variable<Bool>(false)

    var interlocutorIsMuted = Variable<Bool>(false)
    var interlocutorHasMutedYou = Variable<Bool>(false)
    
    var chatStatus = Variable<ChatInfoViewStatus>(.Available)
    var chatEnabled = Variable<Bool>(false)
    
    private var conversation: Variable<ChatConversation>
    
    // Private
    private var messages: [ChatMessage] = []
    
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

    init?(conversation: ChatConversation, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
          productRepository: ProductRepository, userRepository: UserRepository, tracker: Tracker) {
        self.conversation = Variable<ChatConversation>(conversation)
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.tracker = tracker
        
        super.init()
    }
    
    func setupRx() {
        conversation.asObservable().subscribeNext { [weak self] conversation in
            self?.chatStatus.value = conversation.chatStatus
            self?.chatEnabled.value = conversation.chatEnabled
            self?.interlocutorIsMuted.value = conversation.interlocutor?.isMuted ?? false
            self?.interlocutorHasMutedYou.value = conversation.interlocutor?.hasMutedYou ?? false
            }.addDisposableTo(disposeBag)
    }
}


// MARK: > Paginable

extension ChatViewModel {
    func retrievePage(page: Int) {
        let lastMessageId = messages.last?.objectId
        if page == 0 || lastMessageId == nil {
            downloadFirstPage()
        } else if let messageId = lastMessageId {
            downloadMessaagesOlderThean(messageId)
        }
    }
    
    private func downloadFirstPage() {
        chatRepository.indexMessages(conversation.value.objectId!, numResults: resultsPerPage, offset: 0) {
            [weak self] result in
            if let value = result.value {
                self?.messages = value
            } else if let _ = result.error {
                //TODO: Handle Error
            }
        }
    }
    
    private func downloadMessaagesOlderThean(messageId: String) {
        guard let convId = conversation.value.objectId else { return }
        chatRepository.indexMessagesOlderThan(messageId, conversationId: convId, numResults: resultsPerPage) {
            [weak self] result in
            if let value = result.value {
                self?.messages.appendContentsOf(value)
            } else if let _ = result.error {
                //TODO: Handle Error
            }
        }
    }
}


// MARK: > Tracking

private extension ChatViewModel {
    
    private func trackQuestion(source: AskQuestionSource) {
        // only track ask question if there were no previous messages
        guard objectCount == 0 else { return }
        let typePageParam: EventParameterTypePage
        switch source {
        case .ProductDetail:
            typePageParam = .ProductDetail
        case .ProductList:
            typePageParam = .ProductList
        }
        guard let product = conversation.value.product else { return }
        let askQuestionEvent = TrackerEvent.productAskQuestion(product, typePage: typePageParam, directChat: .False,
                                                               longPress: .False)
        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
    }
    
    private func trackMessageSent(isQuickAnswer: Bool) {
        guard let product = conversation.value.product else { return }
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: otherUser,
                                                            isQuickAnswer: isQuickAnswer ? .True : .False, directChat: .False, longPress: .False)
        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
    }
    
    private func trackBlockUsers(userIds: [String]) {
        let blockUserEvent = TrackerEvent.profileBlock(.Chat, blockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(blockUserEvent)
    }
    
    private func trackUnblockUsers(userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.Chat, unblockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(unblockUserEvent)
    }
}

// MARK: > Private ChatConversation Extension

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


//    override func didBecomeActive() {
//        retrieveFirstPage()
//    }
//
//    func didAppear() {
//        if fromMakeOffer &&
//            PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat){
//                fromMakeOffer = false
//                delegate?.vmShowPrePermissions()
//        } else if !chatEnabled {
//            delegate?.vmHideKeyboard()
//        } else {
//            delegate?.vmShowKeyboard()
//        }
//    }
//
//
//    // MARK: - Public
//
//    func productInfoPressed() {
//        switch product.status {
//        case .Deleted:
//            delegate?.vmShowProductRemovedError()
//        case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
//            guard let productVC = ProductDetailFactory.productDetailFromProduct(product) else { return }
//            delegate?.vmShowProduct(productVC)
//        }
//    }
//
//    func userInfoPressed() {
//        guard let user = otherUser else { return }
//        let userVM = UserViewModel(user: user, source: .Chat)
//        delegate?.vmShowUser(userVM)
//    }
//
//    func safetyTipsBtnPressed() {
//        updateChatSafetyTipsLastPageSeen(0)
//        delegate?.vmShowSafetyTips()
//    }
//
//    func updateChatSafetyTipsLastPageSeen(page: Int) {
//        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
//        let maxPageSeen = max(idxLastPageSeen, page)
//        UserDefaultsManager.sharedInstance.saveChatSafetyTipsLastPageSeen(maxPageSeen)
//    }
//
//    func optionsBtnPressed() {
//        var texts: [String] = []
//        var actions: [()->Void] = []
//        //Direct answers
//        if chatEnabled {
//            texts.append(shouldShowDirectAnswers ? LGLocalizedString.directAnswersHide :
//                LGLocalizedString.directAnswersShow)
//            actions.append({ [weak self] in self?.toggleDirectAnswers() })
//        }
//        //Delete
//        if chat.isSaved && !isDeleted {
//            texts.append(LGLocalizedString.chatListDelete)
//            actions.append({ [weak self] in self?.delete() })
//        }
//        //Report
//        texts.append(LGLocalizedString.reportUserTitle)
//        actions.append({ [weak self] in self?.reportUserPressed() })
//
//        if let relation = userRelation where relation.isBlocked {
//            texts.append(LGLocalizedString.chatUnblockUser)
//            actions.append({ [weak self] in self?.unblockUserPressed() })
//        } else {
//            texts.append(LGLocalizedString.chatBlockUser)
//            actions.append({ [weak self] in self?.blockUserPressed() })
//        }
//
//        delegate?.vmShowOptionsList(texts, actions: actions)
//    }
//
//    func messageAtIndex(index: Int) -> Message {
//        return loadedMessages[index]
//    }
//
//    func textOfMessageAtIndex(index: Int) -> String {
//        return loadedMessages[index].text
//    }
//
//    func sendMessage(text: String, isQuickAnswer: Bool) {
//        if isSendingMessage { return }
//        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
//        guard message.characters.count > 0 else { return }
//        guard let toUser = otherUser else { return }
//        self.isSendingMessage = true
//
//        chatRepository.sendText(message, product: product, recipient: toUser) {
//            [weak self] result in
//            guard let strongSelf = self else { return }
//            if let sentMessage = result.value {
//                if let askQuestion = strongSelf.askQuestion {
//                    strongSelf.askQuestion = nil
//                    strongSelf.trackQuestion(askQuestion)
//                }
//                strongSelf.loadedMessages.insert(sentMessage, atIndex: 0)
//                strongSelf.delegate?.vmDidSucceedSendingMessage()
//                strongSelf.trackMessageSent(isQuickAnswer)
//                strongSelf.afterSendMessageEvents()
//            } else if let _ = result.error {
//                strongSelf.delegate?.vmDidFailSendingMessage()
//            }
//            strongSelf.isSendingMessage = false
//        }
//    }
//
//    private func afterSendMessageEvents() {
//        if shouldAskForRating {
//            alreadyAskedForRating = true
//            delegate?.vmAskForRating()
//        } else if shouldAskProductSold {
//            shouldAskProductSold = false
//            delegate?.vmShowQuestion(title: LGLocalizedString.directAnswerSoldQuestionTitle,
//                message: LGLocalizedString.directAnswerSoldQuestionMessage,
//                positiveText: LGLocalizedString.directAnswerSoldQuestionOk,
//                positiveAction: { [weak self] in
//                    self?.markProductAsSold()
//                },
//                positiveActionStyle: nil,
//                negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
//        } else if PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat) {
//            delegate?.vmShowPrePermissions()
//        }
//    }
//
//    func isMatchingConversationData(data: ConversationData) -> Bool {
//        switch data {
//        case .Conversation(let conversationId):
//            return conversationId == chat.objectId
//        case let .ProductBuyer(productId, buyerId):
//            return productId == product.objectId && buyerId == buyer?.objectId
//        }
//    }
//
//    func retrieveUsersRelation() {
//
//        guard let otherUserId = otherUser?.objectId else { return }
//
//        userRepository.retrieveUserToUserRelation(otherUserId) { [weak self] result in
//            if let value = result.value {
//                self?.userRelation = value
//            } else {
//                self?.userRelation = nil
//            }
//        }
//    }
//
//
//    // MARK: - private methods
//
//    private func initUsers() {
//        guard let myUser = myUserRepository.myUser else { return }
//        self.otherUser = chat.otherUser(myUser: myUser)
//        self.buyer = chat.buyer
//    }
//
//    private func setupDeepLinksRx() {
//        DeepLinksRouter.sharedInstance.chatDeepLinks.subscribeNext { [weak self] deepLink in
//            switch deepLink {
//            case .Conversation(let data):
//                guard self?.isMatchingConversationData(data) ?? false else { return }
//                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
//            case .Message(_, let data):
//                guard self?.isMatchingConversationData(data) ?? false else { return }
//                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
//            default: break
//            }
//        }.addDisposableTo(disposeBag)
//    }


//
//    private func onProductSoldDirectAnswer() {
//        if chatStatus != .ProductSold {
//            shouldAskProductSold = true
//        }
//    }
//
//    private func clearProductSoldDirectAnswer() {
//        shouldAskProductSold = false
//    }
//
//    private func blockUserPressed() {
//
//        delegate?.vmShowQuestion(title: LGLocalizedString.chatBlockUserAlertTitle,
//            message: LGLocalizedString.chatBlockUserAlertText,
//            positiveText: LGLocalizedString.chatBlockUserAlertBlockButton,
//            positiveAction: { [weak self] in
//                self?.blockUser() { [weak self] success in
//                    if success {
//                        self?.userRelation?.isBlocked = true
//                    } else {
//                        self?.delegate?.vmShowMessage(LGLocalizedString.blockUserErrorGeneric, completion: nil)
//                    }
//                }
//            },
//            positiveActionStyle: .Destructive,
//            negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
//    }
//
//    private func blockUser(completion: (success: Bool) -> ()) {
//
//        guard let user = otherUser, let userId = user.objectId else {
//            completion(success: false)
//            return
//        }
//
//        trackBlockUsers([userId])
//
//        self.userRepository.blockUserWithId(userId) { result -> Void in
//            completion(success: result.value != nil)
//        }
//    }
//
//    private func unblockUserPressed() {
//        unBlockUser() { [weak self] success in
//            if success {
//                self?.userRelation?.isBlocked = false
//            } else {
//                self?.delegate?.vmShowMessage(LGLocalizedString.unblockUserErrorGeneric, completion: nil)
//            }
//        }
//    }
//
//    private func unBlockUser(completion: (success: Bool) -> ()) {
//        guard let user = otherUser, let userId = user.objectId else {
//            completion(success: false)
//            return
//        }
//
//        trackUnblockUsers([userId])
//
//        self.userRepository.unblockUserWithId(userId) { result -> Void in
//            completion(success: result.value != nil)
//        }
//    }
//
//    private func toggleDirectAnswers() {
//        showDirectAnswers(!shouldShowDirectAnswers)
//    }
//
//    private func delete() {
//        guard !isDeleted else { return }
//
//        delegate?.vmShowQuestion(title: LGLocalizedString.chatListDeleteAlertTitleOne,
//            message: LGLocalizedString.chatListDeleteAlertTextOne,
//            positiveText: LGLocalizedString.chatListDeleteAlertSend,
//            positiveAction: { [weak self] in
//                self?.delete() { [weak self] success in
//                    if success {
//                        self?.isDeleted = true
//                    }
//                    let message = success ? LGLocalizedString.chatListDeleteOkOne : LGLocalizedString.chatListDeleteErrorOne
//                    self?.delegate?.vmShowMessage(message) { [weak self] in
//                        self?.delegate?.vmClose()
//                    }
//                }
//            },
//            positiveActionStyle: .Destructive,
//            negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
//    }
//
//    private func delete(completion: (success: Bool) -> ()) {
//        guard let chatId = chat.objectId else {
//            completion(success: false)
//            return
//        }
//        self.chatRepository.archiveChatsWithIds([chatId]) { result in
//            completion(success: result.value != nil)
//        }
//    }
//
//    private func reportUserPressed() {
//        guard let otherUser = otherUser else { return }
//        let reportVM = ReportUsersViewModel(origin: .Chat, userReported: otherUser)
//        delegate?.vmShowReportUser(reportVM)
//    }
//
//    private func markProductAsSold() {
//        productRepository.markProductAsSold(product) { [weak self] result in
//            guard let strongSelf = self else { return }
//            if let value = result.value {
//                strongSelf.product = value
//                strongSelf.delegate?.vmDidUpdateProduct(messageToShow: LGLocalizedString.productMarkAsSoldSuccessMessage)
//                strongSelf.delegate?.vmUpdateRelationInfoView(strongSelf.chatStatus)
//            } else {
//                strongSelf.delegate?.vmShowMessage(LGLocalizedString.productMarkAsSoldErrorGeneric, completion: nil)
//            }
//        }
//    }
//
//
//    // MARK: Tracking
//
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
//        let askQuestionEvent = TrackerEvent.productAskQuestion(product, typePage: typePageParam, directChat: .False,
//                                                               longPress: .False)
//        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
//    }
//
//    private func trackMessageSent(isQuickAnswer: Bool) {
//        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: otherUser,
//            isQuickAnswer: isQuickAnswer ? .True : .False, directChat: .False, longPress: .False)
//        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
//    }
//
//    private func trackBlockUsers(userIds: [String]) {
//        let blockUserEvent = TrackerEvent.profileBlock(.Chat, blockedUsersIds: userIds)
//        TrackerProxy.sharedInstance.trackEvent(blockUserEvent)
//    }
//
//    private func trackUnblockUsers(userIds: [String]) {
//        let unblockUserEvent = TrackerEvent.profileUnblock(.Chat, unblockedUsersIds: userIds)
//        TrackerProxy.sharedInstance.trackEvent(unblockUserEvent)
//    }
//
//    // MARK: - Paginable
//
//    func retrievePage(page: Int) {
//
//        guard let userBuyer = buyer else { return }
//
//        delegate?.vmDidStartRetrievingChatMessages(hasData: !loadedMessages.isEmpty)
//        isLoading = true
//        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, page: page,
//            numResults: resultsPerPage) { [weak self] result in
//                guard let strongSelf = self else { return }
//                if let chat = result.value {
//                    if page == 0 {
//                        strongSelf.loadedMessages = chat.messages
//                    } else {
//                        strongSelf.loadedMessages += chat.messages
//                    }
//                    strongSelf.isLastPage = chat.messages.count < strongSelf.resultsPerPage
//                    strongSelf.chat = chat
//                    strongSelf.nextPage = page + 1
//                    strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
//                    strongSelf.afterRetrieveChatMessagesEvents()
//                } else if let error = result.error {
//                    switch (error) {
//                    case .NotFound:
//                        //New chat!! this is success
//                        strongSelf.isLastPage = true
//                        strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
//                        strongSelf.afterRetrieveChatMessagesEvents()
//                    case .Network, .Unauthorized, .Internal:
//                        strongSelf.delegate?.vmDidFailRetrievingChatMessages()
//                    }
//                }
//                strongSelf.isLoading = false
//        }
//    }
//
//    private func afterRetrieveChatMessagesEvents() {
//        if shouldShowSafetyTips {
//            safetyTipsBtnPressed()
//        }
//    }
//}
//
//
//// MARK: - DirectAnswers
//
//extension OldChatViewModel: DirectAnswersPresenterDelegate {
//
//    var directAnswers: [DirectAnswer] {
//        let emptyAction: ()->Void = { [weak self] in
//            self?.clearProductSoldDirectAnswer()
//        }
//        if isBuyer {
//            return [DirectAnswer(text: LGLocalizedString.directAnswerInterested, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerIsNegotiable, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerLikeToBuy, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction)]
//        } else {
//            return [DirectAnswer(text: LGLocalizedString.directAnswerStillForSale, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerWhatsOffer, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerNegotiableYes, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerNegotiableNo, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction),
//                DirectAnswer(text: LGLocalizedString.directAnswerProductSold, action: { [weak self] in
//                    self?.onProductSoldDirectAnswer()
//                    })]
//        }
//    }
//
//    func directAnswersDidTapAnswer(controller: DirectAnswersPresenter, answer: DirectAnswer) {
//        if let actionBlock = answer.action {
//            actionBlock()
//        }
//        sendMessage(answer.text, isQuickAnswer: true)
//    }
//
//    func directAnswersDidTapClose(controller: DirectAnswersPresenter) {
//        showDirectAnswers(false)
//    }
//
//    private func showDirectAnswers(show: Bool) {
//        UserDefaultsManager.sharedInstance.saveShouldShowDirectAnswers(show, subKey: userDefaultsSubKey)
//        delegate?.vmDidUpdateDirectAnswers()
//    }
//}
