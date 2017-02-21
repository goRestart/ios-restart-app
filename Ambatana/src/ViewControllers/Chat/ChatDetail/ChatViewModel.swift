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
    func vmShowRelatedProducts(_ productId: String?)

    func vmDidFailSendingMessage()
    func vmDidFailRetrievingChatMessages()
    
    func vmShowReportUser(_ reportUserViewModel: ReportUsersViewModel)
    func vmShowUserRating(_ source: RateUserSource, data: RateUserData)

    func vmShowSafetyTips()

    func vmClearText()
    func vmHideKeyboard(_ animated: Bool)
    func vmShowKeyboard()
    
    func vmAskForRating()
    func vmShowPrePermissions(_ type: PrePermissionType)
    func vmShowMessage(_ message: String, completion: (() -> ())?)
    func vmLoadStickersTooltipWithText(_ text: NSAttributedString)
}

struct EmptyConversation: ChatConversation {
    var objectId: String?
    var unreadMessageCount: Int = 0
    var lastMessageSentAt: Date? = nil
    var product: ChatProduct? = nil
    var interlocutor: ChatInterlocutor? = nil
    var amISelling: Bool 
}

enum ChatRelatedItemsState {
    case loading, visible, hidden
}

enum DirectAnswersState {
    case notAvailable, visible, hidden
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
    let title = Variable<String>("")
    let productName = Variable<String>("")
    let productImageUrl = Variable<URL?>(nil)
    let productPrice = Variable<String>("")
    let productIsFree = Variable<Bool>(false)
    let interlocutorAvatarURL = Variable<URL?>(nil)
    let interlocutorName = Variable<String>("")
    let interlocutorId = Variable<String?>(nil)
    let stickers = Variable<[Sticker]>([])
    let chatStatus = Variable<ChatInfoViewStatus>(.available)
    let chatEnabled = Variable<Bool>(true)
    let directAnswersState = Variable<DirectAnswersState>(.notAvailable)
    let interlocutorTyping = Variable<Bool>(false)
    let messages = CollectionVariable<ChatViewMessage>([])
    let shouldShowReviewButton = Variable<Bool>(false)
    let userReviewTooltipVisible = Variable<Bool>(false)

    var relatedProducts: [Product] = []
    var shouldTrackFirstMessage: Bool = false
    let shouldShowExpressBanner = Variable<Bool>(false)

    var keyForTextCaching: String { return userDefaultsSubKey }

    
    // fileprivate
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let chatRepository: ChatRepository
    fileprivate let productRepository: ProductRepository
    fileprivate let userRepository: UserRepository
    fileprivate let stickersRepository: StickersRepository
    fileprivate let chatViewMessageAdapter: ChatViewMessageAdapter
    fileprivate let tracker: Tracker
    fileprivate let configManager: ConfigManager
    fileprivate let sessionManager: SessionManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let source: EventParameterTypePage
    
    fileprivate let keyValueStorage: KeyValueStorage

    fileprivate let firstInteractionDone = Variable<Bool>(false)
    fileprivate let expressBannerTimerFinished = Variable<Bool>(false)
    fileprivate let hasRelatedProducts = Variable<Bool>(false)
    fileprivate let expressMessagesAlreadySent = Variable<Bool>(false)
    fileprivate let interlocutorIsMuted = Variable<Bool>(false)
    private let interlocutorHasMutedYou = Variable<Bool>(false)
    private let relatedProductsState = Variable<ChatRelatedItemsState>(.loading)
    fileprivate let sellerDidntAnswer = Variable<Bool?>(nil)
    fileprivate let conversation: Variable<ChatConversation>
    fileprivate var interlocutor: User?
    private let myMessagesCount = Variable<Int>(0)
    private let otherMessagesCount = Variable<Int>(0)
    fileprivate let isEmptyConversation = Variable<Bool>(true)
    private let stickersTooltipVisible = Variable<Bool>(!KeyValueStorage.sharedInstance[.stickersTooltipAlreadyShown])
    private let reviewTooltipVisible = Variable<Bool>(!KeyValueStorage.sharedInstance[.userRatingTooltipAlreadyShown])
    fileprivate let userDirectAnswersEnabled = Variable<Bool>(false)

    fileprivate var isDeleted = false
    fileprivate var shouldAskProductSold: Bool = false
    fileprivate var productId: String? // Only used when accessing a chat from a product
    fileprivate var preSendMessageCompletion: ((_ type: ChatWrapperMessageType) -> Void)?
    fileprivate var afterRetrieveMessagesCompletion: (() -> Void)?

    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var userDefaultsSubKey: String {
        return "\(conversation.value.product?.objectId ?? productId) + \(buyerId ?? "offline")"
    }

    fileprivate var isBuyer: Bool {
        return !conversation.value.amISelling
    }

    fileprivate var shouldShowOtherUserInfo: Bool {
        guard conversation.value.isSaved else { return true }
        return !isLoading && isLastPage
    }

    fileprivate var safetyTipsAction: () -> Void {
        return { [weak self] in
            self?.delegate?.vmShowSafetyTips()
        }
    }

