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
    
    func vmDidStartRetrievingChatMessages(hasData: Bool)
    func vmDidFailRetrievingChatMessages()
    func vmDidRefreshChatMessages()
    func vmUpdateAfterReceivingMessagesAtPositions(_ positions: [Int], isUpdate: Bool)
    
    func vmDidFailSendingMessage()
    func vmDidSucceedSendingMessage(_ index: Int)

    func vmShowRelatedProducts(_ productId: String?)
    func vmDidUpdateProduct(messageToShow message: String?)

    func vmShowReportUser(_ reportUserViewModel: ReportUsersViewModel)
    func vmShowUserRating(_ source: RateUserSource, data: RateUserData)
    
    func vmShowSafetyTips()
    func vmAskForRating()
    func vmShowPrePermissions(_ type: PrePermissionType)
    func vmShowKeyboard()
    func vmHideKeyboard(animated: Bool)
    func vmShowMessage(_ message: String, completion: (() -> ())?)
    func vmShowOptionsList(_ options: [String], actions: [() -> Void])
    func vmShowQuestion(title: String, message: String, positiveText: String, positiveAction: (() -> Void)?,
                              positiveActionStyle: UIAlertActionStyle?, negativeText: String, negativeAction: (() -> Void)?,
                              negativeActionStyle: UIAlertActionStyle?)
    func vmClose()
    
    func vmLoadStickersTooltipWithText(_ text: NSAttributedString)

    func vmUpdateRelationInfoView(_ status: ChatInfoViewStatus)
    func vmUpdateChatInteraction(_ enabled: Bool)
    
    func vmDidUpdateStickers()
    func vmClearText()

    func vmUpdateUserIsReadyToReview()
}

enum AskQuestionSource {
    case productList
    case productDetail
}


class OldChatViewModel: BaseViewModel, Paginable {
    
    // MARK: - Properties
    // MARK: > Protocols

    weak var delegate: OldChatViewModelDelegate?
    weak var navigator: ChatDetailNavigator?

    // MARK: > Public data

    var title: String? {
        return product.title
    }
    var productName: String? {
        return product.title
    }
    var productImageUrl: URL? {
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
    var otherUserAvatarUrl: URL? {
        return otherUser?.avatar?.fileURL
    }
    var otherUserID: String? {
        return otherUser?.objectId
    }
    var otherUserName: String? {
        return otherUser?.name
    }

    fileprivate(set) var stickers: [Sticker] = [] {
        didSet {
            delegate?.vmDidUpdateStickers()
        }
    }

    var userRelation: UserUserRelation? {
        didSet {
            delegate?.vmUpdateRelationInfoView(chatStatus)
            if let relation = userRelation, relation.isBlocked || relation.isBlockedBy {
                delegate?.vmHideKeyboard(animated: true)
                showDirectAnswers(false)
            } else {
                showDirectAnswers(userDirectAnswersEnabled.value)
            }
            delegate?.vmUpdateChatInteraction(chatEnabled)
        }
    }

    var keyForTextCaching: String {
        return userDefaultsSubKey
    }

    var chatStatus: ChatInfoViewStatus {
        if chat.forbidden {
            return .forbidden
        }

        guard let otherUser = otherUser else { return .userDeleted }
        switch otherUser.status {
        case .scammer:
            return .forbidden
        case .pendingDelete:
            return .userPendingDelete
        case .deleted:
            return .userDeleted
        case .active, .inactive, .notFound:
            break // In this case we rely on the rest of states
        }

        if let relation = userRelation {
            if relation.isBlocked { return .blocked }
            if relation.isBlockedBy { return .blockedBy }
        }
        
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
        case .forbidden, .blocked, .blockedBy, .userDeleted, .userPendingDelete:
            return false
        case .available, .productSold, .productDeleted:
            return true
        }
    }

    var otherUserEnabled: Bool {
        switch chatStatus {
        case .forbidden, .userDeleted, .userPendingDelete:
            return false
        case .available, .productSold, .productDeleted, .blocked, .blockedBy:
            return true
        }
    }

    let isSendingMessage = Variable<Bool>(false)
    var relatedProducts: [Product] = []

    var scammerDisclaimerMessage: ChatViewMessage {
        return chatViewMessageAdapter.createScammerDisclaimerMessage(
            isBuyer: isBuyer, userName: otherUser?.name, action: safetyTipsAction)
    }

    var messageSuspiciousDisclaimerMessage: ChatViewMessage {
        return chatViewMessageAdapter.createMessageSuspiciousDisclaimerMessage(safetyTipsAction)
    }

    var userInfoMessage: ChatViewMessage? {
        return chatViewMessageAdapter.createUserInfoMessage(otherUser)
    }

