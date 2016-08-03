//
//  OldChatViewModel.swift
//  LetGo
//
//  Created by Isaac Roldan on 23/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import Result
import RxSwift

protocol OldChatViewModelDelegate: BaseViewModelDelegate {
    
    func vmDidStartRetrievingChatMessages(hasData hasData: Bool)
    func vmDidFailRetrievingChatMessages()
    func vmDidSucceedRetrievingChatMessages()
    func vmUpdateAfterReceivingMessagesAtPositions(positions: [Int])
    
    func vmDidFailSendingMessage()
    func vmDidSucceedSendingMessage()
    
    func vmDidUpdateDirectAnswers()
    func vmShowRelatedProducts(productId: String?)
    func vmDidUpdateProduct(messageToShow message: String?)
    
    func vmShowProduct(productVC: UIViewController)
    func vmShowUser(userVM: UserViewModel)
    func vmShowReportUser(reportUserViewModel: ReportUsersViewModel)
    func vmShowUserRating(source: RateUserSource, data: RateUserData)
    
    func vmShowSafetyTips()
    func vmAskForRating()
    func vmShowPrePermissions(type: PrePermissionType)
    func vmShowKeyboard()
    func vmHideKeyboard(animated animated: Bool)
    func vmShowMessage(message: String, completion: (() -> ())?)
    func vmShowOptionsList(options: [String], actions: [() -> Void])
    func vmShowQuestion(title title: String, message: String, positiveText: String, positiveAction: (() -> Void)?,
                              positiveActionStyle: UIAlertActionStyle?, negativeText: String, negativeAction: (() -> Void)?,
                              negativeActionStyle: UIAlertActionStyle?)
    func vmClose()
    
    func vmLoadStickersTooltipWithText(text: NSAttributedString)

    func vmUpdateRelationInfoView(status: ChatInfoViewStatus)
    func vmUpdateChatInteraction(enabled: Bool)
    
    func vmDidUpdateStickers()
    func vmClearText()

    func vmUpdateUserIsReadyToReview()
}

enum AskQuestionSource {
    case ProductList
    case ProductDetail
}


public class OldChatViewModel: BaseViewModel, Paginable {
    
    
    // MARK: > Public data
    
    var fromMakeOffer = false
    var askQuestion: AskQuestionSource?
    
    // MARK: > Controller data
    
