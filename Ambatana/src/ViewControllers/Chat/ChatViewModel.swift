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

    func vmDidStartRetrievingChatMessages(hasData hasData: Bool)
    func vmDidFailRetrievingChatMessages()
    func vmDidSucceedRetrievingChatMessages()
    func vmUpdateAfterReceivingMessagesAtPositions(positions: [Int])

    func vmDidFailSendingMessage()
    func vmDidSucceedSendingMessage()

    func vmDidUpdateDirectAnswers()
    func vmDidUpdateProduct(messageToShow message: String?)

    func vmShowProduct(productVieWmodel: ProductViewModel)
    func vmShowProductRemovedError()
    func vmShowProductSoldError()
    func vmShowUserProfile(user: User, source: EditProfileSource)

    func vmShowReportUser(reportUserViewModel: ReportUsersViewModel)

    func vmShowSafetyTips()
    func vmAskForRating()
    func vmShowPrePermissions()
    func vmShowKeyboard()
    func vmHideKeyboard()
    func vmShowMessage(message: String, completion: (() -> ())?)
    func vmShowOptionsList(options: [String], actions: [()->Void])
    func vmShowQuestion(title title: String, message: String, positiveText: String, positiveAction: (()->Void)?,
        positiveActionStyle: UIAlertActionStyle?, negativeText: String, negativeAction: (()->Void)?,
        negativeActionStyle: UIAlertActionStyle?)
    func vmClose()

    func vmUpdateRelationInfoView(status: ChatInfoViewStatus)
    func vmUpdateChatInteraction(enabled: Bool)
}

enum AskQuestionSource {
    case ProductList
    case ProductDetail
}

public class ChatViewModel: BaseViewModel, Paginable {


    // MARK: > Public data

    var fromMakeOffer = false
    var askQuestion: AskQuestionSource?

    // MARK: > Controller data

    weak var delegate: ChatViewModelDelegate?
    var title: String? {
        return product.name
    }
    var productName: String? {
        return product.name
    }
    var productImageUrl: NSURL? {
        return product.thumbnail?.fileURL
    }
    var productUserName: String? {
        return product.user.name
    }
    var productPrice: String {
        return product.priceString()
    }
    var productStatus: ProductStatus {
        return product.status
    }
    var otherUserAvatarUrl: NSURL? {
        return otherUser?.avatar?.fileURL
    }
    var otherUserID: String? {
        return otherUser?.objectId
    }
    var otherUserName: String? {
        return otherUser?.name
    }
    var otherUser: User?

    var userRelation: UserUserRelation? {
        didSet {
            delegate?.vmUpdateRelationInfoView(chatStatus)
            if let relation = userRelation where relation.isBlocked || relation.isBlockedBy {
                delegate?.vmHideKeyboard()
                showDirectAnswers(false)
            } else {
                showDirectAnswers(shouldShowDirectAnswers)
            }
            delegate?.vmUpdateChatInteraction(chatEnabled)
        }
    }

