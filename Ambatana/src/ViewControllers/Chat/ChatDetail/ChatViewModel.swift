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
    func vmShowRelatedProducts(productId: String?)

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
    weak var navigator: ChatDetailNavigator?
    
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
    var productIsFree = Variable<Bool>(false)
    var interlocutorAvatarURL = Variable<NSURL?>(nil)
    var interlocutorName = Variable<String>("")
    var interlocutorId = Variable<String?>(nil)
    var stickers = Variable<[Sticker]>([])
    var keyForTextCaching: String { return userDefaultsSubKey }
    var askQuestion: AskQuestionSource?
    var relatedProducts: [Product] = []

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
        return directAnswersAvailable && KeyValueStorage.sharedInstance.userLoadChatShowDirectAnswersForKey(userDefaultsSubKey)
    }

    private var directAnswersAvailable: Bool {
        return chatEnabled.value && !relatedProductsEnabled.value
    }

    var shouldShowUserReviewTooltip: Bool {
        // we don't want both tooltips at the same time.  !st stickers, then rating
        return !KeyValueStorage.sharedInstance[.userRatingTooltipAlreadyShown] &&
            KeyValueStorage.sharedInstance[.stickersTooltipAlreadyShown]
    }
    
    // Rx Variables
    let interlocutorIsMuted = Variable<Bool>(false)
    let interlocutorHasMutedYou = Variable<Bool>(false)
    let chatStatus = Variable<ChatInfoViewStatus>(.Available)
    let chatEnabled = Variable<Bool>(true)
    let relatedProductsEnabled = Variable<Bool>(false)
    let interlocutorTyping = Variable<Bool>(false)
    let messages = CollectionVariable<ChatViewMessage>([])
    private let sellerDidntAnswer = Variable<Bool>(false)
    private let conversation: Variable<ChatConversation>
    private var interlocutor: User?
    private let myMessagesCount = Variable<Int>(0)
    private let otherMessagesCount = Variable<Int>(0)
    private let stickersTooltipVisible = Variable<Bool>(!KeyValueStorage.sharedInstance[.stickersTooltipAlreadyShown])
    private let reviewTooltipVisible = Variable<Bool>(!KeyValueStorage.sharedInstance[.userRatingTooltipAlreadyShown])
    let shouldShowReviewButton = Variable<Bool>(false)
    let userReviewTooltipVisible = Variable<Bool>(false)


    // Private    
    private let myUserRepository: MyUserRepository
    private let chatRepository: ChatRepository
    private let productRepository: ProductRepository
    private let userRepository: UserRepository
    private let stickersRepository: StickersRepository
    private let chatViewMessageAdapter: ChatViewMessageAdapter
    private let tracker: Tracker
    private let configManager: ConfigManager
    private let sessionManager: SessionManager
    
    private var isDeleted = false
    private var shouldAskProductSold: Bool = false
    private var isSendingQuickAnswer = false
    private var productId: String? // Only used when accessing a chat from a product
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

    convenience init(conversation: ChatConversation, navigator: ChatDetailNavigator?) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        let stickersRepository = Core.stickersRepository
        let configManager = ConfigManager.sharedInstance
        let sessionManager = Core.sessionManager

        self.init(conversation: conversation, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository, tracker: tracker, configManager: configManager,
                  sessionManager: sessionManager, navigator: navigator)
    }
    
    convenience init?(product: Product, navigator: ChatDetailNavigator?) {
        guard let _ = product.objectId, sellerId = product.user.objectId else { return nil }

        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let stickersRepository = Core.stickersRepository
        let tracker = TrackerProxy.sharedInstance
        let configManager = ConfigManager.sharedInstance
        let sessionManager = Core.sessionManager

        let amISelling = myUserRepository.myUser?.objectId == sellerId
        let empty = EmptyConversation(objectId: nil, unreadMessageCount: 0, lastMessageSentAt: nil, product: nil,
                                      interlocutor: nil, amISelling: amISelling)
        self.init(conversation: empty, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository ,tracker: tracker, configManager: configManager,
                  sessionManager: sessionManager, navigator: navigator)
        self.setupConversationFromProduct(product)
    }
    
    init(conversation: ChatConversation, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
          productRepository: ProductRepository, userRepository: UserRepository, stickersRepository: StickersRepository,
          tracker: Tracker, configManager: ConfigManager, sessionManager: SessionManager, navigator: ChatDetailNavigator?) {
        self.conversation = Variable<ChatConversation>(conversation)
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.tracker = tracker
        self.configManager = configManager
        self.sessionManager = sessionManager
        self.stickersRepository = stickersRepository
        self.chatViewMessageAdapter = ChatViewMessageAdapter()
        self.navigator = navigator
        super.init()
        setupRx()
        loadStickers()
    }
    
    override func didBecomeActive(firstTime: Bool) {
        refreshChatInfo()
        if firstTime {
            retrieveRelatedProducts()
        }
    }

    func applicationWillEnterForeground() {
        refreshChatInfo()
    }

    private func refreshChatInfo() {
        // only load messages if the interlocutor is not blocked
        guard let interlocutor = conversation.value.interlocutor else { return }
        guard !interlocutor.isBanned else { return }
        retrieveMoreMessages()
        loadStickersTooltip()
        if conversation.value.isSaved && chatEnabled.value {
            delegate?.vmShowKeyboard()
        }
    }

    func wentBack() {
        guard sessionManager.loggedIn else { return }
        guard isBuyer else { return }
        guard !relatedProducts.isEmpty else { return }
        guard let productId = conversation.value.product?.objectId else { return }
        navigator?.openExpressChat(relatedProducts, sourceProductId: productId)
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
            self?.productIsFree.value = conversation.product?.price.free ?? false
            self?.interlocutorAvatarURL.value = conversation.interlocutor?.avatar?.fileURL
            self?.interlocutorName.value = conversation.interlocutor?.name ?? ""
            self?.interlocutorId.value = conversation.interlocutor?.objectId
        }.addDisposableTo(disposeBag)

        chatStatus.asObservable().subscribeNext { [weak self] status in
            guard let strongSelf = self else { return }
            
            if status == .Forbidden {
                let disclaimer = strongSelf.chatViewMessageAdapter.createScammerDisclaimerMessage(
                    isBuyer: strongSelf.isBuyer, userName: strongSelf.conversation.value.interlocutor?.name,
                    action: strongSelf.safetyTipsAction)
                self?.messages.removeAll()
                self?.messages.append(disclaimer)
            }
        }.addDisposableTo(disposeBag)

        relatedProductsEnabled.asObservable().bindNext { [weak self] enabled in
            self?.delegate?.vmShowRelatedProducts(enabled ? self?.conversation.value.product?.objectId : nil)
        }.addDisposableTo(disposeBag)

        let relatedProductsConversation = conversation.asObservable().map { $0.relatedProductsEnabled }
        Observable.combineLatest(relatedProductsConversation, sellerDidntAnswer.asObservable()) { $0 || $1 }
            .bindTo(relatedProductsEnabled).addDisposableTo(disposeBag)

        let cfgManager = configManager
        let myMessagesReviewable = myMessagesCount.asObservable()
            .map { $0 >= cfgManager.myMessagesCountForRating }
            .distinctUntilChanged()
        let otherMessagesReviewable = otherMessagesCount.asObservable()
            .map { $0 >= cfgManager.otherMessagesCountForRating }
            .distinctUntilChanged()
        let chatStatusReviewable = chatStatus.asObservable().map { $0.userReviewEnabled }.distinctUntilChanged()

        Observable.combineLatest(myMessagesReviewable, otherMessagesReviewable, chatStatusReviewable) { $0 && $1 && $2 }
            .bindTo(shouldShowReviewButton).addDisposableTo(disposeBag)

        messages.changesObservable.subscribeNext { [weak self] change in
            self?.updateMessagesCounts(change)
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(stickersTooltipVisible.asObservable(), reviewTooltipVisible.asObservable()) { $0 }
            .subscribeNext { [weak self] (stickersTooltipVisible, reviewTooltipVisible) in
            self?.userReviewTooltipVisible.value = !stickersTooltipVisible && reviewTooltipVisible
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
        chatRepository.wsChatStatus.asObservable().bindNext { [weak self] wsChatStatus in
            switch wsChatStatus {
            case .Closed, .Closing, .Opening, .OpenAuthenticated, .OpenNotAuthenticated:
                break
            case .OpenNotVerified:
                self?.showUserNotVerifiedAlert()
            }
        }.addDisposableTo(disposeBag)

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
            case .AuthenticationTokenExpired:
                break
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
            let data = ProductDetailData.ProductChat(chatProduct: product, user: interlocutor,
                                                     thumbnailImage: nil, originFrame: nil)
            navigator?.openProduct(data, source: .Chat)
        }
    }
    
    func userInfoPressed() {
        guard let interlocutor = conversation.value.interlocutor else { return }
        delegate?.vmHideKeyboard(false)
        let data = UserDetailData.UserChat(user: interlocutor)
        navigator?.openUser(data)
    }

    func reviewUserPressed() {
        KeyValueStorage.sharedInstance[.userRatingTooltipAlreadyShown] = true
        reviewTooltipVisible.value = false
        guard let interlocutor = conversation.value.interlocutor, reviewData = RateUserData(interlocutor: interlocutor)
            else { return }
        delegate?.vmShowUserRating(.Chat, data: reviewData)
    }

    func closeReviewTooltipPressed() {
        KeyValueStorage.sharedInstance[.userRatingTooltipAlreadyShown] = true
        reviewTooltipVisible.value = false
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
        guard chatEnabled.value && stickersTooltipVisible.value else { return }

        var newTextAttributes = [String : AnyObject]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let newText = NSAttributedString(string: LGLocalizedString.commonNew, attributes: newTextAttributes)

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
        stickersTooltipVisible.value = false
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

    private func showUserNotVerifiedAlert() {
        navigator?.openVerifyAccounts([.Facebook, .Google, .Email(myUserRepository.myUser?.email)],
                                         source: .Chat(title: LGLocalizedString.chatConnectAccountsTitle,
                                         description: LGLocalizedString.chatNotVerifiedAlertMessage),
                                         completionBlock: { [weak self] in
                                            self?.navigator?.closeChatDetail()
        })
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
        guard let messageId = newMessage.objectId else { return }
        messages.insert(viewMessage, atIndex: 0)
        chatRepository.sendMessage(convId, messageId: messageId, type: newMessage.type, text: text) {
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
                    self?.showUserNotVerifiedAlert()
                case .Forbidden, .Internal, .Network, .NotFound, .TooManyRequests, .Unauthorized, .ServerError:
                    self?.delegate?.vmDidFailSendingMessage()
                }
            }
            if isQuickAnswer {
                self?.isSendingQuickAnswer = false
            }
        }
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
                case .Forbidden, .Internal, .NotFound, .Unauthorized, .UserNotVerified, .ServerError:
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
        chatRepository.confirmRead(convId, messageIds: [messageId], completion: nil)
        guard isBuyer else { return }
        sellerDidntAnswer.value = false
    }
}