    weak var delegate: OldChatViewModelDelegate?
    var title: String? {
        return product.title
    }
    var productName: String? {
        return product.title
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

    var stickers: [Sticker] = []

    var userRelation: UserUserRelation? {
        didSet {
            delegate?.vmUpdateRelationInfoView(chatStatus)
            if let relation = userRelation where relation.isBlocked || relation.isBlockedBy {
                delegate?.vmHideKeyboard(animated: true)
                showDirectAnswers(false)
            } else {
                showDirectAnswers(shouldShowDirectAnswers)
            }
            delegate?.vmUpdateChatInteraction(chatEnabled)
        }
    }


    var shouldShowDirectAnswers: Bool {
        return directAnswersAvailable &&
            KeyValueStorage.sharedInstance.userLoadChatShowDirectAnswersForKey(userDefaultsSubKey)
    }
    var keyForTextCaching: String {
        return userDefaultsSubKey
    }

    var chatStatus: ChatInfoViewStatus {
        if chat.forbidden {
            return .Forbidden
        }

        guard let otherUser = otherUser else { return .UserDeleted }
        switch otherUser.status {
        case .Scammer:
            return .Forbidden
        case .PendingDelete:
            return .UserPendingDelete
        case .Deleted:
            return .UserDeleted
        case .Active, .Inactive, .NotFound:
            break // In this case we rely on the rest of states
        }

        if let relation = userRelation {
            if relation.isBlocked { return .Blocked }
            if relation.isBlockedBy { return .BlockedBy }
        }
        
        switch product.status {
        case .Deleted, .Discarded:
            return .ProductDeleted
        case .Sold, .SoldOld:
            return .ProductSold
        case .Approved, .Pending:
            return .Available
        }
    }

    var directAnswersAvailable: Bool {
        return chatEnabled && !relatedProductsEnabled
    }

    var relatedProductsEnabled: Bool {
        guard isBuyer else { return false }
        switch chatStatus {
        case .Forbidden, .UserDeleted, .UserPendingDelete, .ProductDeleted:
            return true
        case .Blocked, .BlockedBy, .Available, .ProductSold:
            return false
        }
    }

    var chatEnabled: Bool {
        switch chatStatus {
        case .Forbidden, .Blocked, .BlockedBy, .UserDeleted, .UserPendingDelete:
            return false
        case .Available, .ProductSold, .ProductDeleted:
            return true
        }
    }

    var otherUserEnabled: Bool {
        switch chatStatus {
        case .Forbidden, .UserDeleted, .UserPendingDelete:
            return false
        case .Available, .ProductSold, .ProductDeleted, .Blocked, .BlockedBy:
            return true
        }
    }

    let isSendingMessage = Variable<Bool>(false)

    var userBlockedDisclaimerMessage: ChatViewMessage {
        return chatViewMessageAdapter.createUserBlockedDisclaimerMessage(
            isBuyer: isBuyer, userName: otherUser?.name,
            actionTitle: LGLocalizedString.chatBlockedDisclaimerSafetyTipsButton, action: safetyTipsAction)
    }

    var messageSuspiciousDisclaimerMessage: ChatViewMessage {
        return chatViewMessageAdapter.createMessageSuspiciousDisclaimerMessage(safetyTipsAction)
    }

    var userInfoMessage: ChatViewMessage? {
        return chatViewMessageAdapter.createUserInfoMessage(otherUser)
    }

    var userDeletedDisclaimerMessage: ChatViewMessage? {
        switch chatStatus {
        case  .UserPendingDelete, .UserDeleted:
            return chatViewMessageAdapter.createUserDeletedDisclaimerMessage(otherUser?.name)
        case .ProductDeleted, .Forbidden, .Available, .Blocked, .BlockedBy, .ProductSold:
            return nil
        }
    }

    var safetyTipsAction: () -> Void {
        return { [weak self] in
            self?.delegate?.vmShowSafetyTips()
        }
    }

    var userIsReviewable: Bool {
        switch chatStatus {
        case .Available, .ProductSold:
            return enoughMessagesForUserRating
        case .ProductDeleted, .Forbidden, .UserPendingDelete, .UserDeleted, .Blocked, .BlockedBy:
            return false
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
    
    private let chatRepository: OldChatRepository
    private let myUserRepository: MyUserRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let stickersRepository: StickersRepository
    private let chatViewMessageAdapter: ChatViewMessageAdapter
    private let tracker: Tracker
    private let configManager: ConfigManager
    
    private var chat: Chat
    private var product: Product
    private var isDeleted = false
    private var shouldAskProductSold: Bool = false
    private var userDefaultsSubKey: String {
        return "\(product.objectId) + \(buyer?.objectId ?? "offline")"
    }
    
    private var loadedMessages: [ChatViewMessage]
    private var buyer: User?
    private var otherUser: User?
    private var afterRetrieveMessagesBlock: (() -> Void)?
    private var autoKeyboardEnabled = true

    private var isBuyer: Bool {
        guard let buyer = buyer else { return true }
        guard let buyerId = buyer.objectId, myUserId = myUserRepository.myUser?.objectId else { return false }
        return buyerId == myUserId
    }
    private var shouldShowSafetyTips: Bool {
        return !KeyValueStorage.sharedInstance.userChatSafetyTipsShown && didReceiveMessageFromOtherUser
    }
    private var didReceiveMessageFromOtherUser: Bool {
        guard let otherUserId = otherUser?.objectId else { return false }
        for message in loadedMessages {
            if message.talkerId == otherUserId {
                return true
            }
        }
        return false
    }
    private var didSendMessage: Bool {
        guard let myUserId = myUserRepository.myUser?.objectId else { return false }
        for message in loadedMessages {
            if message.talkerId == myUserId {
                return true
            }
        }
        return false
    }
    private var enoughMessagesForUserRating: Bool {
        guard let myUserId = myUserRepository.myUser?.objectId else { return false }
        guard let otherUserId = otherUser?.objectId else { return false }

        var myMessagesCount = 0
        var otherMessagesCount = 0
        for message in loadedMessages {
            if message.talkerId == myUserId {
                myMessagesCount += 1
            } else if message.talkerId == otherUserId {
                otherMessagesCount += 1
            }
            if myMessagesCount >= configManager.myMessagesCountForRating &&
                otherMessagesCount >= configManager.otherMessagesCountForRating {
                return true
            }
        }
        return false
    }
    private var shouldShowOtherUserInfo: Bool {
        guard chat.isSaved else { return true }
        return !isLoading && isLastPage
    }
    
    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle

    convenience init?(chat: Chat) {
        self.init(chat: chat, myUserRepository: Core.myUserRepository, configManager: ConfigManager.sharedInstance)
    }
    
    convenience init?(product: Product) {
        let myUserRepository = Core.myUserRepository
        let chat = LocalChat(product: product, myUser: myUserRepository.myUser)
        let configManager = ConfigManager.sharedInstance

        self.init(chat: chat, myUserRepository: myUserRepository, configManager: configManager)
    }

    convenience init?(chat: Chat, myUserRepository: MyUserRepository, configManager: ConfigManager) {
        let chatRepository = Core.oldChatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        let stickersRepository = Core.stickersRepository
        self.init(chat: chat, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository, tracker: tracker, configManager: configManager)
    }

    init?(chat: Chat, myUserRepository: MyUserRepository, chatRepository: OldChatRepository,
          productRepository: ProductRepository, userRepository: UserRepository, stickersRepository: StickersRepository,
          tracker: Tracker, configManager: ConfigManager) {
        self.chat = chat
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.stickersRepository = stickersRepository
        self.chatViewMessageAdapter = ChatViewMessageAdapter()
        self.tracker = tracker
        self.configManager = configManager
        self.loadedMessages = []
        self.product = chat.product
        if let myUser = myUserRepository.myUser {
            self.isDeleted = chat.isArchived(myUser: myUser)
        }
        super.init()
        initUsers()
        loadStickers()
        if otherUser == nil { return nil }

        setupDeepLinksRx()
    }
    
    override func didBecomeActive(firstTime: Bool) {
        if firstTime {
            checkShowRelatedProducts()
        }

        guard !chat.forbidden else {
            showDisclaimerMessage()
            markForbiddenAsRead()
            return
        }

        // only load messages if the chat is not forbidden
        retrieveFirstPage()
        retrieveUsersRelation()
        if firstTime {
            retrieveInterlocutorInfo()
            loadStickersTooltip()
        }
    }
    
    func showDisclaimerMessage() {
        loadedMessages = [userBlockedDisclaimerMessage]
        delegate?.vmDidSucceedRetrievingChatMessages()
    }

    func checkShowRelatedProducts() {
        guard relatedProductsEnabled else { return }
        delegate?.vmShowRelatedProducts(product.objectId)
    }
    
    func didAppear() {
        if fromMakeOffer &&
            PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat(buyer: isBuyer)){
            fromMakeOffer = false
            delegate?.vmShowPrePermissions(.Chat(buyer: isBuyer))
        } else if !chatEnabled {
            delegate?.vmHideKeyboard(animated: true)
        } else if autoKeyboardEnabled {
            delegate?.vmShowKeyboard()
        }
    }

    
    // MARK: - Public
    
    func productInfoPressed() {
        switch chatStatus {
        case .ProductDeleted, .Forbidden:
            break
        case .Available, .Blocked, .BlockedBy, .ProductSold, .UserPendingDelete, .UserDeleted:
            guard let productVC = ProductDetailFactory.productDetailFromProduct(product) else { return }
            delegate?.vmShowProduct(productVC)
        }
    }
    
    func userInfoPressed() {
        switch chatStatus {
        case .ProductDeleted, .Forbidden, .UserPendingDelete, .UserDeleted:
            break
        case .Available, .Blocked, .BlockedBy, .ProductSold:
            guard let user = otherUser else { return }
            let userVM = UserViewModel(user: user, source: .Chat)
            delegate?.vmShowUser(userVM)
        }
    }

    func reviewUserPressed() {
        guard let otherUser = otherUser, reviewData = RateUserData(user: otherUser) else { return }
        delegate?.vmShowUserRating(.Chat, data: reviewData)
    }
    
    func safetyTipsDismissed() {
        KeyValueStorage.sharedInstance.userChatSafetyTipsShown = true
    }
    
    func optionsBtnPressed() {
        var texts: [String] = []
        var actions: [() -> Void] = []
        //Safety tips
        texts.append(LGLocalizedString.chatSafetyTips)
        actions.append({ [weak self] in self?.delegate?.vmShowSafetyTips() })

        //Direct answers
        if chat.isSaved && directAnswersAvailable {
            texts.append(shouldShowDirectAnswers ? LGLocalizedString.directAnswersHide :
                LGLocalizedString.directAnswersShow)
            actions.append({ [weak self] in self?.toggleDirectAnswers() })
        }
        //Delete
        if chat.isSaved && !isDeleted {
            texts.append(LGLocalizedString.chatListDelete)
            actions.append({ [weak self] in self?.delete() })
        }

        if myUserRepository.myUser != nil && otherUserEnabled {
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
        }
        
        delegate?.vmShowOptionsList(texts, actions: actions)
    }
    
    func messageAtIndex(index: Int) -> ChatViewMessage {
        return loadedMessages[index]
    }
    
    func textOfMessageAtIndex(index: Int) -> String {
        return loadedMessages[index].value
    }
    
    func sendSticker(sticker: Sticker) {
        sendMessage(sticker.name, isQuickAnswer: false, type: .Sticker)
    }
    
    func sendText(text: String, isQuickAnswer: Bool) {
        sendMessage(text, isQuickAnswer: isQuickAnswer, type: .Text)
    }
    
    func isMatchingConversationData(data: ConversationData) -> Bool {
        switch data {
        case .Conversation(let conversationId):
            return conversationId == chat.objectId
        case let .ProductBuyer(productId, buyerId):
            return productId == product.objectId && buyerId == buyer?.objectId
        }
    }

    func stickersShown() {
        KeyValueStorage.sharedInstance[.stickersTooltipAlreadyShown] = true
    }
    
    
    // MARK: - private methods
    
    private func initUsers() {
        if otherUser == nil || otherUser?.objectId == nil {
            if let myUser = myUserRepository.myUser {
                self.otherUser = chat.otherUser(myUser: myUser)
            } else {
                self.otherUser = chat.userTo
            }
        }

        if let _ = myUserRepository.myUser {
            self.buyer = chat.buyer
        } else {
            self.buyer = nil
        }
    }

    private func loadStickers() {
        stickersRepository.show { [weak self] result in
            if let value = result.value {
                self?.stickers = value
                self?.delegate?.vmDidUpdateStickers()
            }
        }
    }
    
    private func setupDeepLinksRx() {
        DeepLinksRouter.sharedInstance.chatDeepLinks.subscribeNext { [weak self] deepLink in
            switch deepLink.action {
            case .Conversation(let data):
                guard self?.isMatchingConversationData(data) ?? false else { return }
                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
            case .Message(_, let data):
                guard self?.isMatchingConversationData(data) ?? false else { return }
                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
            default: break
            }
            }.addDisposableTo(disposeBag)
    }

    private func sendMessage(text: String, isQuickAnswer: Bool, type: MessageType) {
        guard myUserRepository.myUser != nil else {
            loginAndResend(text, isQuickAnswer: isQuickAnswer, type: type)
            return
        }

        if isSendingMessage.value { return }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let toUser = otherUser else { return }
        if !isQuickAnswer && type != .Sticker {
            delegate?.vmClearText()
        }
        isSendingMessage.value = true

        chatRepository.sendMessage(type, message: message, product: product, recipient: toUser) { [weak self] result in
            guard let strongSelf = self else { return }
            if let sentMessage = result.value, let adapter = self?.chatViewMessageAdapter {
                if let askQuestion = strongSelf.askQuestion {
                    strongSelf.askQuestion = nil
                    strongSelf.trackQuestion(askQuestion, type: type)
                }
                let viewMessage = adapter.adapt(sentMessage)
                strongSelf.loadedMessages.insert(viewMessage, atIndex: 0)
                strongSelf.delegate?.vmDidSucceedSendingMessage()

                strongSelf.trackMessageSent(isQuickAnswer, type: type)
                strongSelf.afterSendMessageEvents()
            } else if let error = result.error {
                switch error {
                case .UserNotVerified:
                    strongSelf.userNotVerifiedError()
                case .Forbidden, .Internal, .Network, .NotFound, .TooManyRequests, .Unauthorized:
                    strongSelf.delegate?.vmDidFailSendingMessage()
                }
            }
            strongSelf.isSendingMessage.value = false
        }
    }

    private func retrieveUsersRelation() {
        guard let otherUserId = otherUser?.objectId else { return }
        userRepository.retrieveUserToUserRelation(otherUserId) { [weak self] result in
            if let value = result.value {
                self?.userRelation = value
            } else {
                self?.userRelation = nil
            }
        }
    }

    private func userNotVerifiedError() {
        guard let myUserEmail = myUserRepository.myUser?.email else {
            delegate?.vmDidFailSendingMessage()
            return
        }
        let okAction = UIAction(interface: .Button(LGLocalizedString.chatVerifyAlertOkButton,
            .Cancel), action: {})
        let resendAction = UIAction(interface: .Button(LGLocalizedString.chatVerifyAlertResendButton, .Default),
                                    action: { [weak self] in self?.resendEmailVerification(myUserEmail) })
        delegate?.vmShowAlertWithTitle(LGLocalizedString.chatVerifyAlertTitle,
                                       text: LGLocalizedString.chatVerifyAlertMessage(myUserEmail),
                                       alertType: .PlainAlert, actions: [resendAction, okAction])
    }

    private func resendEmailVerification(email: String) {
        myUserRepository.linkAccount(email) { [weak self] result in
            if let error = result.error {
                switch error {
                case .TooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests, completion: nil)
                case .Network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody, completion: nil)
                case .Forbidden, .Internal, .NotFound, .Unauthorized, .UserNotVerified:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: nil)
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess, completion: nil)
            }
        }
    }

    private func afterSendMessageEvents() {
        if shouldAskProductSold {
            shouldAskProductSold = false
            delegate?.vmShowQuestion(title: LGLocalizedString.directAnswerSoldQuestionTitle,
                                     message: LGLocalizedString.directAnswerSoldQuestionMessage,
                                     positiveText: LGLocalizedString.directAnswerSoldQuestionOk,
                                     positiveAction: { [weak self] in
                                        self?.markProductAsSold()
                },
                                     positiveActionStyle: nil,
                                     negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
        } else if PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat(buyer: isBuyer)) {
            delegate?.vmShowPrePermissions(.Chat(buyer: isBuyer))
        } else if RatingManager.sharedInstance.shouldShowRating {
            delegate?.vmAskForRating()
        }
        delegate?.vmUpdateUserIsReadyToReview()
    }


    private func loadStickersTooltip() {
        guard chatEnabled && !KeyValueStorage.sharedInstance[.stickersTooltipAlreadyShown] else { return }

        var newTextAttributes = [String : AnyObject]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let newText = NSAttributedString(string: LGLocalizedString.chatStickersTooltipNew, attributes: newTextAttributes)

        var titleTextAttributes = [String : AnyObject]()
        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.whiteColor()
        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let titleText = NSAttributedString(string: LGLocalizedString.chatStickersTooltipAddStickers, attributes: titleTextAttributes)

        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.appendAttributedString(NSAttributedString(string: " "))
        fullTitle.appendAttributedString(titleText)

        delegate?.vmLoadStickersTooltipWithText(fullTitle)
    }
    

    /**
     Retrieves the specified number of the newest messages
     
     - parameter numResults: the num of messages to retrieve
     */
    private func retrieveFirstPageWithNumResults(numResults: Int) {
        
        guard let userBuyer = buyer else { return }
        
        guard canRetrieve else { return }
        
        isLoading = true
        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, page: 0, numResults: numResults) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let chat = result.value {
                strongSelf.chat = chat
                
                let chatMessages = chat.messages.map(strongSelf.chatViewMessageAdapter.adapt)
                let newChatMessages = strongSelf.chatViewMessageAdapter
                    .addDisclaimers(chatMessages, disclaimerMessage: strongSelf.messageSuspiciousDisclaimerMessage)
                
                let insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(strongSelf.loadedMessages,
                                                                                newMessages: newChatMessages)
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
    static func insertNewMessagesAt(mainMessages: [ChatViewMessage], newMessages: [ChatViewMessage])
        -> (messages: [ChatViewMessage], indexes: [Int]) {
            
            guard !newMessages.isEmpty else { return (mainMessages, []) }
            
            // - idxs: the positions of the table that will be inserted
            var idxs: [Int] = []
            
            var firstMsgObjectId: String? = nil
            var messagesWithId: [ChatViewMessage] = mainMessages
            
            // - messages sent don't have Id until the list is refreshed (push received or view appears)
            for message in mainMessages {
                if let objectId = message.objectId {
                    firstMsgObjectId = objectId
                    break
                }
                // last "sent messages" are removed, if any
                messagesWithId.removeFirst()
            }
            // myMessagesWithoutIdCount : num of positions that shouldn't be updated in the table
            let myMessagesWithoutIdCount = mainMessages.count - messagesWithId.count
            
            guard let firstMsgId = firstMsgObjectId,
                indexOfFirstNewItem = newMessages.indexOf({$0.objectId == firstMsgId}) else {
                    //If new messages count doesn't reach the ones without id, it means backend didn't process all of
                    //them yet so let's keep the old ones
                    guard newMessages.count-myMessagesWithoutIdCount >= 0 else { return (mainMessages, []) }
                    //Update non-id with new ones plus the extra ones
                    for i in 0..<newMessages.count-myMessagesWithoutIdCount { idxs.append(i) }
                    return (newMessages + messagesWithId, idxs)
            }
            
            // newMessages can be a whole page, so "reallyNewMessages" are only the ones
            // that come as newMessages and haven't been loaded before
            let reallyNewMessages = newMessages[0..<indexOfFirstNewItem]
            if reallyNewMessages.count-myMessagesWithoutIdCount >= 0 {
                for i in 0..<reallyNewMessages.count-myMessagesWithoutIdCount { idxs.append(i) }
            }
            
            return (reallyNewMessages + messagesWithId, idxs)
    }

    private func markForbiddenAsRead() {
        guard let userBuyer = buyer else { return }
        //We just get the last one as backend will mark all of them as read
        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, numResults: 1, completion: nil)
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
        
        trackBlockUsers([userId])
        
        self.userRepository.blockUserWithId(userId) { result -> Void in
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
        
        trackUnblockUsers([userId])
        
        self.userRepository.unblockUserWithId(userId) { result -> Void in
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
        guard let otherUserId = otherUser?.objectId else { return }
        let reportVM = ReportUsersViewModel(origin: .Chat, userReportedId: otherUserId)
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
    
    private func trackQuestion(source: AskQuestionSource, type: MessageType) {
        // only track ask question if I didn't send any previous message
        guard !didSendMessage else { return }
        let typePageParam: EventParameterTypePage
        switch source {
        case .ProductDetail:
            typePageParam = .ProductDetail
        case .ProductList:
            typePageParam = .ProductList
        }

        let sellerRating: Float? = isBuyer ? otherUser?.ratingAverage : myUserRepository.myUser?.ratingAverage
        let askQuestionEvent = TrackerEvent.productAskQuestion(product, messageType: type.trackingMessageType,
                                                               typePage: typePageParam, sellerRating: sellerRating)
        tracker.trackEvent(askQuestionEvent)
    }
    
    private func trackMessageSent(isQuickAnswer: Bool, type: MessageType) {
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: otherUser,
                                                            messageType: type.trackingMessageType,
                                                            isQuickAnswer: isQuickAnswer ? .True : .False)
        tracker.trackEvent(messageSentEvent)
    }
    
    private func trackBlockUsers(userIds: [String]) {
        let blockUserEvent = TrackerEvent.profileBlock(.Chat, blockedUsersIds: userIds)
        tracker.trackEvent(blockUserEvent)
    }
    
    private func trackUnblockUsers(userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.Chat, unblockedUsersIds: userIds)
        tracker.trackEvent(unblockUserEvent)
    }
    
    // MARK: - Paginable
    
    func retrievePage(page: Int) {
        
        guard let userBuyer = buyer else { return }
        
        delegate?.vmDidStartRetrievingChatMessages(hasData: !loadedMessages.isEmpty)
        isLoading = true
        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, page: page, numResults: resultsPerPage) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let chat = result.value {
                strongSelf.isLastPage = chat.messages.count < strongSelf.resultsPerPage
                strongSelf.chat = chat
                strongSelf.nextPage = page + 1

                let mappedChatMessages = chat.messages.map(strongSelf.chatViewMessageAdapter.adapt)
                let chatMessages: [ChatViewMessage] = strongSelf.chatViewMessageAdapter
                    .addDisclaimers(mappedChatMessages, disclaimerMessage: strongSelf.messageSuspiciousDisclaimerMessage)
                
                if page == 0 {
                    if let userDeletedMessage = strongSelf.userDeletedDisclaimerMessage {
                        strongSelf.loadedMessages = [userDeletedMessage] + chatMessages
                    } else {
                        strongSelf.loadedMessages = chatMessages
                    }
                } else {
                    strongSelf.loadedMessages += chatMessages
                }

                if let userInfoMessage = strongSelf.userInfoMessage where strongSelf.isLastPage {
                    strongSelf.loadedMessages += [userInfoMessage]
                }

                if chat.forbidden {
                    strongSelf.showDisclaimerMessage()
                    strongSelf.delegate?.vmUpdateChatInteraction(false)
                } else {
                    strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
                    strongSelf.afterRetrieveChatMessagesEvents()
                }
            } else if let error = result.error {
                switch (error) {
                case .NotFound:
                    //The chat doesn't exist yet, so this must be a new conversation!! this is success
                    strongSelf.isLastPage = true

                    if let userInfoMessage = strongSelf.userInfoMessage {
                        strongSelf.loadedMessages = [userInfoMessage]
                    }

                    strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
                    strongSelf.afterRetrieveChatMessagesEvents()
                case .Network, .Unauthorized, .Internal, .Forbidden, .TooManyRequests, .UserNotVerified:
                    strongSelf.delegate?.vmDidFailRetrievingChatMessages()
                }
            }
            strongSelf.isLoading = false
        }
    }
    
    private func afterRetrieveChatMessagesEvents() {
        afterRetrieveMessagesBlock?()
        afterRetrieveMessagesBlock = nil

        if shouldShowSafetyTips {
            delegate?.vmShowSafetyTips()
        }
        delegate?.vmUpdateUserIsReadyToReview()
    }
}