    fileprivate var buyerId: String? {
        let myUserId = myUserRepository.myUser?.objectId
        let interlocutorId = conversation.value.interlocutor?.objectId
        let currentBuyer = conversation.value.amISelling ? interlocutorId : myUserId
        return currentBuyer
    }

    fileprivate var shouldShowSafetyTips: Bool {
        return !keyValueStorage.userChatSafetyTipsShown && didReceiveMessageFromOtherUser
    }

    fileprivate var didReceiveMessageFromOtherUser: Bool {
        for message in messages.value {
            if message.talkerId == conversation.value.interlocutor?.objectId {
                return true
            }
        }
        return false
    }

    fileprivate var interlocutorEnabled: Bool {
        switch chatStatus.value {
        case .forbidden, .userDeleted, .userPendingDelete:
            return false
        case .available, .productSold, .productDeleted, .blocked, .blockedBy:
            return true
        }
    }

    convenience init(conversation: ChatConversation, navigator: ChatDetailNavigator?, source: EventParameterTypePage) {
        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        let stickersRepository = Core.stickersRepository
        let configManager = ConfigManager.sharedInstance
        let sessionManager = Core.sessionManager
        let featureFlags = FeatureFlags.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance

        self.init(conversation: conversation, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository, tracker: tracker, configManager: configManager,
                  sessionManager: sessionManager, keyValueStorage: keyValueStorage, navigator: navigator, featureFlags: featureFlags,
                  source: source)
    }
    
    convenience init?(product: Product, navigator: ChatDetailNavigator?, source: EventParameterTypePage) {
        guard let _ = product.objectId, let sellerId = product.user.objectId else { return nil }

        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let stickersRepository = Core.stickersRepository
        let tracker = TrackerProxy.sharedInstance
        let configManager = ConfigManager.sharedInstance
        let sessionManager = Core.sessionManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let amISelling = myUserRepository.myUser?.objectId == sellerId
        let empty = EmptyConversation(objectId: nil, unreadMessageCount: 0, lastMessageSentAt: nil, product: nil,
                                      interlocutor: nil, amISelling: amISelling)
        self.init(conversation: empty, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository ,tracker: tracker, configManager: configManager,
                  sessionManager: sessionManager, keyValueStorage: keyValueStorage, navigator: navigator, featureFlags: featureFlags,
                  source: source)
        self.setupConversationFromProduct(product)
    }
    
    init(conversation: ChatConversation, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
          productRepository: ProductRepository, userRepository: UserRepository, stickersRepository: StickersRepository,
          tracker: Tracker, configManager: ConfigManager, sessionManager: SessionManager, keyValueStorage: KeyValueStorage,
          navigator: ChatDetailNavigator?, featureFlags: FeatureFlaggeable, source: EventParameterTypePage) {
        self.conversation = Variable<ChatConversation>(conversation)
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.configManager = configManager
        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage

        self.stickersRepository = stickersRepository
        self.chatViewMessageAdapter = ChatViewMessageAdapter()
        self.navigator = navigator
        self.source = source
        super.init()
        setupRx()
        loadStickers()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            retrieveRelatedProducts()
            setupExpressChat()
        }