    private var bottomDisclaimerMessage: ChatViewMessage? {
        switch chatStatus {
        case  .userPendingDelete, .userDeleted:
            return chatViewMessageAdapter.createUserDeletedDisclaimerMessage(otherUser?.name)
        case .productDeleted, .forbidden, .available, .blocked, .blockedBy, .productSold:
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
        case .available, .productSold:
            return enoughMessagesForUserRating
        case .productDeleted, .forbidden, .userPendingDelete, .userDeleted, .blocked, .blockedBy:
            return false
        }
    }

    var shouldShowUserReviewTooltip: Bool {
        // we don't want both tooltips at the same time.  !st stickers, then rating
        return !keyValueStorage[.userRatingTooltipAlreadyShown] &&
            keyValueStorage[.stickersTooltipAlreadyShown]
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
    
    fileprivate let chatRepository: OldChatRepository
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let productRepository: ProductRepository
    fileprivate let userRepository: UserRepository
    fileprivate let stickersRepository: StickersRepository
    fileprivate let chatViewMessageAdapter: ChatViewMessageAdapter
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let configManager: ConfigManager
    fileprivate let sessionManager: SessionManager
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate var shouldSendFirstMessageEvent: Bool = false
    fileprivate var chat: Chat
    fileprivate var product: Product
    private var isDeleted = false
    private var shouldAskProductSold: Bool = false
    fileprivate var userDefaultsSubKey: String {
        return "\(product.objectId) + \(buyer?.objectId ?? "offline")"
    }
    
    fileprivate var loadedMessages: [ChatViewMessage]
    private var buyer: User?
    fileprivate var otherUser: User?
    fileprivate var afterRetrieveMessagesBlock: (() -> Void)?
    fileprivate var autoKeyboardEnabled = true

    fileprivate var isMyProduct: Bool {
        guard let productUserId = product.user.objectId, let myUserId = myUserRepository.myUser?.objectId else { return false }
        return productUserId == myUserId
    }
    fileprivate var isBuyer: Bool {
        return !isMyProduct
    }
    private var shouldShowSafetyTips: Bool {
        return !keyValueStorage.userChatSafetyTipsShown && didReceiveMessageFromOtherUser
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
    fileprivate var didSendMessage: Bool {
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
    private var bottomDisclaimerIndex: Int? {
        for (index, message) in loadedMessages.enumerated() {
            switch message.type {
            case .disclaimer:
                return index
            default: break
            }
        }
        return nil
    }
    fileprivate var shouldShowOtherUserInfo: Bool {
        guard chat.isSaved else { return true }
        return !isLoading && isLastPage
    }

    // MARK: > express chat banner
    var shouldShowExpressBanner = Variable<Bool>(false)
    var firstInteractionDone = Variable<Bool>(false)
    var expressBannerTimerFinished = Variable<Bool>(false)
    var hasRelatedProducts = Variable<Bool>(false)
    var expressMessagesAlreadySent = Variable<Bool>(false)

    // MARK: > related products
    let relatedProductsState = Variable<ChatRelatedItemsState>(.loading)
    let chatStatusEnablesRelatedProducts = Variable<Bool>(false)
    let sellerDidntAnswer = Variable<Bool?>(nil)

    // MARK: > Direct answers
    fileprivate let userDirectAnswersEnabled = Variable<Bool>(false)
    let directAnswersState = Variable<DirectAnswersState>(.notAvailable)

    private let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle

    convenience init?(chat: Chat, navigator: ChatDetailNavigator?) {
        self.init(chat: chat, myUserRepository: Core.myUserRepository, configManager: ConfigManager.sharedInstance,
                  sessionManager: Core.sessionManager, navigator: navigator,
                  keyValueStorage: KeyValueStorage.sharedInstance, featureFlags: FeatureFlags.sharedInstance)
    }
    
    convenience init?(product: Product, navigator: ChatDetailNavigator?) {
        let myUserRepository = Core.myUserRepository
        let chat = LocalChat(product: product, myUser: myUserRepository.myUser)
        let configManager = ConfigManager.sharedInstance
        let sessionManager = Core.sessionManager
        let featureFlags = FeatureFlags.sharedInstance
        self.init(chat: chat, myUserRepository: myUserRepository,
                  configManager: configManager, sessionManager: sessionManager, navigator: navigator,
                  keyValueStorage: KeyValueStorage.sharedInstance, featureFlags: featureFlags)
    }

    convenience init?(chat: Chat, myUserRepository: MyUserRepository, configManager: ConfigManager,
                      sessionManager: SessionManager, navigator: ChatDetailNavigator?, keyValueStorage: KeyValueStorage,
						featureFlags: FeatureFlaggeable) {
        let chatRepository = Core.oldChatRepository
        let productRepository = Core.productRepository
        let userRepository = Core.userRepository
        let tracker = TrackerProxy.sharedInstance
        let sessionManager = Core.sessionManager
        let stickersRepository = Core.stickersRepository
        let featureFlags = FeatureFlags.sharedInstance
        self.init(chat: chat, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  productRepository: productRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository, tracker: tracker,
                  configManager: configManager, sessionManager: sessionManager, navigator: navigator,
                  keyValueStorage: keyValueStorage, featureFlags: featureFlags)
    }

    init?(chat: Chat, myUserRepository: MyUserRepository, chatRepository: OldChatRepository,
          productRepository: ProductRepository, userRepository: UserRepository, stickersRepository: StickersRepository,
          tracker: Tracker, configManager: ConfigManager, sessionManager: SessionManager, navigator: ChatDetailNavigator?,
          keyValueStorage: KeyValueStorage, featureFlags: FeatureFlaggeable) {
        self.chat = chat
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.productRepository = productRepository
        self.userRepository = userRepository
        self.stickersRepository = stickersRepository
        self.chatViewMessageAdapter = ChatViewMessageAdapter()
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.configManager = configManager
        self.sessionManager = sessionManager
        self.navigator = navigator
        self.keyValueStorage = keyValueStorage
        self.loadedMessages = []
        self.product = chat.product
        if let myUser = myUserRepository.myUser {
            self.isDeleted = chat.isArchived(myUser: myUser)
        }
        super.init()
        initUsers()
        loadStickers()
        if otherUser == nil { return nil }

        setupRx()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        if firstTime {
            retrieveRelatedProducts()
            chatStatusEnablesRelatedProducts.value = statusEnableRelatedProducts()
            launchExpressChatTimer()
            expressMessagesAlreadySent.value = expressChatMessageSentForCurrentProduct()
        }

       refreshChatInfo()

        if firstTime {
            retrieveInterlocutorInfo()
            loadStickersTooltip()
        }
    }

    func applicationWillEnterForeground() {
        refreshChatInfo()
    }

    private func refreshChatInfo() {
        guard chatStatus != .forbidden else {
            showScammerDisclaimerMessage()
            markForbiddenAsRead()
            return
        }
        // only load messages if the chat is not forbidden
        retrieveFirstPage()
        retrieveUsersRelation()
    }

    func wentBack() {
        guard sessionManager.loggedIn else { return }
        guard isBuyer else { return }
        guard !relatedProducts.isEmpty else { return }
        guard let productId = product.objectId else { return }
        navigator?.openExpressChat(relatedProducts, sourceProductId: productId, manualOpen: false)
    }
    
    func showScammerDisclaimerMessage() {
        loadedMessages = [scammerDisclaimerMessage]
        delegate?.vmDidRefreshChatMessages()
    }

    func statusEnableRelatedProducts() -> Bool {
        guard isBuyer else { return false }
        switch chatStatus {
        case .forbidden, .userDeleted, .userPendingDelete, .productDeleted, .productSold:
            return true
        case  .available, .blocked, .blockedBy:
            return false
        }
    }
    
    func didAppear() {
        if !chatEnabled {
            delegate?.vmHideKeyboard(animated: true)
        } else if autoKeyboardEnabled {
            delegate?.vmShowKeyboard()
        }
    }

    
    // MARK: - Public
    
    func productInfoPressed() {
        switch chatStatus {
        case .productDeleted, .forbidden:
            break
        case .available, .blocked, .blockedBy, .productSold, .userPendingDelete, .userDeleted:
            delegate?.vmHideKeyboard(animated: false)
            let data = ProductDetailData.productAPI(product: product, thumbnailImage: nil, originFrame: nil)
            navigator?.openProduct(data, source: .chat, showKeyboardOnFirstAppearIfNeeded: false)
        }
    }
    
    func userInfoPressed() {
        switch chatStatus {
        case .forbidden, .userPendingDelete, .userDeleted:
            break
        case .productDeleted, .available, .blocked, .blockedBy, .productSold:
            guard let user = otherUser else { return }
            delegate?.vmHideKeyboard(animated: false)
            let data = UserDetailData.userAPI(user: user, source: .chat)
            navigator?.openUser(data)
        }
    }

    func reviewUserPressed() {
        keyValueStorage[.userRatingTooltipAlreadyShown] = true
        guard let otherUser = otherUser, let reviewData = RateUserData(user: otherUser) else { return }
        delegate?.vmShowUserRating(.chat, data: reviewData)
    }

    func closeReviewTooltipPressed() {
        keyValueStorage[.userRatingTooltipAlreadyShown] = true
    }
    
    func safetyTipsDismissed() {
        keyValueStorage.userChatSafetyTipsShown = true
    }
    
    func optionsBtnPressed() {
        var texts: [String] = []
        var actions: [() -> Void] = []
        //Safety tips
        texts.append(LGLocalizedString.chatSafetyTips)
        actions.append({ [weak self] in self?.delegate?.vmShowSafetyTips() })

        //Direct answers
        if chat.isSaved && !featureFlags.newQuickAnswers && directAnswersState.value != .notAvailable {
            let visible = directAnswersState.value == .visible
            texts.append(visible ? LGLocalizedString.directAnswersHide :
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
            
            if let relation = userRelation, relation.isBlocked {
                texts.append(LGLocalizedString.chatUnblockUser)
                actions.append({ [weak self] in self?.unblockUserPressed() })
            } else {
                texts.append(LGLocalizedString.chatBlockUser)
                actions.append({ [weak self] in self?.blockUserPressed() })
            }
        }
        
        delegate?.vmShowOptionsList(texts, actions: actions)
    }
    
    func messageAtIndex(_ index: Int) -> ChatViewMessage {
        return loadedMessages[index]
    }
    
    func textOfMessageAtIndex(_ index: Int) -> String {
        return loadedMessages[index].value
    }
    
    func sendSticker(_ sticker: Sticker) {
        sendMessage(sticker.name, isQuickAnswer: false, type: .sticker)
    }
    
    func sendText(_ text: String, isQuickAnswer: Bool) {
        sendMessage(text, isQuickAnswer: isQuickAnswer, type: .text)
    }
    
    func isMatchingConversationData(_ data: ConversationData) -> Bool {
        switch data {
        case .conversation(let conversationId):
            return conversationId == chat.objectId
        case let .productBuyer(productId, buyerId):
            return productId == product.objectId && buyerId == buyer?.objectId
        }
    }

    func stickersShown() {
        keyValueStorage[.stickersTooltipAlreadyShown] = true
        delegate?.vmDidUpdateProduct(messageToShow: nil)
    }

    func bannerActionButtonTapped() {
        guard let productId = product.objectId else { return }
        navigator?.openExpressChat(relatedProducts, sourceProductId: productId, manualOpen: true)
    }

    func directAnswersButtonPressed() {
        toggleDirectAnswers()
    }

    func keyboardShown() {
        if featureFlags.newQuickAnswers && directAnswersState.value != .notAvailable {
            showDirectAnswers(false)
        }
    }
    
    // MARK: - private methods
    
    fileprivate func initUsers() {
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
            }
        }
    }

    private func setupRx() {
        Observable.combineLatest(chatStatusEnablesRelatedProducts.asObservable(), sellerDidntAnswer.asObservable()) { [weak self] in
            guard let strongSelf = self else { return .loading }
            guard strongSelf.isBuyer else { return .hidden } // Seller doesn't have related products
            if $0 { return .visible }
            guard let didntAnswer = $1 else { return .loading } // If still checking if seller didn't answer. set loading state
            return didntAnswer ? .visible : .hidden
        }
        .bindTo(relatedProductsState).addDisposableTo(disposeBag)

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
            relatedProductsState.asObservable().map { (state: ChatRelatedItemsState) -> Bool in return state == .visible },
        expressMessagesAlreadySent.asObservable()) { $0 && $1 && !$2 && !$3 }
            .distinctUntilChanged().bindNext { [weak self] shouldShowBanner in
                guard let strongSelf = self else { return }
                self?.shouldShowExpressBanner.value = shouldShowBanner && strongSelf.featureFlags.expressChatBanner
        }.addDisposableTo(disposeBag)

        relatedProductsState.asObservable().bindNext { [weak self] state in
            switch state {
            case .loading, .hidden:
                self?.delegate?.vmShowRelatedProducts(nil)
            case .visible:
                self?.delegate?.vmShowRelatedProducts(self?.product.objectId)
            }
        }.addDisposableTo(disposeBag)

        if !featureFlags.newQuickAnswers {
            // New quick answers doesn't depend on saved state
            userDirectAnswersEnabled.value = keyValueStorage.userLoadChatShowDirectAnswersForKey(userDefaultsSubKey)
        }
        let directAnswers: Observable<DirectAnswersState> = Observable.combineLatest(
            relatedProductsState.asObservable(),
            userDirectAnswersEnabled.asObservable(),
            resultSelector: { [weak self] relatedState, directAnswers in
                guard let chatEnabled = self?.chatEnabled else { return .notAvailable }
                switch relatedState {
                case .loading, .visible:
                    return .notAvailable
                case .hidden:
                    guard chatEnabled else { return .notAvailable }
                    return directAnswers ? .visible : .hidden
            }
        }).distinctUntilChanged()
        directAnswers.bindTo(directAnswersState).addDisposableTo(disposeBag)

        setupDeepLinksRx()
    }

    private func setupDeepLinksRx() {
        DeepLinksRouter.sharedInstance.chatDeepLinks.subscribeNext { [weak self] deepLink in
            switch deepLink.action {
            case .conversation(let data):
                guard self?.isMatchingConversationData(data) ?? false else { return }
                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
            case .message(_, let data):
                guard self?.isMatchingConversationData(data) ?? false else { return }
                self?.retrieveFirstPageWithNumResults(Constants.numMessagesPerPage)
            default: break
            }
            }.addDisposableTo(disposeBag)
    }

    fileprivate func sendMessage(_ text: String, isQuickAnswer: Bool, type: MessageType) {
        guard myUserRepository.myUser != nil else {
            loginAndResend(text, isQuickAnswer: isQuickAnswer, type: type)
            return
        }

        if isSendingMessage.value { return }
        let message = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard message.characters.count > 0 else { return }
        guard let toUser = otherUser else { return }
        if !isQuickAnswer && type != .sticker {
            delegate?.vmClearText()
        }
        isSendingMessage.value = true

        chatRepository.sendMessage(type, message: message, product: product, recipient: toUser) { [weak self] result in
            guard let strongSelf = self else { return }
            if let sentMessage = result.value, let adapter = self?.chatViewMessageAdapter {
                //This is required to be called BEFORE any message insertion
                strongSelf.trackMessageSent(isQuickAnswer, type: type)

                let viewMessage = adapter.adapt(sentMessage)
                strongSelf.loadedMessages.insert(viewMessage, at: 0)
                strongSelf.delegate?.vmDidSucceedSendingMessage(0)
                strongSelf.afterSendMessageEvents()
            } else if let error = result.error {
                switch error {
                case .userNotVerified:
                    strongSelf.userNotVerifiedError()
                case .forbidden, .internalError, .network, .notFound, .tooManyRequests, .unauthorized, .serverError:
                    strongSelf.delegate?.vmDidFailSendingMessage()
                }
            }
            strongSelf.isSendingMessage.value = false
        }
    }

    fileprivate func retrieveUsersRelation() {
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
        navigator?.openVerifyAccounts([.facebook, .google, .email(myUserRepository.myUser?.email)],
                                         source: .chat(title: LGLocalizedString.chatConnectAccountsTitle,
                                            description: LGLocalizedString.chatNotVerifiedAlertMessage),
                                         completionBlock: { [weak self] in
                                            self?.navigator?.closeChatDetail()
        })
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

    private func afterSendMessageEvents() {
        firstInteractionDone.value = true
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
        } else if PushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.chat(buyer: isBuyer)) {
            delegate?.vmShowPrePermissions(.chat(buyer: isBuyer))
        } else if RatingManager.sharedInstance.shouldShowRating {
            delegate?.vmAskForRating()
        }
        delegate?.vmUpdateUserIsReadyToReview()
    }