// MARK: - DirectAnswers

extension OldChatViewModel: DirectAnswersPresenterDelegate {
    
    var directAnswers: [DirectAnswer] {
        let emptyAction: () -> Void = { [weak self] in
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
        sendText(answer.text, isQuickAnswer: true)
    }
    
    func directAnswersDidTapClose(controller: DirectAnswersPresenter) {
        showDirectAnswers(false)
    }
    
    private func showDirectAnswers(show: Bool) {
        KeyValueStorage.sharedInstance.userSaveChatShowDirectAnswersForKey(userDefaultsSubKey, value: show)
        delegate?.vmDidUpdateDirectAnswers()
    }
}


// MARK: - UserInfo

private extension OldChatViewModel {
    func retrieveInterlocutorInfo() {
        guard let otherUserId = otherUser?.objectId else { return }
        userRepository.show(otherUserId, includeAccounts: true) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let userWaccounts = result.value else { return }
            strongSelf.otherUser = userWaccounts
            if let userInfoMessage = strongSelf.userInfoMessage where strongSelf.shouldShowOtherUserInfo {
                strongSelf.loadedMessages += [userInfoMessage]
                strongSelf.delegate?.vmDidSucceedRetrievingChatMessages()
            }
        }
    }
}


// MARK: - User verification & Second step login

