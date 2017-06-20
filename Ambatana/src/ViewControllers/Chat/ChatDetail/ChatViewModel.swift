
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

    func vmDidFailRetrievingChatMessages()
    
    func vmShowReportUser(_ reportUserViewModel: ReportUsersViewModel)

    func vmShowSafetyTips()

    func vmClearText()
    func vmHideKeyboard(_ animated: Bool)
    func vmShowKeyboard()
    
    func vmShowPrePermissions(_ type: PrePermissionType)
    func vmShowMessage(_ message: String, completion: (() -> ())?)
}

struct EmptyConversation: ChatConversation {
    var objectId: String?
    var unreadMessageCount: Int = 0
    var lastMessageSentAt: Date? = nil
    var listing: ChatListing? = nil
    var interlocutor: ChatInterlocutor? = nil
    var amISelling: Bool 
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
    var relatedListings: [Listing] = []
    var shouldTrackFirstMessage: Bool = false
    let shouldShowExpressBanner = Variable<Bool>(false)
    let relatedProductsState = Variable<ChatRelatedItemsState>(.loading)

    var keyForTextCaching: String { return userDefaultsSubKey }
    
    let showStickerBadge = Variable<Bool>(!KeyValueStorage.sharedInstance[.stickersBadgeAlreadyShown])

    
    // fileprivate
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let chatRepository: ChatRepository
    fileprivate let listingRepository: ListingRepository
    fileprivate let userRepository: UserRepository
    fileprivate let stickersRepository: StickersRepository
    fileprivate let chatViewMessageAdapter: ChatViewMessageAdapter
    fileprivate let tracker: Tracker
    fileprivate let configManager: ConfigManager
    fileprivate let sessionManager: SessionManager
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let source: EventParameterTypePage
    fileprivate let pushPermissionsManager: PushPermissionsManager
    fileprivate let ratingManager: RatingManager
    
    fileprivate let keyValueStorage: KeyValueStorageable

    fileprivate let firstInteractionDone = Variable<Bool>(false)
    fileprivate let expressBannerTimerFinished = Variable<Bool>(false)
    fileprivate let hasRelatedProducts = Variable<Bool>(false)
    fileprivate let expressMessagesAlreadySent = Variable<Bool>(false)
    fileprivate let interlocutorIsMuted = Variable<Bool>(false)
    private let interlocutorHasMutedYou = Variable<Bool>(false)
    fileprivate let sellerDidntAnswer = Variable<Bool?>(nil)
    fileprivate let conversation: Variable<ChatConversation>
    fileprivate var interlocutor: User?
    private let myMessagesCount = Variable<Int>(0)
    private let otherMessagesCount = Variable<Int>(0)
    fileprivate let isEmptyConversation = Variable<Bool>(true)
    private let reviewTooltipVisible = Variable<Bool>(!KeyValueStorage.sharedInstance[.userRatingTooltipAlreadyShown])
    fileprivate let userDirectAnswersEnabled = Variable<Bool>(false)

    fileprivate var isDeleted = false
    fileprivate var shouldAskProductSold: Bool = false
    fileprivate var listingId: String? // Only used when accessing a chat from a listing
    fileprivate var preSendMessageCompletion: ((_ type: ChatWrapperMessageType) -> Void)?
    fileprivate var afterRetrieveMessagesCompletion: (() -> Void)?

