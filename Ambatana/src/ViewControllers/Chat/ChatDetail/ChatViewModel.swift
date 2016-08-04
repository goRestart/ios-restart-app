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

    func vmDidFailSendingMessage()
    func vmDidFailRetrievingChatMessages()
    
    func vmShowReportUser(reportUserViewModel: ReportUsersViewModel)
    func vmShowUserRating(source: RateUserSource, data: RateUserData)

    func vmShowSafetyTips()

    func vmClearText()
    func vmHideKeyboard(animated: Bool)
    func vmShowKeyboard()
    
    func vmAskForRating()
    func vmShowPrePermissions(type: PrePermissionType)
    func vmShowMessage(message: String, completion: (() -> ())?)
    func vmRequestLogin(loggedInAction: () -> Void)
    func vmLoadStickersTooltipWithText(text: NSAttributedString)
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
    weak var tabNavigator: TabNavigator?
    
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
    var stickers = Variable<[Sticker]>([])
    var keyForTextCaching: String { return userDefaultsSubKey }
    var askQuestion: AskQuestionSource?

    private var shouldShowSafetyTips: Bool {
        return !KeyValueStorage.sharedInstance.userChatSafetyTipsShown && didReceiveMessageFromOtherUser
    }
    
    private var didReceiveMessageFromOtherUser: Bool {
        for message in messages.value {
            if message.talkerId == conversation.value.interlocutor?.objectId {
                return true
            }
        }
        return false
    }

    private var didSendMessage: Bool {
        guard let myUserId = myUserRepository.myUser?.objectId else { return false }
        for message in messages.value {
            if message.talkerId == myUserId {
                return true
            }
        }
        return false
    }

    var interlocutorEnabled: Bool {
        switch chatStatus.value {
        case .Forbidden, .UserDeleted, .UserPendingDelete:
            return false
        case .Available, .ProductSold, .ProductDeleted, .Blocked, .BlockedBy:
            return true
        }
    }

    var shouldShowDirectAnswers: Bool {
        return chatEnabled.value && KeyValueStorage.sharedInstance.userLoadChatShowDirectAnswersForKey(userDefaultsSubKey)
    }
    
    // Rx Variables
    var interlocutorIsMuted = Variable<Bool>(false)
    var interlocutorHasMutedYou = Variable<Bool>(false)
    var chatStatus = Variable<ChatInfoViewStatus>(.Available)
    var chatEnabled = Variable<Bool>(true)
    var interlocutorTyping = Variable<Bool>(false)
    var messages = CollectionVariable<ChatViewMessage>([])
    private var conversation: Variable<ChatConversation>
    private var interlocutor: User?
    private var myMessagesCount = Variable<Int>(0)
    private var otherMessagesCount = Variable<Int>(0)
    var userIsReviewable = Variable<Bool>(false)

    // Private    
    private let myUserRepository: MyUserRepository
    private let chatRepository: ChatRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let stickersRepository: StickersRepository
    private let chatViewMessageAdapter: ChatViewMessageAdapter
    private let tracker: Tracker
    private let configManager: ConfigManager
    
    private var isDeleted = false
    private var shouldAskProductSold: Bool = false
    private var isSendingQuickAnswer = false
    private var productId: String?
    private var preSendMessageCompletion: ((text: String, isQuickAnswer: Bool, type: ChatMessageType) -> Void)?
    private var afterRetrieveMessagesCompletion: (() -> Void)?
    
    private let disposeBag = DisposeBag()
    
    private var userDefaultsSubKey: String {
        return "\(conversation.value.product?.objectId ?? productId) + \(conversation.value.interlocutor?.objectId)"
    }

    private var isBuyer: Bool {
        return !conversation.value.amISelling
    }

    private var shouldShowOtherUserInfo: Bool {
        guard conversation.value.isSaved else { return true }
        return !isLoading && isLastPage
    }

    private var safetyTipsAction: () -> Void {
        return { [weak self] in
            self?.delegate?.vmShowSafetyTips()
        }
    }

    convenience init(conversation: ChatConversation, tabNavigator: TabNavigator?) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        let stickersRepository = Core.stickersRepository
        let configManager = ConfigManager.sharedInstance

        self.init(conversation: conversation, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository, tracker: tracker, configManager: configManager,
                  tabNavigator: tabNavigator)
    }
    
    convenience init?(product: Product, tabNavigator: TabNavigator?) {
        guard let _ = product.objectId, sellerId = product.user.objectId else { return nil }

        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let stickersRepository = Core.stickersRepository
        let tracker = TrackerProxy.sharedInstance
        let configManager = ConfigManager.sharedInstance

        let amISelling = myUserRepository.myUser?.objectId == sellerId
        let empty = EmptyConversation(objectId: nil, unreadMessageCount: 0, lastMessageSentAt: nil, product: nil,
                                      interlocutor: nil, amISelling: amISelling)
        self.init(conversation: empty, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository ,tracker: tracker, configManager: configManager,
                  tabNavigator: tabNavigator)
        self.setupConversationFromProduct(product)
    }
    
    init(conversation: ChatConversation, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
          productRepository: ProductRepository, userRepository: UserRepository, stickersRepository: StickersRepository,
          tracker: Tracker, configManager: ConfigManager, tabNavigator: TabNavigator?) {
        self.conversation = Variable<ChatConversation>(conversation)
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.tracker = tracker
        self.configManager = configManager
        self.stickersRepository = stickersRepository
        self.chatViewMessageAdapter = ChatViewMessageAdapter()
        self.tabNavigator = tabNavigator
        super.init()
        setupRx()
        loadStickers()
    }
    
    override func didBecomeActive(firstTime: Bool) {
        // only load messages if the interlocutor is not blocked
        guard let interlocutor = conversation.value.interlocutor else { return }
        guard !interlocutor.isBanned else { return }
        retrieveMoreMessages()
        loadStickersTooltip()
        if conversation.value.isSaved && chatEnabled.value {
            delegate?.vmShowKeyboard()
        }
    }

    func setupConversationFromProduct(product: Product) {
        guard let productId = product.objectId, sellerId = product.user.objectId else { return }
        if let _ =  myUserRepository.myUser?.objectId {
            syncConversation(productId, sellerId: sellerId)
        } else {
            setupNotLoggedIn(product)
        }
    }

    func syncConversation(productId: String, sellerId: String) {
        chatRepository.showConversation(sellerId, productId: productId) { [weak self] result in
            if let value = result.value {
                self?.conversation.value = value
                self?.retrieveMoreMessages()
                self?.setupChatEventsRx()
            } else if let _ = result.error {
                self?.delegate?.vmDidFailRetrievingChatMessages()
            }
        }
    }
    
    func refreshConversation() {
        guard let conversationId = conversation.value.objectId else { return }
        chatRepository.showConversation(conversationId) { [weak self] result in
            if let value = result.value {
                self?.conversation.value = value
            }
        }
    }
    
    func loadStickers() {
        stickersRepository.show { [weak self] result in
            if let value = result.value {
                self?.stickers.value = value
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

        chatStatus.asObservable().subscribeNext { [weak self] status in
            guard let strongSelf = self else { return }
            
            if status == .Forbidden {
                let disclaimer = strongSelf.chatViewMessageAdapter.createUserBlockedDisclaimerMessage(
                    isBuyer: strongSelf.isBuyer, userName: strongSelf.conversation.value.interlocutor?.name,
                    actionTitle:  LGLocalizedString.chatBlockedDisclaimerSafetyTipsButton, action: strongSelf.safetyTipsAction)
                self?.messages.removeAll()
                self?.messages.append(disclaimer)
            }
        }.addDisposableTo(disposeBag)


        let cfgManager = configManager
        let myMessagesReviewable = myMessagesCount.asObservable()
            .map { $0 >= cfgManager.myMessagesCountForRating }
            .distinctUntilChanged()
        let otherMessagesReviewable = otherMessagesCount.asObservable()
            .map { $0 >= cfgManager.otherMessagesCountForRating }
            .distinctUntilChanged()
        let chatStatusReviewable = chatStatus.asObservable().map { $0.userReviewEnabled }.distinctUntilChanged()

        Observable.combineLatest(myMessagesReviewable, otherMessagesReviewable, chatStatusReviewable) { $0 && $1 && $2 }
            .bindTo(userIsReviewable).addDisposableTo(disposeBag)

        messages.changesObservable.subscribeNext { [weak self] change in
            self?.updateMessagesCounts(change)
        }.addDisposableTo(disposeBag)

        setupChatEventsRx()
    }

    func updateMessagesCounts(changeInMessages: CollectionChange<ChatViewMessage>) {
        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        guard let otherUserId = conversation.value.interlocutor?.objectId else { return }

        switch changeInMessages {
        case let .Remove(_, message):
            if message.talkerId == myUserId {
                myMessagesCount.value = max(0, myMessagesCount.value-1)
            } else if message.talkerId == otherUserId {
                otherMessagesCount.value = max(0, otherMessagesCount.value-1)
            }
        case let .Insert(_, message):
            if message.talkerId == myUserId {
                myMessagesCount.value += 1
            } else if message.talkerId == otherUserId {
                otherMessagesCount.value += 1
            }
        case let .Composite(changes):
            changes.forEach { [weak self] change in
                self?.updateMessagesCounts(change)
            }
        }
    }

    func setupChatEventsRx() {
        guard let convId = conversation.value.objectId else { return }
        chatRepository.chatEventsIn(convId).subscribeNext { [weak self] event in
            switch event.type {
            case let .InterlocutorMessageSent(messageId, sentAt, text, type):
                self?.handleNewMessageFromInterlocutor(messageId, sentAt: sentAt, text: text, type: type)
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
            break
        case .Pending, .Approved, .Discarded, .Sold, .SoldOld:
            guard let interlocutor = conversation.value.interlocutor else { return }
            delegate?.vmHideKeyboard(false)
            tabNavigator?.openProduct(chatProduct: product, user: interlocutor, thumbnailImage: nil, originFrame: nil)
        }
    }
    
    func userInfoPressed() {
        guard let interlocutor = conversation.value.interlocutor else { return }
        delegate?.vmHideKeyboard(false)
        tabNavigator?.openUser(interlocutor)
    }

    func reviewUserPressed() {
        guard let interlocutor = conversation.value.interlocutor, reviewData = RateUserData(interlocutor: interlocutor)
            else { return }
        delegate?.vmShowUserRating(.Chat, data: reviewData)
    }

    func safetyTipsDismissed() {
        KeyValueStorage.sharedInstance.userChatSafetyTipsShown = true
    }
    
    func messageAtIndex(index: Int) -> ChatViewMessage? {
        guard 0..<messages.value.count ~= index else { return nil }
        return messages.value[index]
    }
    
    func textOfMessageAtIndex(index: Int) -> String? {
        return messageAtIndex(index)?.value
    }

    func loadStickersTooltip() {
        guard chatEnabled.value && !KeyValueStorage.sharedInstance[.stickersTooltipAlreadyShown] else { return }

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

    func stickersShown() {
        KeyValueStorage.sharedInstance[.stickersTooltipAlreadyShown] = true
    }
}


// MARK: - Private methods

extension ChatViewModel {
    
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
    
    func sendSticker(sticker: Sticker) {
        sendMessage(sticker.name, isQuickAnswer: false, type: .Sticker)
    }
    
    func sendText(text: String, isQuickAnswer: Bool) {
        sendMessage(text, isQuickAnswer: isQuickAnswer, type: .Text)
    }
    
    private func sendMessage(text: String, isQuickAnswer: Bool, type: ChatMessageType) {
        if let preSendMessageCompletion = preSendMessageCompletion {
            preSendMessageCompletion(text: text, isQuickAnswer: isQuickAnswer, type: type)
            return
        }

        if isQuickAnswer {
            if isSendingQuickAnswer { return }
            isSendingQuickAnswer = true
        }
        let message = text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        guard message.characters.count > 0 else { return }
        guard let convId = conversation.value.objectId else { return }
        guard let userId = myUserRepository.myUser?.objectId else { return }

        if !isQuickAnswer && type != .Sticker {
            delegate?.vmClearText()
        }

        let newMessage = chatRepository.createNewMessage(userId, text: text, type: type)
        let viewMessage = chatViewMessageAdapter.adapt(newMessage).markAsSent()
        messages.insert(viewMessage, atIndex: 0)
        chatRepository.sendMessage(convId, messageId: newMessage.objectId!, type: newMessage.type, text: text) {
            [weak self] result in
            if let _ = result.value {
                guard let id = newMessage.objectId else { return }
                self?.markMessageAsSent(id)
                self?.afterSendMessageEvents()
                self?.trackMessageSent(isQuickAnswer, type: type)

                if let askQuestion = self?.askQuestion {
                    self?.askQuestion = nil
                    self?.trackQuestion(askQuestion, type: type)
                }
            } else if let error = result.error {
                // TODO: 🎪 Create an "errored" state for Chat Message so we can retry
                switch error {
                case .UserNotVerified:
                    self?.userNotVerifiedError()
                case .Forbidden, .Internal, .Network, .NotFound, .TooManyRequests, .Unauthorized:
                    self?.delegate?.vmDidFailSendingMessage()
                }
            }
            if isQuickAnswer {
                self?.isSendingQuickAnswer = false
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

    private func afterSendMessageEvents() {
        if shouldAskProductSold {
            shouldAskProductSold = false
            let action = UIAction(interface: UIActionInterface.Text(LGLocalizedString.directAnswerSoldQuestionOk),
                                  action: markProductAsSold)
            delegate?.vmShowAlert(LGLocalizedString.directAnswerSoldQuestionTitle,
                                  message: LGLocalizedString.directAnswerSoldQuestionMessage,
                                  cancelLabel: LGLocalizedString.commonCancel,
                                  actions: [action])
        } else if PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.Chat(buyer: isBuyer)) {
            delegate?.vmShowPrePermissions(.Chat(buyer: isBuyer))
        } else if RatingManager.sharedInstance.shouldShowRating {
            delegate?.vmAskForRating()
        }
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
    
    private func updateMessageWithAction(messageId: String, action: ChatViewMessage -> ChatViewMessage) {
        guard let index = messages.value.indexOf({$0.objectId == messageId}) else { return }
        let message = messages.value[index]
        let newMessage = action(message)
        let range = index..<(index+1)
        messages.replace(range, with: [newMessage])
    }
    
    private func handleNewMessageFromInterlocutor(messageId: String, sentAt: NSDate, text: String, type: ChatMessageType) {
        guard let convId = conversation.value.objectId else { return }
        guard let interlocutorId = conversation.value.interlocutor?.objectId else { return }
        let message: ChatMessage = chatRepository.createNewMessage(interlocutorId, text: text, type: type)
        let viewMessage = chatViewMessageAdapter.adapt(message).markAsSent().markAsReceived().markAsRead()
        messages.insert(viewMessage, atIndex: 0)
        chatRepository.confirmReception(convId, messageIds: [messageId], completion: nil)
        chatRepository.confirmRead(convId, messageIds: [messageId], completion: nil)
    }
}


// MARK: - Product Operations

extension ChatViewModel {
    private func markProductAsSold() {
        guard conversation.value.amISelling else { return }
        guard let productId = conversation.value.product?.objectId else { return }
        productRepository.markProductAsSold(productId) { [weak self] result in
            self?.refreshConversation()
        }
    }
}


// MARK: - Options Menu

extension ChatViewModel {
    
    func openOptionsMenu() {
        var actions: [UIAction] = []
        
        let safetyTips = UIAction(interface: UIActionInterface.Text(LGLocalizedString.chatSafetyTips)) { [weak self] in
            self?.delegate?.vmShowSafetyTips()
        }
        actions.append(safetyTips)

        if conversation.value.isSaved {
            if chatEnabled.value {
                let directAnswersText = shouldShowDirectAnswers ? LGLocalizedString.directAnswersHide :
                    LGLocalizedString.directAnswersShow
                let directAnswersAction = UIAction(interface: UIActionInterface.Text(directAnswersText),
                                                   action: toggleDirectAnswers)
                actions.append(directAnswersAction)
            }
            
            if !isDeleted {
                let delete = UIAction(interface: UIActionInterface.Text(LGLocalizedString.chatListDelete),
                                                   action: deleteAction)
                actions.append(delete)
            }

            if interlocutorEnabled {
                let report = UIAction(interface: UIActionInterface.Text(LGLocalizedString.reportUserTitle),
                                      action: reportUserAction)
                actions.append(report)
              
                if interlocutorIsMuted.value {
                    let unblock = UIAction(interface: UIActionInterface.Text(LGLocalizedString.chatUnblockUser),
                                          action: unblockUserAction)
                    actions.append(unblock)
                } else {
                    let block = UIAction(interface: UIActionInterface.Text(LGLocalizedString.chatBlockUser),
                                           action: blockUserAction)
                    actions.append(block)
                }
            }
        }
        
        delegate?.vmShowActionSheet(LGLocalizedString.commonCancel, actions: actions)
    }
    
    private func toggleDirectAnswers() {
        showDirectAnswers(!shouldShowDirectAnswers)
    }
    
    private func deleteAction() {
        guard !isDeleted else { return }
        
        
        let action = UIAction(interface: .StyledText(LGLocalizedString.chatListDeleteAlertSend, .Destructive)) {
            [weak self] in
            self?.delete() { [weak self] success in
                if success {
                    self?.isDeleted = true
                }
                let message = success ? LGLocalizedString.chatListDeleteOkOne : LGLocalizedString.chatListDeleteErrorOne
                self?.delegate?.vmShowMessage(message) { [weak self] in
                    self?.delegate?.vmClose()
                }
            }
        }
        delegate?.vmShowAlert(LGLocalizedString.chatListDeleteAlertTitleOne,
                              message: LGLocalizedString.chatListDeleteAlertTextOne,
                              cancelLabel: LGLocalizedString.commonCancel,
                              actions: [action])
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
        guard let userID = conversation.value.interlocutor?.objectId else { return }
        let reportVM = ReportUsersViewModel(origin: .Chat, userReportedId: userID)
        delegate?.vmShowReportUser(reportVM)
    }
    
    private func blockUserAction() {
        
        let action = UIAction(interface: .StyledText(LGLocalizedString.chatBlockUserAlertBlockButton, .Destructive)) {
            [weak self] in
            self?.blockUser() { [weak self] success in
                if success {
                    self?.interlocutorIsMuted.value = true
                    self?.refreshConversation()
                } else {
                    self?.delegate?.vmShowMessage(LGLocalizedString.blockUserErrorGeneric, completion: nil)
                }
            }
        }
        
        delegate?.vmShowAlert(LGLocalizedString.chatBlockUserAlertTitle,
                              message: LGLocalizedString.chatBlockUserAlertText,
                              cancelLabel: LGLocalizedString.commonCancel,
                              actions: [action])
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
                self?.refreshConversation()
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
        let threshold = objectCount - Int(Double(resultsPerPage)*0.3)
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
    
    private var defaultDisclaimerMessage: ChatViewMessage {
        return chatViewMessageAdapter.createMessageSuspiciousDisclaimerMessage(safetyTipsAction)
    }

    var userInfoMessage: ChatViewMessage? {
        return chatViewMessageAdapter.createUserInfoMessage(interlocutor)
    }

    var userDeletedMessage: ChatViewMessage? {
        switch chatStatus.value {
        case .UserDeleted, .UserPendingDelete:
            return chatViewMessageAdapter.createUserDeletedDisclaimerMessage(conversation.value.interlocutor?.name)
        case .Available, .Blocked, .BlockedBy, .Forbidden, .ProductDeleted, .ProductSold:
            return nil
        }
    }

    private func downloadFirstPage(conversationId: String) {
        chatRepository.indexMessages(conversationId, numResults: resultsPerPage, offset: 0) {
            [weak self] result in
            guard let strongSelf = self else { return }
            self?.isLoading = false
            if let value = result.value, let adapter = self?.chatViewMessageAdapter {
                self?.isLastPage = value.count == 0
                let messages: [ChatViewMessage] = value.map(adapter.adapt)
                let newMessages = strongSelf.chatViewMessageAdapter
                    .addDisclaimers(messages, disclaimerMessage: strongSelf.defaultDisclaimerMessage)
                self?.messages.removeAll()
                if let userDeletedMessage = self?.userDeletedMessage {
                    self?.messages.append(userDeletedMessage)
                }
                self?.messages.appendContentsOf(newMessages)
                if let userInfoMessage = self?.userInfoMessage where strongSelf.isLastPage {
                    self?.messages.append(userInfoMessage)
                }
                self?.afterRetrieveChatMessagesEvents()
                self?.markAsReadMessages(messages)
            } else if let _ = result.error {
                self?.delegate?.vmDidFailRetrievingChatMessages()
            }
        }
    }
    
    private func downloadMoreMessages(convId: String, fromMessageId: String) {
        chatRepository.indexMessagesOlderThan(fromMessageId, conversationId: convId, numResults: resultsPerPage) {
            [weak self] result in
            guard let strongSelf = self else { return }
            self?.isLoading = false
            if let value = result.value, let adapter = self?.chatViewMessageAdapter {
                let messages = value.map(adapter.adapt)
                if messages.count == 0 {
                    self?.isLastPage = true
                    if let userInfoMessage = self?.userInfoMessage {
                        self?.messages.append(userInfoMessage)
                    }
                } else {
                    let newMessages = strongSelf.chatViewMessageAdapter
                        .addDisclaimers(messages, disclaimerMessage: strongSelf.defaultDisclaimerMessage)
                    self?.messages.appendContentsOf(newMessages)
                    self?.markAsReadMessages(messages)
                }
            } else if let _ = result.error {
                self?.delegate?.vmDidFailRetrievingChatMessages()
            }
        }
    }

    private func markAsReadMessages(chatMessages: [ChatViewMessage] ) {
        guard let convId = conversation.value.objectId else { return }
        guard let interlocutorId = conversation.value.interlocutor?.objectId else { return }

        let receptionIds: [String] = chatMessages.filter { return $0.talkerId == interlocutorId && $0.receivedAt == nil }
            .flatMap{ $0.objectId }
        let readIds: [String] = chatMessages.filter { return $0.talkerId == interlocutorId && $0.readAt == nil }
            .flatMap { $0.objectId }

        if !receptionIds.isEmpty {
            chatRepository.confirmReception(convId, messageIds: receptionIds, completion: nil)
        }
        if !readIds.isEmpty {
            chatRepository.confirmRead(convId, messageIds: readIds, completion: nil)
        }
    }

    private func afterRetrieveChatMessagesEvents() {
        if shouldShowSafetyTips {
            delegate?.vmShowSafetyTips()
        }

        afterRetrieveMessagesCompletion?()
    }
}


// MARK: - Second step login

private extension ChatViewModel {
    func setupNotLoggedIn(product: Product) {
        guard let productId = product.objectId, sellerId = product.user.objectId else { return }
        self.productId = productId

        // Configure product + user info
        title.value = product.title ?? ""
        productName.value = product.title ?? ""
        productImageUrl.value = product.thumbnail?.fileURL
        productPrice.value = product.priceString()
        interlocutorAvatarURL.value = product.user.avatar?.fileURL
        interlocutorName.value = product.user.name ?? ""
        interlocutorId.value = sellerId

        // Configure login + send actions
        preSendMessageCompletion = { [weak self] (text: String, isQuickAnswer: Bool, type: ChatMessageType) in
            self?.delegate?.vmHideKeyboard(false)
            self?.delegate?.vmRequestLogin() { [weak self] in
                self?.preSendMessageCompletion = nil
                self?.afterRetrieveMessagesCompletion = { [weak self] in
                    self?.afterRetrieveMessagesCompletion = nil
                    guard let messages = self?.messages.value where messages.isEmpty else { return }
                    self?.sendMessage(text, isQuickAnswer: isQuickAnswer, type: type)
                }
                self?.syncConversation(productId, sellerId: sellerId)
            }
        }
    }
}


// MARK: - Tracking

private extension ChatViewModel {
    
    private func trackQuestion(source: AskQuestionSource, type: ChatMessageType) {
        // only track ask question if I didn't send any message previously
        guard !didSendMessage else { return }
        let typePageParam: EventParameterTypePage
        switch source {
        case .ProductDetail:
            typePageParam = .ProductDetail
        case .ProductList:
            typePageParam = .ProductList
        }
        guard let product = conversation.value.product else { return }
        guard let userId = conversation.value.interlocutor?.objectId else { return }

        let sellerRating = conversation.value.amISelling ?
            myUserRepository.myUser?.ratingAverage : interlocutor?.ratingAverage
        let askQuestionEvent = TrackerEvent.productAskQuestion(product, messageType: type.trackingMessageType,
                                                               interlocutorId: userId, typePage: typePageParam,
                                                               sellerRating: sellerRating)
        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
    }

    private func trackMessageSent(isQuickAnswer: Bool, type: ChatMessageType) {
        guard let product = conversation.value.product else { return }
        guard let userId = conversation.value.interlocutor?.objectId else { return }
        let messageSentEvent = TrackerEvent.userMessageSent(product, userToId: userId,
                                                            messageType: type.trackingMessageType,
                                                            isQuickAnswer: isQuickAnswer ? .True : .False)
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


// MARK: - Private ChatConversation Extension

private extension ChatConversation {
    var chatStatus: ChatInfoViewStatus {
        guard let interlocutor = interlocutor else { return .Available }
        guard let product = product else { return .Available }

        switch interlocutor.status {
        case .Scammer:
            return .Forbidden
        case .PendingDelete:
            return .UserPendingDelete
        case .Deleted:
            return .UserDeleted
        case .Active, .Inactive, .NotFound:
            break // In this case we rely on the rest of states
        }

        if interlocutor.isBanned { return .Forbidden }
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
        case .Forbidden, .Blocked, .BlockedBy, .UserPendingDelete, .UserDeleted:
            return false
        case .Available, .ProductSold, .ProductDeleted:
            return true
        }
    }
}

private extension ChatInfoViewStatus {
    var userReviewEnabled: Bool {
        switch self {
        case .Forbidden, .Blocked, .BlockedBy, .UserPendingDelete, .UserDeleted, .ProductDeleted:
            return false
        case .Available, .ProductSold:
            return true
        }
    }
}

//// MARK: - DirectAnswers

extension ChatViewModel: DirectAnswersPresenterDelegate {
    
    var directAnswers: [DirectAnswer] {
        let emptyAction: () -> Void = { [weak self] in
            self?.clearProductSoldDirectAnswer()
        }
        if !conversation.value.amISelling {
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
    
    private func clearProductSoldDirectAnswer() {
        shouldAskProductSold = false
    }
    
    private func onProductSoldDirectAnswer() {
        if chatStatus.value != .ProductSold {
            shouldAskProductSold = true
        }
    }
}


// MARK: - UserInfo

private extension ChatViewModel {

    func setupUserInfoRxBindings() {
        interlocutorId.asObservable().bindNext { [weak self] interlocutorId in
            guard let interlocutorId = interlocutorId where self?.interlocutor?.objectId != interlocutorId else { return }
            self?.userRepository.show(interlocutorId, includeAccounts: true) { [weak self] result in
                guard let strongSelf = self else { return }
                guard let userWaccounts = result.value else { return }
                strongSelf.interlocutor = userWaccounts
                if let userInfoMessage = strongSelf.userInfoMessage where strongSelf.shouldShowOtherUserInfo {
                    strongSelf.messages.append(userInfoMessage)
                }
            }
        }.addDisposableTo(disposeBag)
    }
}


// MARK: - ChatMessageType tracking

extension ChatMessageType {
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