private extension OldChatViewModel {
    func loginAndResend(text: String, isQuickAnswer: Bool, type: MessageType) {
        let completion = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.autoKeyboardEnabled = true
            strongSelf.chat = LocalChat(product: strongSelf.product , myUser: strongSelf.myUserRepository.myUser)
            // Setting the buyer
            strongSelf.initUsers()
            strongSelf.afterRetrieveMessagesBlock = { [weak self] in
                // Updating with real data
                self?.initUsers()
                // In case there were messages in the conversation, don't send the message automatically.
                guard let messages = self?.chat.messages where messages.isEmpty else {
                    strongSelf.isSendingMessage.value = false
                    return
                }
                self?.sendMessage(text, isQuickAnswer: isQuickAnswer, type: type)
            }
            strongSelf.retrieveFirstPage()
            strongSelf.retrieveUsersRelation()
        }
        /* Needed to avoid showing the keyboard while login in (as the login is overCurrentContext) so chat will become
         'visible' while login screen is there */
        autoKeyboardEnabled = false
        delegate?.vmHideKeyboard(animated: false) // this forces SLKTextViewController to have correct keyboard info
        delegate?.ifLoggedInThen(.AskQuestion, loginStyle: .Popup(LGLocalizedString.chatLoginPopupText),
                                 loggedInAction: completion, elsePresentSignUpWithSuccessAction: completion)
    }
}


// MARK: - Related products

extension OldChatViewModel: RelatedProductsViewDelegate {

    func relatedProductsViewDidShow(view: RelatedProductsView) {

        //TODO: TRACKING
    }

    func relatedProductsView(view: RelatedProductsView, didSelectProduct product: Product, thumbnailImage: UIImage?,
                             originFrame: CGRect?) {
        //TODO: TRACKING
        guard let productVC = ProductDetailFactory.productDetailFromProduct(product, thumbnailImage: thumbnailImage,
                                                                            originFrame: originFrame) else { return }
        delegate?.vmShowProduct(productVC)
    }
}


// MARK: - MessageType tracking

extension MessageType {
    var trackingMessageType: EventParameterMessageType {
        switch self {
        case .Text:
            return .Text
        case .Offer:
            return .Offer
        case .Sticker:
            return .Sticker
        }
    }
}