    fileprivate var showingSendMessageError = false
    fileprivate var showingVerifyAccounts = false

    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var userDefaultsSubKey: String {
        return "\(String(describing: conversation.value.listing?.objectId ?? listingId)) + \(buyerId ?? "offline")"
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
    
    fileprivate var blockAction: () -> Void {
        return { [weak self] in
            self?.blockUserAction(buttonPosition: .safetyPopup)
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
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        let stickersRepository = Core.stickersRepository
        let configManager = LGConfigManager.sharedInstance
        let sessionManager = Core.sessionManager
        let featureFlags = FeatureFlags.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let ratingManager = LGRatingManager.sharedInstance
        let pushPermissionsManager = LGPushPermissionsManager.sharedInstance

        self.init(conversation: conversation, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  listingRepository: listingRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository, tracker: tracker, configManager: configManager,
                  sessionManager: sessionManager, keyValueStorage: keyValueStorage, navigator: navigator, featureFlags: featureFlags,
                  source: source, ratingManager: ratingManager, pushPermissionsManager: pushPermissionsManager)
    }
    
    convenience init?(listing: Listing, navigator: ChatDetailNavigator?, source: EventParameterTypePage) {
        guard let _ = listing.objectId, let sellerId = listing.user.objectId else { return nil }

        let myUserRepository = Core.myUserRepository
        let chatRepository = Core.chatRepository
        let listingRepository = Core.listingRepository
        let userRepository = Core.userRepository
        let stickersRepository = Core.stickersRepository
        let tracker = TrackerProxy.sharedInstance
        let configManager = LGConfigManager.sharedInstance
        let sessionManager = Core.sessionManager
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let ratingManager = LGRatingManager.sharedInstance
        let pushPermissionsManager = LGPushPermissionsManager.sharedInstance
        
        let amISelling = myUserRepository.myUser?.objectId == sellerId
        let empty = EmptyConversation(objectId: nil, unreadMessageCount: 0, lastMessageSentAt: nil, listing: nil,
                                      interlocutor: nil, amISelling: amISelling)
        self.init(conversation: empty, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  listingRepository: listingRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository ,tracker: tracker, configManager: configManager,
                  sessionManager: sessionManager, keyValueStorage: keyValueStorage, navigator: navigator, featureFlags: featureFlags,
                  source: source, ratingManager: ratingManager, pushPermissionsManager: pushPermissionsManager)
        self.setupConversationFrom(listing: listing)
    }
    
    init(conversation: ChatConversation, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
          listingRepository: ListingRepository, userRepository: UserRepository, stickersRepository: StickersRepository,
          tracker: Tracker, configManager: ConfigManager, sessionManager: SessionManager, keyValueStorage: KeyValueStorageable,
          navigator: ChatDetailNavigator?, featureFlags: FeatureFlaggeable, source: EventParameterTypePage,
          ratingManager: RatingManager, pushPermissionsManager: PushPermissionsManager) {
        self.conversation = Variable<ChatConversation>(conversation)
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.listingRepository = listingRepository
        self.userRepository = userRepository
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.configManager = configManager
        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage
        self.ratingManager = ratingManager
        self.pushPermissionsManager = pushPermissionsManager

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

        refreshChat()
        trackVisit()
    }

    func didAppear() {
        if conversation.value.isSaved && chatEnabled.value {
            delegate?.vmShowKeyboard()
        }
    }

    fileprivate func refreshChat() {
        // only load messages if the interlocutor is not blocked
        // Note: In some corner cases (staging only atm) the interlocutor may come as nil
        if let interlocutor = conversation.value.interlocutor, interlocutor.isBanned { return }
        refreshMessages()
    }

    func wentBack() {
        guard sessionManager.loggedIn else { return }
        guard isBuyer else { return }
        guard !relatedListings.isEmpty else { return }
        guard let listingId = conversation.value.listing?.objectId else { return }
        navigator?.openExpressChat(relatedListings, sourceListingId: listingId, manualOpen: false)
    }

    func setupConversationFrom(listing: Listing) {
        guard let listingId = listing.objectId, let sellerId = listing.user.objectId else { return }
        if let _ =  myUserRepository.myUser?.objectId {
            syncConversation(listingId, sellerId: sellerId)
        } else {
            setupNotLoggedIn(listing)
        }
    }

    func syncConversation(_ listingId: String, sellerId: String) {
        chatRepository.showConversation(sellerId, productId: listingId) { [weak self] result in
            if let value = result.value {
                self?.conversation.value = value
                self?.refreshMessages()
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
            self?.title.value = conversation.listing?.name ?? ""
            self?.productName.value = conversation.listing?.name ?? ""
            self?.productImageUrl.value = conversation.listing?.image?.fileURL
            if let featureFlags = self?.featureFlags {
                self?.productPrice.value = conversation.listing?.priceString(freeModeAllowed: featureFlags.freePostingModeAllowed) ?? ""
            }
            self?.productIsFree.value = conversation.listing?.price.free ?? false
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

        let relatedProductsConversation = conversation.asObservable().map { $0.relatedProductsEnabled }
        Observable.combineLatest(relatedProductsConversation, sellerDidntAnswer.asObservable()) { [weak self] in
            guard let strongSelf = self else { return .loading }
            guard strongSelf.isBuyer else { return .hidden } // Seller doesn't have related products
            guard let listingId = strongSelf.conversation.value.listing?.objectId else {return .hidden }
            if $0 { return .visible(listingId: listingId) }
            guard let didntAnswer = $1 else { return .loading } // If still checking if seller didn't answer. set loading state
            return didntAnswer ? .visible(listingId: listingId) : .hidden
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
        
        reviewTooltipVisible.asObservable().bindNext { [weak self] reviewTooltipVisible in
            self?.userReviewTooltipVisible.value = reviewTooltipVisible
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
            relatedProductsState.asObservable().map { $0.isVisible },
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
            guard let strongSelf = self else { return }
            switch wsChatStatus {
            case .openAuthenticated:
                //Reload messages if active, otherwise it will reload when active
                if strongSelf.active {
                    self?.refreshMessages()
                }
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
            case .authenticationTokenExpired, .talkerUnauthenticated:
                break
            }
        }.addDisposableTo(disposeBag)
    }

    
    // MARK: - Public Methods
    
    func productInfoPressed() {
        guard let product = conversation.value.listing else { return }
        switch product.status {
        case .deleted:
            break
        case .pending, .approved, .discarded, .sold, .soldOld:
            delegate?.vmHideKeyboard(false)
            let data = ListingDetailData.listingChat(chatConversation: conversation.value)
            navigator?.openListing(data, source: .chat, showKeyboardOnFirstAppearIfNeeded: false)
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
        navigator?.openUserRating(.chat, data: reviewData)
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

    func stickersShown() {
        keyValueStorage[.stickersBadgeAlreadyShown] = true
        showStickerBadge.value = false
    }

    func bannerActionButtonTapped() {
        guard let listingId = conversation.value.listing?.objectId else { return }
        navigator?.openExpressChat(relatedListings, sourceListingId: listingId, manualOpen: true)
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
            return productId == conversation.value.listing?.objectId && productBuyerId == buyerId
        }
    }

    fileprivate func showUserNotVerifiedAlert() {
        guard !showingVerifyAccounts else { return }
        showingVerifyAccounts = true
        navigator?.openVerifyAccounts([.facebook, .google, .email(myUserRepository.myUser?.email)],
                                         source: .chat(title: LGLocalizedString.chatConnectAccountsTitle,
                                         description: LGLocalizedString.chatNotVerifiedAlertMessage),
                                         completionBlock: { [weak self] in
                                            self?.navigator?.closeChatDetail()
                                            self?.showingVerifyAccounts = false
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
                strongSelf.afterSendMessageEvents()
                strongSelf.trackMessageSent(type: type)
            } else if let error = result.error {
                strongSelf.trackMessageSentError(type: type, error: error)
                // Removing message until we implement the retry-message state behavior
                strongSelf.removeMessage(messageId: messageId)
                switch error {
                case .userNotVerified:
                    self?.showUserNotVerifiedAlert()
                case .forbidden, .internalError, .network, .notFound, .tooManyRequests, .unauthorized, .serverError:
                    self?.showSendMessageError()
                }
            }
        }
    }

    private func afterSendMessageEvents() {
        firstInteractionDone.value = true
        if shouldAskProductSold {
            var interfaceText: String
            var alertTitle: String
            var soldQuestionText: String
            
            if productIsFree.value {
                interfaceText = LGLocalizedString.directAnswerGivenAwayQuestionOk
                alertTitle = LGLocalizedString.directAnswerGivenAwayQuestionTitle
                soldQuestionText = LGLocalizedString.directAnswerGivenAwayQuestionMessage
            } else {
                interfaceText = LGLocalizedString.directAnswerSoldQuestionOk
                alertTitle = LGLocalizedString.directAnswerSoldQuestionTitle
                soldQuestionText = LGLocalizedString.directAnswerSoldQuestionMessage
            }
            shouldAskProductSold = false
            let action = UIAction(interface: UIActionInterface.text(interfaceText),
                                  action: { [weak self] in self?.markProductAsSold() })
            delegate?.vmShowAlert(alertTitle,
                                  message: soldQuestionText,
                                  cancelLabel: LGLocalizedString.commonCancel,
                                  actions: [action])
        } else if pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.chat(buyer: isBuyer)) {
            delegate?.vmShowPrePermissions(.chat(buyer: isBuyer))
        } else if ratingManager.shouldShowRating {
            delegate?.vmHideKeyboard(true)
            delay(1.0) { [weak self] in
                self?.delegate?.vmHideKeyboard(true)
                self?.navigator?.openAppRating(.chat)
            }
        }
    }

    private func showSendMessageError() {
        guard !showingSendMessageError else { return }
        showingSendMessageError = true
        delegate?.vmShowAutoFadingMessage(LGLocalizedString.chatSendErrorGeneric) { [weak self] in
            self?.showingSendMessageError = false
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
        let viewMessage = chatViewMessageAdapter.adapt(message).markAsSent(date: sentAt).markAsReceived().markAsRead()
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
        guard let listingId = conversation.value.listing?.objectId else { return }
        
        delegate?.vmShowLoading(nil)
        listingRepository.markAsSold(listingId: listingId) { [weak self] result in
            if let _ = result.value {
                self?.trackMarkAsSold()
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
                                         action:  { [weak self] in self?.blockUserAction(buttonPosition: .threeDots) } )
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
    
    fileprivate func blockUserAction(buttonPosition: EventParameterBlockButtonPosition) {
        
        let action = UIAction(interface: .styledText(LGLocalizedString.chatBlockUserAlertBlockButton, .destructive), action: {
            [weak self] in
            self?.blockUser(buttonPosition: buttonPosition) { [weak self] success in
                if success {
                    self?.interlocutorIsMuted.value = true
                    self?.refreshChat()
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
    
    private func blockUser(buttonPosition: EventParameterBlockButtonPosition, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let userId = conversation.value.interlocutor?.objectId else {
            completion(false)
            return
        }
        
        trackBlockUsers([userId], buttonPosition: buttonPosition)
        
        self.userRepository.blockUserWithId(userId) { result -> Void in
            completion(result.value != nil)
        }
    }
    
    private func unblockUserAction() {
        unBlockUser() { [weak self] success in
            if success {
                self?.interlocutorIsMuted.value = false
                self?.refreshChat()
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

    func refreshMessages() {
        guard let convId = conversation.value.objectId else { return }
        guard !isLoading else { return }
        if messages.value.count == 0 {
            downloadFirstPage(convId)
        } else {
            refreshLastMessages(convId)
        }
    }

    private func retrieveMoreMessages() {
        guard let convId = conversation.value.objectId else { return }
        guard !isLoading && !isLastPage else { return }
        if messages.value.count == 0 {
            downloadFirstPage(convId)
        } else if let lastId = messages.value.last?.objectId {
            downloadMoreMessages(convId, fromMessageId: lastId)
        }
    }
    
    private var defaultDisclaimerMessage: ChatViewMessage {
        let action: (() -> Void)? = interlocutorIsMuted.value ? nil : blockAction
        return chatViewMessageAdapter.createMessageSuspiciousDisclaimerMessage(action)
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
        isLoading = true
        chatRepository.indexMessages(conversationId, numResults: resultsPerPage, offset: 0) { [weak self] result in
            guard let strongSelf = self else { return }

            strongSelf.isLoading = false
            if let value = result.value {
                self?.isLastPage = value.count == 0
                strongSelf.mergeMessages(newMessages: value)
                strongSelf.afterRetrieveChatMessagesEvents()
                strongSelf.checkSellerDidntAnswer(value)
            } else if let _ = result.error {
                strongSelf.delegate?.vmDidFailRetrievingChatMessages()
            }
        }
    }
    
    private func downloadMoreMessages(_ convId: String, fromMessageId: String) {
        isLoading = true
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

    private func refreshLastMessages(_ convId: String) {
        isLoading = true
        chatRepository.indexMessages(convId, numResults: resultsPerPage, offset: 0) { [weak self] result in
            self?.isLoading = false
            guard let newMessages = result.value else { return }
            self?.mergeMessages(newMessages: newMessages)
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

    private func mergeMessages(newMessages: [ChatMessage]) {
        markAsReadMessages(newMessages)

        let newViewMessages = newMessages.map(chatViewMessageAdapter.adapt)
        guard !newViewMessages.isEmpty else { return }

        //We need to remove extra messages & disclaimers to be able to merge correctly. Will be added back before returning
        var filteredViewMessages = messages.value.filter { $0.objectId != nil }

        filteredViewMessages.merge(
            another: newViewMessages,
            matcher: { $0.objectId == $1.objectId },
            sortBy: { (message1, message2) -> Bool in
                if message1.sentAt == nil && message2.sentAt != nil { return true }
                guard let sentAt1 = message1.sentAt, let sentAt2 = message2.sentAt else { return false }
                return sentAt1 > sentAt2
            }
        )

        var chatMessages = chatViewMessageAdapter.addDisclaimers(filteredViewMessages,
                                                                 disclaimerMessage: defaultDisclaimerMessage)

        // Add user info as 1st message
        if let userInfoMessage = userInfoMessage, isLastPage {
            chatMessages.append(userInfoMessage)
        }
        // Add disclaimer at the bottom of the first page
        if let bottomDisclaimerMessage = bottomDisclaimerMessage {
            chatMessages.insert(bottomDisclaimerMessage, at: 0)
        }

        messages.removeAll()
        messages.appendContentsOf(chatMessages)
    }
    
    fileprivate func updateDisclaimers() {
        let chatMessages = chatViewMessageAdapter.addDisclaimers(messages.value,
                                                                 disclaimerMessage: defaultDisclaimerMessage)
        messages.removeAll()
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
    func setupNotLoggedIn(_ listing: Listing) {
        guard let listingId = listing.objectId, let sellerId = listing.user.objectId else { return }
        self.listingId = listingId

        // Configure product + user info
        title.value = listing.title ?? ""
        productName.value = listing.title ?? ""
        productImageUrl.value = listing.thumbnail?.fileURL
        productPrice.value = listing.priceString(freeModeAllowed: featureFlags.freePostingModeAllowed)
        interlocutorAvatarURL.value = listing.user.avatar?.fileURL
        interlocutorName.value = listing.user.name ?? ""
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
                self?.syncConversation(listingId, sellerId: sellerId)
            })
        }
    }
}


// MARK: - Tracking

fileprivate extension ChatViewModel {

    func trackMessageSent(type: ChatWrapperMessageType) {
        guard let info = buildSendMessageInfo(withType: type, error: nil) else { return }

        if shouldTrackFirstMessage {
            shouldTrackFirstMessage = false
            tracker.trackEvent(TrackerEvent.firstMessage(info: info, productVisitSource: .unknown))
        }
        tracker.trackEvent(TrackerEvent.userMessageSent(info: info))
    }

    func trackMessageSentError(type: ChatWrapperMessageType, error: RepositoryError) {
        guard let info = buildSendMessageInfo(withType: type, error: error) else { return }
        tracker.trackEvent(TrackerEvent.userMessageSentError(info: info))
    }
    
    func trackBlockUsers(_ userIds: [String], buttonPosition: EventParameterBlockButtonPosition) {
        let blockUserEvent = TrackerEvent.profileBlock(.chat, blockedUsersIds: userIds, buttonPosition: buttonPosition)
        tracker.trackEvent(blockUserEvent)
    }
    
    func trackUnblockUsers(_ userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.chat, unblockedUsersIds: userIds)
        tracker.trackEvent(unblockUserEvent)
    }
    
    func trackVisit() {
        let chatWindowOpen = TrackerEvent.chatWindowVisit(source, chatEnabled: interlocutorEnabled)
        tracker.trackEvent(chatWindowOpen)
    }

    func trackMarkAsSold() {
        guard let chatListing = conversation.value.listing else { return }
        let trackingInfo = MarkAsSoldTrackingInfo.make(chatListing: chatListing,
                                                       isBumpedUp: .notAvailable,
                                                       isFreePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                       typePage: .chat)
        let markAsSold = TrackerEvent.productMarkAsSold(trackingInfo: trackingInfo)
        tracker.trackEvent(markAsSold)
    }

    private func buildSendMessageInfo(withType type: ChatWrapperMessageType, error: RepositoryError?) -> SendMessageTrackingInfo? {
        guard let listing = conversation.value.listing else { return nil }
        guard let userId = conversation.value.interlocutor?.objectId else { return nil }

        let sellerRating = conversation.value.amISelling ?
            myUserRepository.myUser?.ratingAverage : interlocutor?.ratingAverage

        let sendMessageInfo = SendMessageTrackingInfo()
            .set(chatListing: listing, freePostingModeAllowed: featureFlags.freePostingModeAllowed)
            .set(interlocutorId: userId)
            .set(messageType: type.chatTrackerType)
            .set(quickAnswerType: type.quickAnswerType)
            .set(typePage: .chat)
            .set(sellerRating: sellerRating)
            .set(isBumpedUp: .falseParameter)
        if let error = error {
            sendMessageInfo.set(error: error.chatError)
        }
        return sendMessageInfo
    }
}


// MARK: - Private ChatConversation Extension

fileprivate extension ChatConversation {
    var chatStatus: ChatInfoViewStatus {
        guard let interlocutor = interlocutor else { return .available }
        guard let listing = listing else { return .available }

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
        switch listing.status {
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

// MARK: - DirectAnswers

extension ChatViewModel: DirectAnswersPresenterDelegate {
    
    var directAnswers: [QuickAnswer] {
        let isFree = featureFlags.freePostingModeAllowed && productIsFree.value
        let isBuyer = !conversation.value.amISelling
        return QuickAnswer.quickAnswersForChatWith(buyer: isBuyer, isFree: isFree)
    }
    
    func directAnswersDidTapAnswer(_ controller: DirectAnswersPresenter, answer: QuickAnswer) {
        switch answer {
        case .productSold, .freeNotAvailable:
            onProductSoldDirectAnswer()
        case .interested, .notInterested, .meetUp, .stillAvailable, .isNegotiable, .likeToBuy, .productCondition,
             .productStillForSale, .whatsOffer, .negotiableYes, .negotiableNo, .freeStillHave, .freeYours,
             .freeAvailable:
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
        if chatStatus.value == .available {
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

    func relatedProductsView(_ view: ChatRelatedProductsView, showListing listing: Listing, atIndex index: Int,
                             productListModels: [ListingCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus.value)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsComplete(index, shownReason: relatedShownReason))
        let data = ListingDetailData.listingList(listing: listing, cellModels: productListModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        navigator?.openListing(data, source: .chat, showKeyboardOnFirstAppearIfNeeded: false)
    }
}


// MARK: - Related products for express chat

extension ChatViewModel {

    static let maxRelatedProductsForExpressChat = 4

    fileprivate func retrieveRelatedProducts() {
        guard isBuyer else { return }
        guard let productId = conversation.value.listing?.objectId else { return }
        listingRepository.indexRelated(listingId: productId, params: RetrieveListingParams()) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let listings = result.value {
                strongSelf.relatedListings = strongSelf.relatedWithoutMyListings(listings)
                strongSelf.hasRelatedProducts.value = !strongSelf.relatedListings.isEmpty
            }
        }
    }

    private func relatedWithoutMyListings(_ listings: [Listing]) -> [Listing] {
        var cleanRelatedListings: [Listing] = []
        for listing in listings {
            if listing.user.objectId != myUserRepository.myUser?.objectId { cleanRelatedListings.append(listing) }
            if cleanRelatedListings.count == OldChatViewModel.maxRelatedProductsForExpressChat {
                return cleanRelatedListings
            }
        }
        return cleanRelatedListings
    }


    // Express Chat Banner methods

    fileprivate func setupExpressChat() {
        expressMessagesAlreadySent.value = expressChatMessageSentForCurrentProduct()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) { [weak self] in
            self?.expressBannerTimerFinished.value = true
        }
    }

    private func expressChatMessageSentForCurrentProduct() -> Bool {
        guard let listingId = conversation.value.listing?.objectId else { return false }
        for productSentId in keyValueStorage.userProductsWithExpressChatMessageSent {
            if productSentId == listingId { return true }
        }
        return false
    }
}