        refreshChatInfo()
        trackVisit()
    }

    func didAppear() {
        if conversation.value.isSaved && chatEnabled.value {
            delegate?.vmShowKeyboard()
        }
    }

    private func refreshChatInfo() {
        // only load messages if the interlocutor is not blocked
        // Note: In some corner cases (staging only atm) the interlocutor may come as nil
        if let interlocutor = conversation.value.interlocutor, interlocutor.isBanned { return }
        retrieveMoreMessages()
        loadStickersTooltip()
    }

    func wentBack() {
        guard sessionManager.loggedIn else { return }
        guard isBuyer else { return }
        guard !relatedProducts.isEmpty else { return }
        guard let productId = conversation.value.product?.objectId else { return }
        navigator?.openExpressChat(relatedProducts, sourceProductId: productId, manualOpen: false)
    }

    func setupConversationFromProduct(_ product: Product) {
        guard let productId = product.objectId, let sellerId = product.user.objectId else { return }
        if let _ =  myUserRepository.myUser?.objectId {
            syncConversation(productId, sellerId: sellerId)
        } else {
            setupNotLoggedIn(product)
        }
    }

    func syncConversation(_ productId: String, sellerId: String) {
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
            
            if status == .forbidden {
                let disclaimer = strongSelf.chatViewMessageAdapter.createScammerDisclaimerMessage(
                    isBuyer: strongSelf.isBuyer, userName: strongSelf.conversation.value.interlocutor?.name,
                    action: strongSelf.safetyTipsAction)
                self?.messages.removeAll()
                self?.messages.append(disclaimer)
            }
        }.addDisposableTo(disposeBag)

        relatedProductsState.asObservable().bindNext { [weak self] state in
            switch state {
            case .loading, .hidden:
                self?.delegate?.vmShowRelatedProducts(nil)
            case .visible:
                self?.delegate?.vmShowRelatedProducts(self?.conversation.value.product?.objectId)
            }
        }.addDisposableTo(disposeBag)

        let relatedProductsConversation = conversation.asObservable().map { $0.relatedProductsEnabled }
        Observable.combineLatest(relatedProductsConversation, sellerDidntAnswer.asObservable()) { [weak self] in
            guard let strongSelf = self else { return .loading }
            guard strongSelf.isBuyer else { return .hidden } // Seller doesn't have related products
            if $0 { return .visible }
            guard let didntAnswer = $1 else { return .loading } // If still checking if seller didn't answer. set loading state
            return didntAnswer ? .visible : .hidden
        }.bindTo(relatedProductsState).addDisposableTo(disposeBag)

        let cfgManager = configManager
        let myMessagesReviewable = myMessagesCount.asObservable().map { $0 >= cfgManager.myMessagesCountForRating }
        let otherMessagesReviewable = otherMessagesCount.asObservable().map { $0 >= cfgManager.otherMessagesCountForRating }
        let chatStatusReviewable = chatStatus.asObservable().map { $0.userReviewEnabled }
        Observable.combineLatest(myMessagesReviewable, otherMessagesReviewable, chatStatusReviewable) { $0 && $1 && $2 }
            .distinctUntilChanged().bindTo(shouldShowReviewButton).addDisposableTo(disposeBag)

        messages.changesObservable.subscribeNext { [weak self] change in
            self?.updateMessagesCounts(change)
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(stickersTooltipVisible.asObservable(), reviewTooltipVisible.asObservable()) { $0 }
            .subscribeNext { [weak self] (stickersTooltipVisible, reviewTooltipVisible) in
            self?.userReviewTooltipVisible.value = !stickersTooltipVisible && reviewTooltipVisible
        }.addDisposableTo(disposeBag)
        
        conversation.asObservable().map{ $0.lastMessageSentAt == nil }.bindNext{ [weak self] result in
            self?.shouldTrackFirstMessage = result
        }.addDisposableTo(disposeBag)

        let emptyMyMessages = myMessagesCount.asObservable().map { $0 == 0 }
        let emptyOtherMessages = otherMessagesCount.asObservable().map { $0 == 0 }
        Observable.combineLatest(emptyMyMessages, emptyOtherMessages){ $0 && $1 }.distinctUntilChanged()
            .bindTo(isEmptyConversation).addDisposableTo(disposeBag)

        let expressBannerTriggered = Observable.combineLatest(firstInteractionDone.asObservable(),
                                                              expressBannerTimerFinished.asObservable()) { $0 || $1 }
        /**
            Express chat banner is shown after 3 seconds or 1st interaction if:
                - the product has related products
                - we're not showing the related products already over the keyboard
                - user hasn't SENT messages via express chat for this product
         */
        Observable.combineLatest(expressBannerTriggered,
            hasRelatedProducts.asObservable(),
            relatedProductsState.asObservable().map { $0 == .visible },
        expressMessagesAlreadySent.asObservable()) { $0 && $1 && !$2 && !$3 }
            .distinctUntilChanged().bindTo(shouldShowExpressBanner).addDisposableTo(disposeBag)

        userDirectAnswersEnabled.value = keyValueStorage.userLoadChatShowDirectAnswersForKey(userDefaultsSubKey)

        let directAnswers: Observable<DirectAnswersState> = Observable.combineLatest(chatEnabled.asObservable(),
                                        relatedProductsState.asObservable(),
                                        userDirectAnswersEnabled.asObservable(),
                                        resultSelector: { chatEnabled, relatedState, directAnswers in
                                            switch relatedState {
                                            case .loading, .visible:
                                                return .notAvailable
                                            case .hidden:
                                                guard chatEnabled else { return .notAvailable }
                                                return directAnswers ? .visible : .hidden
                                            }
                                        }).distinctUntilChanged()
        directAnswers.bindTo(directAnswersState).addDisposableTo(disposeBag)

        interlocutorId.asObservable().bindNext { [weak self] interlocutorId in
            guard let interlocutorId = interlocutorId, self?.interlocutor?.objectId != interlocutorId else { return }
            self?.userRepository.show(interlocutorId) { [weak self] result in
                guard let strongSelf = self else { return }
                guard let user = result.value else { return }
                strongSelf.interlocutor = user
                if let userInfoMessage = strongSelf.userInfoMessage, strongSelf.shouldShowOtherUserInfo {
                    strongSelf.messages.append(userInfoMessage)
                }
            }
        }.addDisposableTo(disposeBag)

        setupChatEventsRx()
    }


    func updateMessagesCounts(_ changeInMessages: CollectionChange<ChatViewMessage>) {
        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        guard let otherUserId = conversation.value.interlocutor?.objectId else { return }

        switch changeInMessages {
        case let .remove(_, message):
            if message.talkerId == myUserId {
                myMessagesCount.value = max(0, myMessagesCount.value-1)
            } else if message.talkerId == otherUserId {
                otherMessagesCount.value = max(0, otherMessagesCount.value-1)
            }
        case let .insert(_, message):
            if message.talkerId == myUserId {
                myMessagesCount.value += 1
            } else if message.talkerId == otherUserId {
                otherMessagesCount.value += 1
            }
        case let .composite(changes):
            changes.forEach { [weak self] change in
                self?.updateMessagesCounts(change)
            }
        }
    }

    func setupChatEventsRx() {
        chatRepository.chatStatus.bindNext { [weak self] wsChatStatus in
            switch wsChatStatus {
            case .openAuthenticated:
                //Reload messages
                break

            case .openNotVerified:
                self?.showUserNotVerifiedAlert()
            case .closed, .closing, .opening, .openNotAuthenticated:
                break
            }
        }.addDisposableTo(disposeBag)

        guard let convId = conversation.value.objectId else { return }
        chatRepository.chatEventsIn(convId).subscribeNext { [weak self] event in
            switch event.type {
            case let .interlocutorMessageSent(messageId, sentAt, text, type):
                self?.handleNewMessageFromInterlocutor(messageId, sentAt: sentAt, text: text, type: type)
            case let .interlocutorReadConfirmed(messagesIds):
                self?.markMessagesAsRead(messagesIds)
            case let .interlocutorReceptionConfirmed(messagesIds):
                self?.markMessagesAsReceived(messagesIds)
            case .interlocutorTypingStarted:
                self?.interlocutorTyping.value = true
            case .interlocutorTypingStopped:
                self?.interlocutorTyping.value = false
            case .authenticationTokenExpired:
                break
            }
        }.addDisposableTo(disposeBag)
    }

    
    // MARK: - Public Methods
    
    func productInfoPressed() {
        guard let product = conversation.value.product else { return }
        switch product.status {
        case .deleted:
            break
        case .pending, .approved, .discarded, .sold, .soldOld:
            delegate?.vmHideKeyboard(false)
            let data = ProductDetailData.productChat(chatConversation: conversation.value)
            navigator?.openProduct(data, source: .chat, showKeyboardOnFirstAppearIfNeeded: false)
        }
    }
    
    func userInfoPressed() {
        guard let interlocutor = conversation.value.interlocutor else { return }
        let data = UserDetailData.userChat(user: interlocutor)
        navigator?.openUser(data)
    }

    func reviewUserPressed() {
        keyValueStorage[.userRatingTooltipAlreadyShown] = true
        reviewTooltipVisible.value = false
        guard let interlocutor = conversation.value.interlocutor, let reviewData = RateUserData(interlocutor: interlocutor)
            else { return }
        delegate?.vmShowUserRating(.chat, data: reviewData)
    }

    func closeReviewTooltipPressed() {
        keyValueStorage[.userRatingTooltipAlreadyShown] = true
        reviewTooltipVisible.value = false
    }

    func safetyTipsDismissed() {
        keyValueStorage.userChatSafetyTipsShown = true
    }

    func messageAtIndex(_ index: Int) -> ChatViewMessage? {
        guard 0..<messages.value.count ~= index else { return nil }
        return messages.value[index]
    }
    
    func textOfMessageAtIndex(_ index: Int) -> String? {
        return messageAtIndex(index)?.value
    }

    func loadStickersTooltip() {
        guard chatEnabled.value && stickersTooltipVisible.value else { return }

        var newTextAttributes = [String : Any]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let newText = NSAttributedString(string: LGLocalizedString.commonNew, attributes: newTextAttributes)

        var titleTextAttributes = [String : Any]()
        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.white
        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let titleText = NSAttributedString(string: LGLocalizedString.chatStickersTooltipAddStickers, attributes: titleTextAttributes)

        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.append(NSAttributedString(string: " "))
        fullTitle.append(titleText)

        delegate?.vmLoadStickersTooltipWithText(fullTitle)
    }

    func stickersShown() {
        keyValueStorage[.stickersTooltipAlreadyShown] = true
        stickersTooltipVisible.value = false
    }

    func bannerActionButtonTapped() {
        guard let productId = conversation.value.product?.objectId else { return }
        navigator?.openExpressChat(relatedProducts, sourceProductId: productId, manualOpen: true)
    }

    func directAnswersButtonPressed() {
        toggleDirectAnswers()
    }
}