    var shouldShowDirectAnswers: Bool {
        return chatEnabled && UserDefaultsManager.sharedInstance.loadShouldShowDirectAnswers(userDefaultsSubKey)
    }
    var keyForTextCaching: String {
        return userDefaultsSubKey
    }
    var safetyTipsCompleted: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen() ?? 0
        return idxLastPageSeen >= (ChatSafetyTipsView.tipsCount - 1)
    }

    var chatStatus: ChatInfoViewStatus {
        if chat.forbidden {
            return .Forbidden
        }

        if let relation = userRelation {
            if relation.isBlocked { return .Blocked }
            if relation.isBlockedBy { return .BlockedBy }
        }

        switch product.status {
        case .Deleted:
            return .ProductDeleted
        case .Sold, .SoldOld:
            return .ProductSold
        case .Approved, .Discarded, .Pending:
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

    // MARK: Paginable

    var resultsPerPage: Int = Constants.numMessagesPerPage
    var firstPage: Int = 0
    var nextPage: Int = 0
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return loadedMessages.count
    }


    // MARK: > Private data
    
    private let chatRepository: ChatRepository
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let tracker: Tracker

    private var chat: Chat
    private var product: Product
    private var isDeleted = false
    private var alreadyAskedForRating = false
    private var shouldAskProductSold: Bool = false
    private var userDefaultsSubKey: String {
        return "\(product.objectId) + \(chat.userTo.objectId)"
    }

    private var loadedMessages: [Message]
    private var buyer: User?
    private var isSendingMessage = false

    private var isBuyer: Bool {
        guard let buyerId = buyer?.objectId, myUserId = myUserRepository.myUser?.objectId else { return false }
        return buyerId == myUserId
    }
    private var shouldAskForRating: Bool {
        return !alreadyAskedForRating && !UserDefaultsManager.sharedInstance.loadAlreadyRated()
    }
    private var shouldShowSafetyTips: Bool {
        let idxLastPageSeen = UserDefaultsManager.sharedInstance.loadChatSafetyTipsLastPageSeen()
        return idxLastPageSeen == nil && didReceiveMessageFromOtherUser
    }
    private var didReceiveMessageFromOtherUser: Bool {
        guard let otherUserId = otherUser?.objectId else { return false }
        return chat.didReceiveMessageFrom(otherUserId)
    }


    // MARK: - Lifecycle

    convenience init?(chat: Chat) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(chat: chat, myUserRepository: myUserRepository, chatRepository: chatRepository,
            productRepository: productRepository, userRepository: userRepository, tracker: tracker)
    }

    convenience init?(product: Product) {
        guard let chatFromProduct = Core.chatRepository.newChatWithProduct(product) else { return nil }
        self.init(chat: chatFromProduct)
    }

    init?(chat: Chat, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
        productRepository: ProductRepository, userRepository: UserRepository, tracker: Tracker) {
            self.chat = chat
            self.myUserRepository = myUserRepository
            self.chatRepository = chatRepository
            self.productRepository = productRepository
            self.userRepository = userRepository
            self.tracker = tracker
            self.loadedMessages = []
            self.product = chat.product
            if let myUser = myUserRepository.myUser {
                self.isDeleted = chat.isArchived(myUser: myUser)
            }
            super.init()
            initUsers()
            if otherUser == nil { return nil }
            if buyer == nil { return nil }
    }

    override func didSetActive(active: Bool) {
        if active {
            retrieveFirstPage()
        }
    }

    func didAppear() {
        if fromMakeOffer &&
            PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat){
                fromMakeOffer = false
                delegate?.vmShowPrePermissions()
        } else if !chatEnabled {
            delegate?.vmHideKeyboard()
        } else {
            delegate?.vmShowKeyboard()
        }
    }


    // MARK: - Public

    func productInfoPressed() {
        switch product.status {
        case .Deleted:
            delegate?.vmShowProductRemovedError()
        case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
            delegate?.vmShowProduct(ProductViewModel(product: product, thumbnailImage: nil))
        }
    }

    func userInfoPressed() {
        guard let user = otherUser else { return }
        delegate?.vmShowUserProfile(user, source: .Chat)
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

    func optionsBtnPressed() {
        var texts: [String] = []
        var actions: [()->Void] = []
        //Direct answers
        if chatEnabled {
            texts.append(shouldShowDirectAnswers ? LGLocalizedString.directAnswersHide :
                LGLocalizedString.directAnswersShow)
            actions.append({ [weak self] in self?.toggleDirectAnswers() })
        }
        //Delete
        if chat.isSaved && !isDeleted {
            texts.append(LGLocalizedString.chatListDelete)
            actions.append({ [weak self] in self?.delete() })
        }
        //Report
        texts.append(LGLocalizedString.reportUserTitle)
        actions.append({ [weak self] in self?.reportUserPressed() })

        if let relation = userRelation where relation.isBlocked {
            texts.append(LGLocalizedString.chatUnblockUser)
            actions.append({ [weak self] in self?.unblockUserPressed() })
        } else {
            texts.append(LGLocalizedString.chatBlockUser)
            actions.append({ [weak self] in self?.blockUserPressed() })
        }

        delegate?.vmShowOptionsList(texts, actions: actions)
    }

    func messageAtIndex(index: Int) -> Message {
        return loadedMessages[index]
    }

    func textOfMessageAtIndex(index: Int) -> String {
        return loadedMessages[index].text
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
                strongSelf.delegate?.vmDidSucceedSendingMessage()

                if let askQuestion = strongSelf.askQuestion {
                    strongSelf.askQuestion = nil
                    strongSelf.trackQuestion(askQuestion)
                }
                strongSelf.trackMessageSent()
                strongSelf.afterSendMessageEvents()
            } else if let _ = result.error {
                strongSelf.delegate?.vmDidFailSendingMessage()
            }
            strongSelf.isSendingMessage = false
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

    func isMatchingDeepLink(deepLink: DeepLink) -> Bool {
        if deepLink.query["p"] == chat.product.objectId && deepLink.query["b"] == otherUser?.objectId {
            //Product + Buyer deep link
            return true
        }
        if deepLink.query["c"] == chat.objectId {
            //Conversation id deep link
            return true
        }
        return false
    }

    func didReceiveUserInteractionWithInfo(userInfo: [NSObject: AnyObject]) {
        guard isMatchingUserInfo(userInfo) else { return }

        retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
    }

    func retrieveUsersRelation() {

        guard let otherUserId = otherUser?.objectId else { return }

        userRepository.retrieveUserToUserRelation(otherUserId) { [weak self] result in
            if let value = result.value {
                self?.userRelation = value
            } else {
                self?.userRelation = nil
            }
        }
    }


    // MARK: - private methods

    private func initUsers() {
        guard let myUser = myUserRepository.myUser else { return }
        self.otherUser = chat.otherUser(myUser: myUser)
        self.buyer = chat.buyer
    }

    private func isMatchingUserInfo(userInfo: [NSObject: AnyObject]) -> Bool {
        guard let action = Action(userInfo: userInfo) else { return false }

        switch action {
        case let .Conversation(_, conversationId):
            return chat.objectId == conversationId
        case let .Message(_, productId, buyerId):
            return chat.product.objectId == productId && buyerId == buyer?.objectId
        case .URL:
            return false
        }
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
                    strongSelf.chat = chat
                    let insertedMessagesInfo = ChatViewModel.insertNewMessagesAt(strongSelf.loadedMessages,
                        newMessages: chat.messages)
                    strongSelf.loadedMessages = insertedMessagesInfo.messages
                    strongSelf.delegate?.vmUpdateAfterReceivingMessagesAtPositions(insertedMessagesInfo.indexes)
                    strongSelf.afterRetrieveChatMessagesEvents()
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
        if chatStatus != .ProductSold {
            shouldAskProductSold = true
        }
    }

    private func clearProductSoldDirectAnswer() {
        shouldAskProductSold = false
    }

    private func blockUserPressed() {
        delegate?.vmShowQuestion(title: LGLocalizedString.chatBlockUserAlertTitle,
            message: LGLocalizedString.chatBlockUserAlertText,
            positiveText: LGLocalizedString.chatBlockUserAlertBlockButton,
            positiveAction: { [weak self] in
                self?.blockUser() { [weak self] success in
                    if success {
                        self?.userRelation?.isBlocked = true
                    } else {
                        self?.delegate?.vmShowMessage(LGLocalizedString.blockUserErrorGeneric, completion: nil)
                    }
                }
            },
            positiveActionStyle: .Destructive,
            negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
    }

    private func blockUser(completion: (success: Bool) -> ()) {

        guard let user = otherUser, let userId = user.objectId else {
            completion(success: false)
            return
        }

        self.userRepository.blockUsersWithIds([userId]) { result -> Void in
            completion(success: result.value != nil)
        }
    }

    private func unblockUserPressed() {
        unBlockUser() { [weak self] success in
            if success {
                self?.userRelation?.isBlocked = false
            } else {
                self?.delegate?.vmShowMessage(LGLocalizedString.unblockUserErrorGeneric, completion: nil)
            }
        }
    }

    private func unBlockUser(completion: (success: Bool) -> ()) {
        guard let user = otherUser, let userId = user.objectId else {
            completion(success: false)
            return
        }

        self.userRepository.unblockUsersWithIds([userId]) { result -> Void in
            completion(success: result.value != nil)
        }
    }

    private func toggleDirectAnswers() {
        showDirectAnswers(!shouldShowDirectAnswers)
    }

    private func delete() {
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
        guard let chatId = chat.objectId else {
            completion(success: false)
            return
        }
        self.chatRepository.archiveChatsWithIds([chatId]) { result in
            completion(success: result.value != nil)
        }
    }

    private func reportUserPressed() {
        guard let otherUser = otherUser else { return }
        let reportVM = ReportUsersViewModel(origin: .Chat, userReported: otherUser)
        delegate?.vmShowReportUser(reportVM)
    }

    private func markProductAsSold() {
        productRepository.markProductAsSold(product) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.product = value
                strongSelf.delegate?.vmDidUpdateProduct(messageToShow: LGLocalizedString.productMarkAsSoldSuccessMessage)
                strongSelf.delegate?.vmUpdateRelationInfoView(strongSelf.chatStatus)
            } else {
                strongSelf.delegate?.vmShowMessage(LGLocalizedString.productMarkAsSoldErrorGeneric, completion: nil)
            }
        }
    }

    // MARK: Tracking

    private func trackQuestion(source: AskQuestionSource) {
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

    private func trackMessageSent() {
        let myUser = myUserRepository.myUser
        let messageSentEvent = TrackerEvent.userMessageSent(product, user: myUser)
        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
    }

    // MARK: - Paginable

    func retrievePage(page: Int) {

        guard let userBuyer = buyer else { return }

        delegate?.vmDidStartRetrievingChatMessages(hasData: !loadedMessages.isEmpty)
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
                    strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
                    strongSelf.afterRetrieveChatMessagesEvents()
                } else if let error = result.error {
                    switch (error) {
                    case .NotFound:
                        //New chat!! this is success
                        strongSelf.isLastPage = true
                        strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
                        strongSelf.afterRetrieveChatMessagesEvents()
                    case .Network, .Unauthorized, .Internal:
                        strongSelf.delegate?.vmDidFailRetrievingChatMessages()
                    }
                }
                strongSelf.isLoading = false
        }
    }

    private func afterRetrieveChatMessagesEvents() {
        if shouldShowSafetyTips {
            safetyTipsBtnPressed()
        }
    }
}


// MARK: - DirectAnswers

extension ChatViewModel: DirectAnswersPresenterDelegate {

    var directAnswers: [DirectAnswer] {
        let emptyAction: ()->Void = { [weak self] in
            self?.clearProductSoldDirectAnswer()
        }
        if isBuyer {
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
        sendMessage(answer.text)
    }

    func directAnswersDidTapClose(controller: DirectAnswersPresenter) {
        showDirectAnswers(false)
    }

    private func showDirectAnswers(show: Bool) {
        UserDefaultsManager.sharedInstance.saveShouldShowDirectAnswers(show, subKey: userDefaultsSubKey)
        delegate?.vmDidUpdateDirectAnswers()
    }
}