// MARK: - Product Operations

extension ChatViewModel {
    private func markProductAsSold() {
        guard conversation.value.amISelling else { return }
        guard let productId = conversation.value.product?.objectId else { return }
        delegate?.vmShowLoading(nil)
        productRepository.markProductAsSold(productId) { [weak self] result in
            let errorMessage: String? = result.error != nil ? LGLocalizedString.productMarkAsSoldErrorGeneric : nil
            self?.delegate?.vmHideLoading(errorMessage) {
                guard let _ = result.value else { return }
                self?.refreshConversation()
            }
        }
    }
}


// MARK: - Options Menu

extension ChatViewModel {
    
    func openOptionsMenu() {
        var actions: [UIAction] = []
        
        let safetyTips = UIAction(interface: UIActionInterface.Text(LGLocalizedString.chatSafetyTips), action: { [weak self] in
            self?.delegate?.vmShowSafetyTips()
        })
        actions.append(safetyTips)

        if conversation.value.isSaved {
            if directAnswersAvailable {
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
        
        
        let action = UIAction(interface: .StyledText(LGLocalizedString.chatListDeleteAlertSend, .Destructive), action: {
            [weak self] in
            self?.delete() { [weak self] success in
                if success {
                    self?.isDeleted = true
                }
                let message = success ? LGLocalizedString.chatListDeleteOkOne : LGLocalizedString.chatListDeleteErrorOne
                self?.delegate?.vmShowMessage(message) { [weak self] in
                    self?.navigator?.closeChatDetail()
                }
            }
        })
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
        
        let action = UIAction(interface: .StyledText(LGLocalizedString.chatBlockUserAlertBlockButton, .Destructive), action: {
            [weak self] in
            self?.blockUser() { [weak self] success in
                if success {
                    self?.interlocutorIsMuted.value = true
                    self?.refreshConversation()
                } else {
                    self?.delegate?.vmShowMessage(LGLocalizedString.blockUserErrorGeneric, completion: nil)
                }
            }
        })
        
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

    private var bottomDisclaimerMessage: ChatViewMessage? {
        switch chatStatus.value {
        case .UserDeleted, .UserPendingDelete:
            return chatViewMessageAdapter.createUserDeletedDisclaimerMessage(conversation.value.interlocutor?.name)
        case .Available, .Blocked, .BlockedBy, .Forbidden, .ProductDeleted, .ProductSold:
            return nil
        }
    }

    private func downloadFirstPage(conversationId: String) {
        chatRepository.indexMessages(conversationId, numResults: resultsPerPage, offset: 0) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false
            if let value = result.value {
                self?.isLastPage = value.count == 0
                strongSelf.messages.removeAll()
                strongSelf.updateMessages(newMessages: value, isFirstPage: true)
                strongSelf.afterRetrieveChatMessagesEvents()
                strongSelf.checkSellerDidntAnswer(value)
            } else if let _ = result.error {
                strongSelf.delegate?.vmDidFailRetrievingChatMessages()
            }
        }
    }
    
    private func downloadMoreMessages(convId: String, fromMessageId: String) {
        chatRepository.indexMessagesOlderThan(fromMessageId, conversationId: convId, numResults: resultsPerPage) {
            [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false
            if let value = result.value {
                if value.count == 0 {
                    strongSelf.isLastPage = true
                }
                strongSelf.updateMessages(newMessages: value, isFirstPage: false)
            } else if let _ = result.error {
                strongSelf.delegate?.vmDidFailRetrievingChatMessages()
            }
        }
    }

    private func markAsReadMessages(chatMessages: [ChatMessage] ) {
        guard let convId = conversation.value.objectId else { return }
        guard let interlocutorId = conversation.value.interlocutor?.objectId else { return }

        let readIds: [String] = chatMessages.filter { return $0.talkerId == interlocutorId && $0.readAt == nil }
            .flatMap { $0.objectId }
        if !readIds.isEmpty {
            chatRepository.confirmRead(convId, messageIds: readIds, completion: nil)
        }
    }

    private func updateMessages(newMessages newMessages: [ChatMessage], isFirstPage: Bool) {
        // Mark as read
        markAsReadMessages(newMessages)

        // Add message disclaimer (message flagged)
        let mappedChatMessages = newMessages.map(chatViewMessageAdapter.adapt)
        var chatMessages = chatViewMessageAdapter.addDisclaimers(mappedChatMessages,
                                                                 disclaimerMessage: defaultDisclaimerMessage)
        // Add user info as 1st message
        if let userInfoMessage = userInfoMessage where isLastPage {
            chatMessages.append(userInfoMessage)
        }
        // Add disclaimer at the bottom of the first page
        if let bottomDisclaimerMessage = bottomDisclaimerMessage where isFirstPage {
            chatMessages.insert(bottomDisclaimerMessage, atIndex: 0)
        }
        messages.appendContentsOf(chatMessages)
    }

    private func afterRetrieveChatMessagesEvents() {
        if shouldShowSafetyTips {
            delegate?.vmShowSafetyTips()
        }

        afterRetrieveMessagesCompletion?()
    }

    private func checkSellerDidntAnswer(messages: [ChatMessage]) {
        guard isBuyer else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        guard let oldestMessageDate = messages.last?.sentAt else { return }

        let calendar = NSCalendar.currentCalendar()

        guard let twoDaysAgo = calendar.dateByAddingUnit(.Day, value: -2, toDate: NSDate(), options: []) else { return }
        let recentSellerMessages = messages.filter { $0.talkerId != myUserId && $0.sentAt?.compare(twoDaysAgo) == .OrderedDescending }

        /*
         Cases when we consider the seller didn't answer:
         - Seller didn't answer in the last 48h (recentSellerMessages is empty)
         AND either:
            - the oldest message in the first page is also from more than 48h ago (oldestMessageDate > twoDaysAgo)
            OR:
            - the first page is full (this case covers the super eager buyer who sent 20 messages in less than 48h and
            didn't got any answer. We show him the related items too)
         */
        sellerDidntAnswer.value = recentSellerMessages.isEmpty &&
            (oldestMessageDate.compare(twoDaysAgo) == .OrderedAscending || messages.count == Constants.numMessagesPerPage)
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
                guard let strongSelf = self else { return }
                strongSelf.preSendMessageCompletion = nil
                guard sellerId != strongSelf.myUserRepository.myUser?.objectId else {
                    //A user cannot have a conversation with himself
                    strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.chatWithYourselfAlertMsg) {
                        [weak self] in
                        self?.navigator?.closeChatDetail()
                    }
                    return
                }
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
        guard let product = conversation.value.product else { return }
        guard let userId = conversation.value.interlocutor?.objectId else { return }

        let sellerRating = conversation.value.amISelling ?
            myUserRepository.myUser?.ratingAverage : interlocutor?.ratingAverage
        let askQuestionEvent = TrackerEvent.productAskQuestion(product, messageType: type.trackingMessageType,
                                                               interlocutorId: userId, typePage: .Chat,
                                                               sellerRating: sellerRating)
        TrackerProxy.sharedInstance.trackEvent(askQuestionEvent)
    }

    private func trackMessageSent(isQuickAnswer: Bool, type: ChatMessageType) {
        guard let product = conversation.value.product else { return }
        guard let userId = conversation.value.interlocutor?.objectId else { return }
        let messageSentEvent = TrackerEvent.userMessageSent(product, userToId: userId,
                                                            messageType: type.trackingMessageType,
                                                            isQuickAnswer: isQuickAnswer ? .True : .False, typePage: .Chat)
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

    var relatedProductsEnabled: Bool {
        switch chatStatus {
        case .Forbidden,  .UserPendingDelete, .UserDeleted, .ProductDeleted, .ProductSold:
            return !amISelling
        case .Available, .Blocked, .BlockedBy:
            return false
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
        if FeatureFlags.freePostingMode.enabled && productIsFree.value {
            if !conversation.value.amISelling {
                return [DirectAnswer(text: LGLocalizedString.directAnswerInterested, action: emptyAction),
                        DirectAnswer(text: LGLocalizedString.directAnswerFreeStillHave, action: emptyAction),
                        DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: emptyAction),
                        DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction)]
            } else {
                return [DirectAnswer(text: LGLocalizedString.directAnswerFreeYours, action: emptyAction),
                        DirectAnswer(text: LGLocalizedString.directAnswerFreeAvailable, action: emptyAction),
                        DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: emptyAction),
                        DirectAnswer(text: LGLocalizedString.directAnswerFreeNoAvailable, action: emptyAction)]
            }
        } else {
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


// MARK: - Related products

extension ChatViewModel: RelatedProductsViewDelegate {

    func relatedProductsViewDidShow(view: RelatedProductsView) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus.value)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsStart(relatedShownReason))
    }

    func relatedProductsView(view: RelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus.value)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsComplete(index, shownReason: relatedShownReason))
        let data = ProductDetailData.ProductList(product: product, cellModels: productListModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        navigator?.openProduct(data, source: .Chat)
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

// MARK: - Related products for express chat

extension ChatViewModel {

    static let maxRelatedProductsForExpressChat = 4

    private func retrieveRelatedProducts() {
        guard isBuyer else { return }
        guard let productId = conversation.value.product?.objectId else { return }
        productRepository.indexRelated(productId: productId, params: RetrieveProductsParams()) { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.relatedProducts = strongSelf.relatedWithoutMyProducts(value)
            }
        }
    }

    private func relatedWithoutMyProducts(products: [Product]) -> [Product] {
        var cleanRelatedProducts: [Product] = []
        for product in products {
            if product.user.objectId != myUserRepository.myUser?.objectId { cleanRelatedProducts.append(product) }
            if cleanRelatedProducts.count == OldChatViewModel.maxRelatedProductsForExpressChat {
                return cleanRelatedProducts
            }
        }
        return cleanRelatedProducts
    }
}