// MARK: - Private methods

extension ChatViewModel {
    
    func isMatchingConversationData(_ data: ConversationData) -> Bool {
        switch data {
        case .conversation(let conversationId):
            return conversationId == conversation.value.objectId
        case let .productBuyer(productId, productBuyerId):
            return productId == conversation.value.product?.objectId && productBuyerId == buyerId
        }
    }

    fileprivate func showUserNotVerifiedAlert() {
        navigator?.openVerifyAccounts([.facebook, .google, .email(myUserRepository.myUser?.email)],
                                         source: .chat(title: LGLocalizedString.chatConnectAccountsTitle,
                                         description: LGLocalizedString.chatNotVerifiedAlertMessage),
                                         completionBlock: { [weak self] in
                                            self?.navigator?.closeChatDetail()
        })
    }
}


// MARK: - Message operations

extension ChatViewModel {
    
    func send(sticker: Sticker) {
        sendMessage(type: .chatSticker(sticker))
    }
    
    func send(text: String) {
        sendMessage(type: .text(text))
    }

    func send(quickAnswer: QuickAnswer) {
        sendMessage(type: .quickAnswer(quickAnswer))
    }
    
    fileprivate func sendMessage(type: ChatWrapperMessageType) {
        if let preSendMessageCompletion = preSendMessageCompletion {
            preSendMessageCompletion(type)
            return
        }

        let message = type.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard message.characters.count > 0 else { return }
        guard let convId = conversation.value.objectId else { return }
        guard let userId = myUserRepository.myUser?.objectId else { return }
        
        if type.isUserText {
            delegate?.vmClearText()
        }

        let newMessage = chatRepository.createNewMessage(userId, text: message, type: type.chatType)
        let viewMessage = chatViewMessageAdapter.adapt(newMessage).markAsSent()
        guard let messageId = newMessage.objectId else { return }
        messages.insert(viewMessage, atIndex: 0)
        chatRepository.sendMessage(convId, messageId: messageId, type: newMessage.type, text: message) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                strongSelf.markMessageAsSent(messageId)
                strongSelf.afterSendMessageEvents()
                strongSelf.trackMessageSent(type: type)
            } else if let error = result.error {
                // Removing message until we implement the retry-message state behavior
                strongSelf.removeMessage(messageId: messageId)
                switch error {
                case .userNotVerified:
                    self?.showUserNotVerifiedAlert()
                case .forbidden, .internalError, .network, .notFound, .tooManyRequests, .unauthorized, .serverError:
                    self?.delegate?.vmDidFailSendingMessage()
                }
            }
        }
    }

    private func afterSendMessageEvents() {
        firstInteractionDone.value = true
        if shouldAskProductSold {
            shouldAskProductSold = false
            let action = UIAction(interface: UIActionInterface.text(LGLocalizedString.directAnswerSoldQuestionOk),
                                  action: { [weak self] in self?.markProductAsSold() })
            delegate?.vmShowAlert(LGLocalizedString.directAnswerSoldQuestionTitle,
                                  message: LGLocalizedString.directAnswerSoldQuestionMessage,
                                  cancelLabel: LGLocalizedString.commonCancel,
                                  actions: [action])
        } else if PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.chat(buyer: isBuyer)) {
            delegate?.vmShowPrePermissions(.chat(buyer: isBuyer))
        } else if RatingManager.sharedInstance.shouldShowRating {
            delegate?.vmAskForRating()
        }
    }

    private func resendEmailVerification(_ email: String) {
        myUserRepository.linkAccount(email) { [weak self] result in
            if let error = result.error {
                switch error {
                case .tooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailTooManyRequests, completion: nil)
                case .network:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorNetworkBody, completion: nil)
                case .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified, .serverError:
                    self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.commonErrorGenericBody, completion: nil)
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.profileVerifyEmailSuccess, completion: nil)
            }
        }
    }

    private func markMessageAsSent(_ messageId: String) {
        updateMessageWithAction(messageId) { $0.markAsSent() }
    }
    
    fileprivate func markMessagesAsReceived(_ messagesIds: [String]) {
        messagesIds.forEach { [weak self] messageId in
            self?.updateMessageWithAction(messageId) { $0.markAsReceived() }
        }
    }
    
    fileprivate func markMessagesAsRead(_ messagesIds: [String]) {
        messagesIds.forEach { [weak self] messageId in
            self?.updateMessageWithAction(messageId) { $0.markAsRead() }
        }
    }
    
    private func updateMessageWithAction(_ messageId: String, action: (ChatViewMessage) -> ChatViewMessage) {
        guard let index = messages.value.index(where: {$0.objectId == messageId}) else { return }
        let message = messages.value[index]
        let newMessage = action(message)
        let range = index..<(index+1)
        messages.replace(range, with: [newMessage])
    }

    private func removeMessage(messageId: String) {
        guard let index = messages.value.index(where: {$0.objectId == messageId}) else { return }
        messages.removeAtIndex(index)
    }

    fileprivate func handleNewMessageFromInterlocutor(_ messageId: String, sentAt: Date, text: String, type: ChatMessageType) {
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
    fileprivate func markProductAsSold() {
        guard conversation.value.amISelling else { return }
        guard let productId = conversation.value.product?.objectId else { return }
        guard featureFlags.userRatingMarkAsSold else {
            markProductAsSold(productId: productId, buyerId: nil, userSoldTo: nil)
            return
        }
        delegate?.vmShowLoading(nil)
        productRepository.possibleBuyersOf(productId: productId) { [weak self] result in
            if let buyers = result.value, !buyers.isEmpty {
                self?.delegate?.vmHideLoading(nil) {
                    self?.navigator?.selectBuyerToRate(source: .chat, buyers: buyers) { buyerId in
                        let userSoldTo: EventParameterUserSoldTo = buyerId != nil ? .letgoUser : .outsideLetgo
                        self?.markProductAsSold(productId: productId, buyerId: buyerId, userSoldTo: userSoldTo)
                    }
                }
            } else {
                self?.markProductAsSold(productId: productId, buyerId: nil, userSoldTo: .noConversations)
            }
        }
    }

    private func markProductAsSold(productId: String, buyerId: String?, userSoldTo: EventParameterUserSoldTo?) {
        delegate?.vmShowLoading(nil)
        productRepository.markProductAsSold(productId, buyerId: nil) { [weak self] result in
            if let _ = result.value {
                self?.trackMarkAsSold(userSoldTo: userSoldTo)
            }
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
        
        let safetyTips = UIAction(interface: UIActionInterface.text(LGLocalizedString.chatSafetyTips), action: { [weak self] in
            self?.delegate?.vmShowSafetyTips()
        })
        actions.append(safetyTips)

        if conversation.value.isSaved {
            if directAnswersState.value != .notAvailable {
                let visible = directAnswersState.value == .visible
                let directAnswersText = visible ? LGLocalizedString.directAnswersHide : LGLocalizedString.directAnswersShow
                let directAnswersAction = UIAction(interface: UIActionInterface.text(directAnswersText),
                                                   action: toggleDirectAnswers)
                actions.append(directAnswersAction)
            }
            
            if !isDeleted && !isEmptyConversation.value {
                let delete = UIAction(interface: UIActionInterface.text(LGLocalizedString.chatListDelete),
                                                   action: deleteAction)
                actions.append(delete)
            }

            if interlocutorEnabled {
                let report = UIAction(interface: UIActionInterface.text(LGLocalizedString.reportUserTitle),
                                      action: reportUserAction)
                actions.append(report)
              
                if interlocutorIsMuted.value {
                    let unblock = UIAction(interface: UIActionInterface.text(LGLocalizedString.chatUnblockUser),
                                          action: unblockUserAction)
                    actions.append(unblock)
                } else {
                    let block = UIAction(interface: UIActionInterface.text(LGLocalizedString.chatBlockUser),
                                           action: blockUserAction)
                    actions.append(block)
                }
            }
        }
        
        delegate?.vmShowActionSheet(LGLocalizedString.commonCancel, actions: actions)
    }
    
    private func deleteAction() {
        guard !isDeleted else { return }
        
        
        let action = UIAction(interface: .styledText(LGLocalizedString.chatListDeleteAlertSend, .destructive), action: {
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
    
    private func delete(_ completion: @escaping (_ success: Bool) -> ()) {
        guard let chatId = conversation.value.objectId else {
            completion(false)
            return
        }
        self.chatRepository.archiveConversations([chatId]) { result in
            completion(result.value != nil)
        }
    }
    
    private func reportUserAction() {
        guard let userID = conversation.value.interlocutor?.objectId else { return }
        let reportVM = ReportUsersViewModel(origin: .chat, userReportedId: userID)
        delegate?.vmShowReportUser(reportVM)
    }
    
    private func blockUserAction() {
        
        let action = UIAction(interface: .styledText(LGLocalizedString.chatBlockUserAlertBlockButton, .destructive), action: {
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
    
    private func blockUser(_ completion: @escaping (_ success: Bool) -> ()) {
        
        guard let userId = conversation.value.interlocutor?.objectId else {
            completion(false)
            return
        }
        
        trackBlockUsers([userId])
        
        self.userRepository.blockUserWithId(userId) { result -> Void in
            completion(result.value != nil)
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
    
    private func unBlockUser(_ completion: @escaping (_ success: Bool) -> ()) {
        guard let userId = conversation.value.interlocutor?.objectId else {
            completion(false)
            return
        }
        
        trackUnblockUsers([userId])
        
        self.userRepository.unblockUserWithId(userId) { result -> Void in
            completion(result.value != nil)
        }
    }
}


// MARK: - Paginable

extension ChatViewModel {
    
    func setCurrentIndex(_ index: Int) {
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
        case .userDeleted, .userPendingDelete:
            return chatViewMessageAdapter.createUserDeletedDisclaimerMessage(conversation.value.interlocutor?.name)
        case .available, .blocked, .blockedBy, .forbidden, .productDeleted, .productSold:
            return nil
        }
    }

    private func downloadFirstPage(_ conversationId: String) {
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
    
    private func downloadMoreMessages(_ convId: String, fromMessageId: String) {
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

    private func markAsReadMessages(_ chatMessages: [ChatMessage] ) {
        guard let convId = conversation.value.objectId else { return }
        guard let interlocutorId = conversation.value.interlocutor?.objectId else { return }

        let readIds: [String] = chatMessages.filter { return $0.talkerId == interlocutorId && $0.readAt == nil }
            .flatMap { $0.objectId }
        if !readIds.isEmpty {
            chatRepository.confirmRead(convId, messageIds: readIds, completion: nil)
        }
    }

    private func updateMessages(newMessages: [ChatMessage], isFirstPage: Bool) {
        // Mark as read
        markAsReadMessages(newMessages)

        // Add message disclaimer (message flagged)
        let mappedChatMessages = newMessages.map(chatViewMessageAdapter.adapt)
        var chatMessages = chatViewMessageAdapter.addDisclaimers(mappedChatMessages,
                                                                 disclaimerMessage: defaultDisclaimerMessage)
        // Add user info as 1st message
        if let userInfoMessage = userInfoMessage, isLastPage {
            chatMessages.append(userInfoMessage)
        }
        // Add disclaimer at the bottom of the first page
        if let bottomDisclaimerMessage = bottomDisclaimerMessage, isFirstPage {
            chatMessages.insert(bottomDisclaimerMessage, at: 0)
        }
        messages.appendContentsOf(chatMessages)
    }

    private func afterRetrieveChatMessagesEvents() {
        if shouldShowSafetyTips {
            delegate?.vmShowSafetyTips()
        }

        afterRetrieveMessagesCompletion?()
    }

    private func checkSellerDidntAnswer(_ messages: [ChatMessage]) {
        guard isBuyer else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        guard let oldestMessageDate = messages.last?.sentAt else { return }

        let calendar = Calendar.current

        guard let twoDaysAgo = (calendar as NSCalendar).date(byAdding: .day, value: -2, to: Date(), options: []) else { return }
        let recentSellerMessages = messages.filter { $0.talkerId != myUserId && $0.sentAt?.compare(twoDaysAgo) == .orderedDescending }

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
            (oldestMessageDate.compare(twoDaysAgo) == .orderedAscending || messages.count == Constants.numMessagesPerPage)
    }

    private func checkShouldShowDirectAnswers(_ messages: [ChatMessage]) {
        // If there's no previous message from me, we should show direct answers
        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        for message in messages {
            guard message.talkerId != myUserId else { return }
        }
        userDirectAnswersEnabled.value = true
    }
}


// MARK: - Second step login

fileprivate extension ChatViewModel {
    func setupNotLoggedIn(_ product: Product) {
        guard let productId = product.objectId, let sellerId = product.user.objectId else { return }
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
        preSendMessageCompletion = { [weak self] (type: ChatWrapperMessageType) in
            self?.delegate?.vmHideKeyboard(false)
            self?.navigator?.openLoginIfNeededFromChatDetail(from: .askQuestion, loggedInAction: { [weak self] in
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
                    guard let messages = self?.messages.value, messages.isEmpty else { return }
                    self?.sendMessage(type: type)
                }
                self?.syncConversation(productId, sellerId: sellerId)
            })
        }
    }
}


// MARK: - Tracking

fileprivate extension ChatViewModel {
    
    func trackFirstMessage(type: ChatWrapperMessageType) {
        guard let product = conversation.value.product else { return }
        guard let userId = conversation.value.interlocutor?.objectId else { return }

        let sellerRating = conversation.value.amISelling ?
            myUserRepository.myUser?.ratingAverage : interlocutor?.ratingAverage
        let firstMessageEvent = TrackerEvent.firstMessage(product, messageType: type.chatTrackerType, quickAnswerType: type.quickAnswerType,
                                                               interlocutorId: userId, typePage: .chat,
                                                               sellerRating: sellerRating,
                                                               freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                               isBumpedUp: EventParameterBoolean.falseParameter)
        TrackerProxy.sharedInstance.trackEvent(firstMessageEvent)
    }

    func trackMessageSent(type: ChatWrapperMessageType) {
        guard let product = conversation.value.product else { return }
        guard let userId = conversation.value.interlocutor?.objectId else { return }

        if shouldTrackFirstMessage {
            shouldTrackFirstMessage = false
            trackFirstMessage(type:type)
        }
        let messageSentEvent = TrackerEvent.userMessageSent(product, userToId: userId, messageType: type.chatTrackerType,
                                                            quickAnswerType: type.quickAnswerType, typePage: .chat,
                                                            freePostingModeAllowed: featureFlags.freePostingModeAllowed)
        TrackerProxy.sharedInstance.trackEvent(messageSentEvent)
    }
    
    func trackBlockUsers(_ userIds: [String]) {
        let blockUserEvent = TrackerEvent.profileBlock(.chat, blockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(blockUserEvent)
    }
    
    func trackUnblockUsers(_ userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.chat, unblockedUsersIds: userIds)
        TrackerProxy.sharedInstance.trackEvent(unblockUserEvent)
    }
    
    func trackVisit() {
        let chatWindowOpen = TrackerEvent.chatWindowVisit(source, chatEnabled: interlocutorEnabled)
        tracker.trackEvent(chatWindowOpen)
    }

    func trackMarkAsSold(userSoldTo: EventParameterUserSoldTo?) {
        guard let product = conversation.value.product else { return }
        let markAsSold = TrackerEvent.productMarkAsSold(product, typePage: .chat, soldTo: userSoldTo,
                                                        freePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                        isBumpedUp: .notAvailable)
        tracker.trackEvent(markAsSold)
    }
}


// MARK: - Private ChatConversation Extension

fileprivate extension ChatConversation {
    var chatStatus: ChatInfoViewStatus {
        guard let interlocutor = interlocutor else { return .available }
        guard let product = product else { return .available }

        switch interlocutor.status {
        case .scammer:
            return .forbidden
        case .pendingDelete:
            return .userPendingDelete
        case .deleted:
            return .userDeleted
        case .active, .inactive, .notFound:
            break // In this case we rely on the rest of states
        }

        if interlocutor.isBanned { return .forbidden }
        if interlocutor.isMuted { return .blocked }
        if interlocutor.hasMutedYou { return .blockedBy }
        switch product.status {
        case .deleted, .discarded:
            return .productDeleted
        case .sold, .soldOld:
            return .productSold
        case .approved, .pending:
            return .available
        }
    }
    
    var chatEnabled: Bool {
        switch chatStatus {
        case .forbidden, .blocked, .blockedBy, .userPendingDelete, .userDeleted:
            return false
        case .available, .productSold, .productDeleted:
            return true
        }
    }

    var relatedProductsEnabled: Bool {
        switch chatStatus {
        case .forbidden,  .userPendingDelete, .userDeleted, .productDeleted, .productSold:
            return !amISelling
        case .available, .blocked, .blockedBy:
            return false
        }
    }
}

fileprivate extension ChatInfoViewStatus {
    var userReviewEnabled: Bool {
        switch self {
        case .forbidden, .blocked, .blockedBy, .userPendingDelete, .userDeleted:
            return false
        case .available, .productSold, .productDeleted:
            return true
        }
    }
}

//// MARK: - DirectAnswers

extension ChatViewModel: DirectAnswersPresenterDelegate {
    
    var directAnswers: [QuickAnswer] {
        let isFree = featureFlags.freePostingModeAllowed && productIsFree.value
        let isBuyer = !conversation.value.amISelling
        return QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree)
    }
    
    func directAnswersDidTapAnswer(_ controller: DirectAnswersPresenter, answer: QuickAnswer) {
        switch answer {
        case .productSold:
            onProductSoldDirectAnswer()
        default:
            clearProductSoldDirectAnswer()
        }
        send(quickAnswer: answer)
    }
    
    func directAnswersDidTapClose(_ controller: DirectAnswersPresenter) {
        showDirectAnswers(false)
    }

    fileprivate func toggleDirectAnswers() {
        showDirectAnswers(!userDirectAnswersEnabled.value)
    }

    fileprivate func showDirectAnswers(_ show: Bool) {
        keyValueStorage.userSaveChatShowDirectAnswersForKey(userDefaultsSubKey, value: show)
        userDirectAnswersEnabled.value = show
    }
    
    private func clearProductSoldDirectAnswer() {
        shouldAskProductSold = false
    }
    
    private func onProductSoldDirectAnswer() {
        if chatStatus.value != .productSold {
            shouldAskProductSold = true
        }
    }
}


// MARK: - Related products

extension ChatViewModel: ChatRelatedProductsViewDelegate {

    func relatedProductsViewDidShow(_ view: ChatRelatedProductsView) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus.value)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsStart(relatedShownReason))
    }

    func relatedProductsView(_ view: ChatRelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus.value)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsComplete(index, shownReason: relatedShownReason))
        let data = ProductDetailData.productList(product: product, cellModels: productListModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        navigator?.openProduct(data, source: .chat, showKeyboardOnFirstAppearIfNeeded: false)
    }
}


// MARK: - Related products for express chat

extension ChatViewModel {

    static let maxRelatedProductsForExpressChat = 4

    fileprivate func retrieveRelatedProducts() {
        guard isBuyer else { return }
        guard let productId = conversation.value.product?.objectId else { return }
        productRepository.indexRelated(productId: productId, params: RetrieveProductsParams()) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.relatedProducts = strongSelf.relatedWithoutMyProducts(value)
                strongSelf.hasRelatedProducts.value = !strongSelf.relatedProducts.isEmpty
            }
        }
    }

    private func relatedWithoutMyProducts(_ products: [Product]) -> [Product] {
        var cleanRelatedProducts: [Product] = []
        for product in products {
            if product.user.objectId != myUserRepository.myUser?.objectId { cleanRelatedProducts.append(product) }
            if cleanRelatedProducts.count == OldChatViewModel.maxRelatedProductsForExpressChat {
                return cleanRelatedProducts
            }
        }
        return cleanRelatedProducts
    }

    // Express Chat Banner methods

    fileprivate func setupExpressChat() {
        expressMessagesAlreadySent.value = expressChatMessageSentForCurrentProduct()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) { [weak self] in
            self?.expressBannerTimerFinished.value = true
        }
    }

    private func expressChatMessageSentForCurrentProduct() -> Bool {
        guard let productId = conversation.value.product?.objectId else { return false }
        for productSentId in keyValueStorage.userProductsWithExpressChatMessageSent {
            if productSentId == productId { return true }
        }
        return false
    }
}