    private func loadStickersTooltip() {
        guard chatEnabled && !keyValueStorage[.stickersTooltipAlreadyShown] else { return }

        var newTextAttributes = [String : Any]()
        newTextAttributes[NSForegroundColorAttributeName] = UIColor.primaryColorHighlighted
        newTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let newText = NSAttributedString(string: LGLocalizedString.chatStickersTooltipNew, attributes: newTextAttributes)

        var titleTextAttributes = [String : Any]()
        titleTextAttributes[NSForegroundColorAttributeName] = UIColor.white
        titleTextAttributes[NSFontAttributeName] = UIFont.systemSemiBoldFont(size: 17)

        let titleText = NSAttributedString(string: LGLocalizedString.chatStickersTooltipAddStickers, attributes: titleTextAttributes)

        let fullTitle: NSMutableAttributedString = NSMutableAttributedString(attributedString: newText)
        fullTitle.append(NSAttributedString(string: " "))
        fullTitle.append(titleText)

        delegate?.vmLoadStickersTooltipWithText(fullTitle)
    }
    

    /**
     Retrieves the specified number of the newest messages
     
     - parameter numResults: the num of messages to retrieve
     */
    private func retrieveFirstPageWithNumResults(_ numResults: Int) {
        
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
                strongSelf.delegate?.vmUpdateAfterReceivingMessagesAtPositions(insertedMessagesInfo.indexes,
                                                                               isUpdate: insertedMessagesInfo.isUpdate)
                strongSelf.afterRetrieveChatMessagesEvents()
                strongSelf.checkSellerDidntAnswer(chat.messages, page: strongSelf.firstPage)
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
     
     - returns: a struct with the FULL array (old + new), the indexes of the NEW items and if the insertion should be an update
        * if there are messages without id, we consider the insertion as an update then the table is reloaded instead of inserted
     */

    static func insertNewMessagesAt(_ mainMessages: [ChatViewMessage], newMessages: [ChatViewMessage])
        -> (messages: [ChatViewMessage], indexes: [Int], isUpdate: Bool) {

            guard !newMessages.isEmpty else { return (mainMessages, [], false) }

            var isUpdate = false
            var firstId: String? = nil

            var mainMessagesWithId: [ChatViewMessage] = mainMessages

            for i in 0..<mainMessages.count {
                if mainMessages[i].objectId != nil {
                    firstId = mainMessages[i].objectId
                    break
                } else {
                    isUpdate = true
                    mainMessagesWithId.removeFirst()
                }
            }
            // double check in case the messages with no id weren't at the first positions
            for i in 0..<min(10, mainMessagesWithId.count) {
                if mainMessagesWithId[i].objectId == nil {
                    isUpdate = true
                    break
                }
            }

            // - reallyNewMessages: the messages in newMessages that are not in mainMessages already
            var reallyNewMessages: [ChatViewMessage] = []
            // - idxs: the positions of the table that will be inserted
            var idxs: [Int] = []
            for i in 0..<newMessages.count {
                if newMessages[i].objectId == firstId {
                    break
                } else {
                    reallyNewMessages.append(newMessages[i])
                    idxs.append(i)
                }
            }
            return (reallyNewMessages + mainMessagesWithId, idxs, isUpdate)
    }

    private func markForbiddenAsRead() {
        guard let userBuyer = buyer else { return }
        //We just get the last one as backend will mark all of them as read
        chatRepository.retrieveMessagesWithProduct(product, buyer: userBuyer, page: 0, numResults: 1, completion: nil)
    }
    
    fileprivate func onProductSoldDirectAnswer() {
        if chatStatus != .productSold {
            shouldAskProductSold = true
        }
    }
    
    fileprivate func clearProductSoldDirectAnswer() {
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
                                 positiveActionStyle: .destructive,
                                 negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
    }
    
    private func blockUser(_ completion: @escaping (_ success: Bool) -> ()) {
        
        guard let user = otherUser, let userId = user.objectId else {
            completion(false)
            return
        }
        
        trackBlockUsers([userId])
        
        self.userRepository.blockUserWithId(userId) { result -> Void in
            completion(result.value != nil)
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
    
    private func unBlockUser(_ completion: @escaping (_ success: Bool) -> ()) {
        guard let user = otherUser, let userId = user.objectId else {
            completion(false)
            return
        }
        
        trackUnblockUsers([userId])
        
        self.userRepository.unblockUserWithId(userId) { result -> Void in
            completion(result.value != nil)
        }
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
                                 positiveActionStyle: .destructive,
                                 negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
    }
    
    private func delete(_ completion: @escaping (_ success: Bool) -> ()) {
        guard let chatId = chat.objectId else {
            completion(false)
            return
        }
        self.chatRepository.archiveChatsWithIds([chatId]) { result in
            completion(result.value != nil)
        }
    }
    
    private func reportUserPressed() {
        guard let otherUserId = otherUser?.objectId else { return }
        let reportVM = ReportUsersViewModel(origin: .chat, userReportedId: otherUserId)
        delegate?.vmShowReportUser(reportVM)
    }
    
    private func markProductAsSold() {
        delegate?.vmShowLoading(nil)
        productRepository.markProductAsSold(product) { [weak self] result in
            self?.delegate?.vmHideLoading(nil) { [weak self] in
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
    }

    
    // MARK: Tracking
    
    private func trackFirstMessage(_ type: MessageType) {
        // only track ask question if I didn't send any previous message
        guard !didSendMessage else { return }
        let sellerRating: Float? = isBuyer ? otherUser?.ratingAverage : myUserRepository.myUser?.ratingAverage
        let firstMessageEvent = TrackerEvent.firstMessage(product, messageType: type.trackingMessageType,
                                                               typePage: .chat, sellerRating: sellerRating)
        tracker.trackEvent(firstMessageEvent)
    }
    
    private func trackMessageSent(_ isQuickAnswer: Bool, type: MessageType) {
        if shouldSendFirstMessageEvent {
            shouldSendFirstMessageEvent = false
            trackFirstMessage(type)
        }
        let messageSentEvent = TrackerEvent.userMessageSent(product, userTo: otherUser,
                                                            messageType: type.trackingMessageType,
                                                            isQuickAnswer: isQuickAnswer ? .trueParameter : .falseParameter, typePage: .chat)
        tracker.trackEvent(messageSentEvent)
    }
    
    private func trackBlockUsers(_ userIds: [String]) {
        let blockUserEvent = TrackerEvent.profileBlock(.chat, blockedUsersIds: userIds)
        tracker.trackEvent(blockUserEvent)
    }
    
    private func trackUnblockUsers(_ userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.chat, unblockedUsersIds: userIds)
        tracker.trackEvent(unblockUserEvent)
    }
    
    // MARK: - Paginable
    
    func retrievePage(_ page: Int) {
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
                strongSelf.updateLoadedMessages(newMessages: chat.messages, page: page)

                if strongSelf.chatStatus == .forbidden {
                    strongSelf.showScammerDisclaimerMessage()
                    strongSelf.delegate?.vmUpdateChatInteraction(false)
                } else {
                    strongSelf.checkSellerDidntAnswer(chat.messages, page: page)
                    strongSelf.delegate?.vmDidRefreshChatMessages()
                    strongSelf.afterRetrieveChatMessagesEvents()
                    if strongSelf.featureFlags.newQuickAnswers {
                        strongSelf.checkShouldShowDirectAnswers(messages: chat.messages)
                    }
                }
            } else if let error = result.error {
                switch (error) {
                case .notFound:
                    //The chat doesn't exist yet, so this must be a new conversation -> this is success
                    strongSelf.isLastPage = true
                    strongSelf.shouldSendFirstMessageEvent = true
                    strongSelf.updateLoadedMessages(newMessages: [], page: page)

                    strongSelf.delegate?.vmDidRefreshChatMessages()
                    strongSelf.afterRetrieveChatMessagesEvents()
                    if strongSelf.featureFlags.newQuickAnswers {
                        strongSelf.checkShouldShowDirectAnswers(messages: [])
                    }
                case .network, .unauthorized, .internalError, .forbidden, .tooManyRequests, .userNotVerified, .serverError:
                    strongSelf.delegate?.vmDidFailRetrievingChatMessages()
                }
            }
            strongSelf.isLoading = false
        }
    }

    private func updateLoadedMessages(newMessages: [Message], page: Int) {
        // Add message disclaimer (message flagged)
        let mappedChatMessages = newMessages.map(chatViewMessageAdapter.adapt)
        var chatMessages = chatViewMessageAdapter.addDisclaimers(mappedChatMessages,
                                                                 disclaimerMessage: messageSuspiciousDisclaimerMessage)
        // Add user info as 1st message
        if let userInfoMessage = userInfoMessage, isLastPage {
            chatMessages += [userInfoMessage]
        }
        // Add disclaimer at the bottom of the first page
        if let bottomDisclaimerMessage = bottomDisclaimerMessage, page == 0 {
            chatMessages = [bottomDisclaimerMessage] + chatMessages
        }
        if page == 0 {
            loadedMessages = chatMessages
        } else {
            loadedMessages += chatMessages
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

    private func checkSellerDidntAnswer(_ messages: [Message], page: Int) {
        guard page == firstPage else { return }
        guard !isMyProduct else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        guard let oldestMessageDate = messages.last?.createdAt else { return }

        let calendar = Calendar.current

        guard let twoDaysAgo = (calendar as NSCalendar).date(byAdding: .day, value: -2, to: Date(), options: []) else { return }
        let recentSellerMessages = messages.filter { $0.userId != myUserId && $0.createdAt?.compare(twoDaysAgo) == .orderedDescending }

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

    private func checkShouldShowDirectAnswers(messages: [Message]) {
        // If there's no previous message from me, we should show direct answers
        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        for message in messages {
            guard message.userId != myUserId else { return }
        }
        userDirectAnswersEnabled.value = true
    }
}


// MARK: - DirectAnswers

extension OldChatViewModel: DirectAnswersPresenterDelegate {
    
    var directAnswers: [DirectAnswer] {
        let emptyAction: () -> Void = { [weak self] in
            self?.clearProductSoldDirectAnswer()
        }
        if featureFlags.freePostingModeAllowed && product.price.free {
            if isBuyer {
                var directAnswers = [DirectAnswer(text: LGLocalizedString.directAnswerInterested, action: emptyAction),
                                     DirectAnswer(text: LGLocalizedString.directAnswerFreeStillHave, action: emptyAction),
                                     DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: emptyAction)]
                if !featureFlags.newQuickAnswers {
                    directAnswers.append(DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction))
                }
                return directAnswers
            } else {
                var directAnswers = [DirectAnswer(text: LGLocalizedString.directAnswerFreeYours, action: emptyAction),
                                     DirectAnswer(text: LGLocalizedString.directAnswerFreeAvailable, action: emptyAction),
                                     DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: emptyAction)]
                if !featureFlags.newQuickAnswers {
                    directAnswers.append(DirectAnswer(text: LGLocalizedString.directAnswerFreeNoAvailable, action: emptyAction))
                }
                return directAnswers
            }
        } else {
            if isBuyer {
                if featureFlags.newQuickAnswers {
                    return [DirectAnswer(text: LGLocalizedString.directAnswerStillAvailable, action: emptyAction),
                            DirectAnswer(text: LGLocalizedString.directAnswerIsNegotiable, action: emptyAction),
                            DirectAnswer(text: LGLocalizedString.directAnswerCondition, action: emptyAction)]
                } else {
                    return [DirectAnswer(text: LGLocalizedString.directAnswerInterested, action: emptyAction),
                            DirectAnswer(text: LGLocalizedString.directAnswerIsNegotiable, action: emptyAction),
                            DirectAnswer(text: LGLocalizedString.directAnswerLikeToBuy, action: emptyAction),
                            DirectAnswer(text: LGLocalizedString.directAnswerMeetUp, action: emptyAction),
                            DirectAnswer(text: LGLocalizedString.directAnswerNotInterested, action: emptyAction)]
                }
            } else {
                if featureFlags.newQuickAnswers {
                    return [DirectAnswer(text: LGLocalizedString.directAnswerStillForSale, action: emptyAction),
                            DirectAnswer(text: LGLocalizedString.directAnswerProductSold, action: { [weak self] in
                                self?.onProductSoldDirectAnswer()
                                }),
                            DirectAnswer(text: LGLocalizedString.directAnswerWhatsOffer, action: emptyAction)]
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
    }
    
    func directAnswersDidTapAnswer(_ controller: DirectAnswersPresenter, answer: DirectAnswer) {
        if featureFlags.newQuickAnswers {
            delegate?.vmShowKeyboard()
        }
        if let actionBlock = answer.action {
            actionBlock()
        }
        sendText(answer.text, isQuickAnswer: true)
    }
    
    func directAnswersDidTapClose(_ controller: DirectAnswersPresenter) {
        showDirectAnswers(false)
    }

    fileprivate func toggleDirectAnswers() {
        showDirectAnswers(!userDirectAnswersEnabled.value)
    }

    fileprivate func showDirectAnswers(_ show: Bool) {
        if !featureFlags.newQuickAnswers {
            keyValueStorage.userSaveChatShowDirectAnswersForKey(userDefaultsSubKey, value: show)
        }
        userDirectAnswersEnabled.value = show
    }
}


// MARK: - UserInfo

fileprivate extension OldChatViewModel {
    func retrieveInterlocutorInfo() {
        guard let otherUserId = otherUser?.objectId else { return }
        userRepository.show(otherUserId, includeAccounts: true) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let userWaccounts = result.value else { return }
            strongSelf.otherUser = userWaccounts
            if let userInfoMessage = strongSelf.userInfoMessage, strongSelf.shouldShowOtherUserInfo {
                strongSelf.loadedMessages += [userInfoMessage]
                strongSelf.delegate?.vmDidRefreshChatMessages()
            }
        }
    }
}


// MARK: - User verification & Second step login

fileprivate extension OldChatViewModel {
    func loginAndResend(_ text: String, isQuickAnswer: Bool, type: MessageType) {
        let completion = { [weak self] in
            guard let strongSelf = self else { return }
            guard !strongSelf.isMyProduct else {
                //A user cannot have a conversation with himself
                strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.chatWithYourselfAlertMsg) {
                    [weak self] in
                    self?.delegate?.vmClose()
                }
                return
            }
            strongSelf.autoKeyboardEnabled = true
            strongSelf.chat = LocalChat(product: strongSelf.product , myUser: strongSelf.myUserRepository.myUser)
            // Setting the buyer
            strongSelf.initUsers()
            strongSelf.afterRetrieveMessagesBlock = { [weak self] in
                // Updating with real data
                self?.initUsers()
                // In case there were messages in the conversation, don't send the message automatically.
                guard let messages = self?.chat.messages, messages.isEmpty else {
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
        delegate?.ifLoggedInThen(.askQuestion, loginStyle: .popup(LGLocalizedString.chatLoginPopupText),
                                 loggedInAction: completion, elsePresentSignUpWithSuccessAction: completion)
    }
}


// MARK: - Related products

extension OldChatViewModel: ChatRelatedProductsViewDelegate {

    func relatedProductsViewDidShow(_ view: ChatRelatedProductsView) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsStart(relatedShownReason))
    }

    func relatedProductsView(_ view: ChatRelatedProductsView, showProduct product: Product, atIndex index: Int,
                             productListModels: [ProductCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsComplete(index, shownReason: relatedShownReason))
        let data = ProductDetailData.productList(product: product, cellModels: productListModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        navigator?.openProduct(data, source: .chat, showKeyboardOnFirstAppearIfNeeded: false)
    }
}


// MARK: - MessageType tracking

extension MessageType {
    var trackingMessageType: EventParameterMessageType {
        switch self {
        case .text:
            return .text
        case .offer:
            return .offer
        case .sticker:
            return .sticker
        }
    }
}


// MARK: - Related products for express chat

extension OldChatViewModel {

    static let maxRelatedProductsForExpressChat = 4

    fileprivate func retrieveRelatedProducts() {
        guard isBuyer else { return }
        guard let productId = product.objectId else { return }
        productRepository.indexRelated(productId: productId, params: RetrieveProductsParams()) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                strongSelf.relatedProducts = strongSelf.relatedWithoutMyProducts(value)
                strongSelf.updateExpressChatBanner()
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

    private func updateExpressChatBanner() {
        hasRelatedProducts.value = !relatedProducts.isEmpty
    }

    fileprivate func launchExpressChatTimer() {
        let _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateBannerTimerStatus),
                                                       userInfo: nil, repeats: false)
    }

    private dynamic func updateBannerTimerStatus() {
        expressBannerTimerFinished.value = true
    }

    fileprivate func expressChatMessageSentForCurrentProduct() -> Bool {
        guard let productId = product.objectId else { return false }
        for productSentId in keyValueStorage.userProductsWithExpressChatMessageSent {
            if productSentId == productId { return true }
        }
        return false
    }
}
