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

    func vmDidUpdateProduct(messageToShow message: String?)

    func vmShowReportUser(_ reportUserViewModel: ReportUsersViewModel)
    
    func vmShowSafetyTips()
    func vmShowPrePermissions(_ type: PrePermissionType)
    func vmShowKeyboard()
    func vmHideKeyboard(animated: Bool)
    func vmShowMessage(_ message: String, completion: (() -> ())?)
    func vmShowOptionsList(_ options: [String], actions: [() -> Void])
    func vmShowQuestion(title: String, message: String, positiveText: String, positiveAction: (() -> Void)?,
                              positiveActionStyle: UIAlertActionStyle?, negativeText: String, negativeAction: (() -> Void)?,
                              negativeActionStyle: UIAlertActionStyle?)
    func vmClose()
    
    func vmUpdateRelationInfoView(_ status: ChatInfoViewStatus)
    func vmUpdateChatInteraction(_ enabled: Bool)
    
    func vmDidUpdateStickers()
    func vmClearText()

    func vmUpdateReviewButton()
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
        return listing.title
    }
    var productName: String? {
        return listing.title
    }
    var productImageUrl: URL? {
        return listing.thumbnail?.fileURL
    }
    var productUserName: String? {
        return listing.user.name
    }
    var productPrice: String {
        return listing.priceString(freeModeAllowed: featureFlags.freePostingModeAllowed)
    }
    var listingStatus: ListingStatus {
        return listing.status
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
    var relatedListings: [Listing] = []

    var scammerDisclaimerMessage: ChatViewMessage {
        return chatViewMessageAdapter.createScammerDisclaimerMessage(
            isBuyer: isBuyer, userName: otherUser?.name, action: safetyTipsAction)
    }

    var messageSuspiciousDisclaimerMessage: ChatViewMessage {
        var action: (() -> Void)? = blockUserAction
        if let relations = userRelation, relations.isBlocked {
            action = nil
        }
        return chatViewMessageAdapter.createMessageSuspiciousDisclaimerMessage(action)
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
    
    var blockUserAction: () -> Void {
        return { [weak self] in
            self?.blockUser(position: .safetyPopup)
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
        return !keyValueStorage[.userRatingTooltipAlreadyShown]
    }
    
    var shouldShowStickerBadge: Bool

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
    fileprivate let listingRepository: ListingRepository
    fileprivate let userRepository: UserRepository
    fileprivate let stickersRepository: StickersRepository
    fileprivate let chatViewMessageAdapter: ChatViewMessageAdapter
    fileprivate let tracker: Tracker
    fileprivate let featureFlags: FeatureFlaggeable
    fileprivate let configManager: ConfigManager
    fileprivate let sessionManager: SessionManager
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let deepLinksRouter: DeepLinksRouter
    fileprivate var shouldSendFirstMessageEvent: Bool = false
    fileprivate var chat: Chat
    fileprivate var listing: Listing
    fileprivate var source: EventParameterTypePage
    private var isDeleted = false
    private var shouldAskProductSold: Bool = false
    fileprivate var userDefaultsSubKey: String {
        return "\(String(describing: listing.objectId)) + \(buyer?.objectId ?? "offline")"
    }
    
    fileprivate var loadedMessages: [ChatViewMessage]
    private var buyer: LocalUser?
    fileprivate var otherUser: LocalUser?
    fileprivate var afterRetrieveMessagesBlock: (() -> Void)?
    fileprivate var autoKeyboardEnabled = true

    fileprivate var isMyProduct: Bool {
        guard let productUserId = listing.user.objectId, let myUserId = myUserRepository.myUser?.objectId else { return false }
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
    
    convenience init?(listing: Listing, source: EventParameterTypePage) {
        let myUserRepository = Core.myUserRepository
        let chat = LocalChat(listing: listing, myUserProduct: LocalUser(user: myUserRepository.myUser))
        self.init(chat: chat, source: source)
    }

    convenience init?(chat: Chat, source: EventParameterTypePage) {
        self.init(chat: chat,
                  source: source,
                  myUserRepository: Core.myUserRepository,
                  chatRepository: Core.oldChatRepository,
                  listingRepository: Core.listingRepository,
                  userRepository: Core.userRepository,
                  stickersRepository: Core.stickersRepository,
                  tracker: TrackerProxy.sharedInstance,
                  configManager: LGConfigManager.sharedInstance,
                  sessionManager: Core.sessionManager,
                  keyValueStorage: KeyValueStorage.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance,
                  deepLinksRouter: LGDeepLinksRouter.sharedInstance)
    }

    init?(chat: Chat,
          source: EventParameterTypePage,
          myUserRepository: MyUserRepository,
          chatRepository: OldChatRepository,
          listingRepository: ListingRepository,
          userRepository: UserRepository,
          stickersRepository: StickersRepository,
          tracker: Tracker,
          configManager: ConfigManager,
          sessionManager: SessionManager,
          keyValueStorage: KeyValueStorage,
          featureFlags: FeatureFlaggeable,
          deepLinksRouter: DeepLinksRouter) {
        self.chat = chat
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.listingRepository = listingRepository
        self.userRepository = userRepository
        self.stickersRepository = stickersRepository
        self.chatViewMessageAdapter = ChatViewMessageAdapter()
        self.tracker = tracker
        self.featureFlags = featureFlags
        self.configManager = configManager
        self.sessionManager = sessionManager
        self.keyValueStorage = keyValueStorage
        self.deepLinksRouter = deepLinksRouter
        self.loadedMessages = []
        self.listing = chat.listing
        self.source = source
        if let myUser = myUserRepository.myUser {
            self.isDeleted = chat.isArchived(myUser: myUser)
        }
        self.shouldShowStickerBadge = !keyValueStorage[.stickersBadgeAlreadyShown]
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
            setupExpressChat()
            trackVisit()
        }

       refreshChatInfo()

        if firstTime {
            retrieveInterlocutorInfo()
            setStickerBadge()
        }
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
        guard !relatedListings.isEmpty else { return }
        guard let listingId = listing.objectId else { return }
        navigator?.openExpressChat(relatedListings, sourceListingId: listingId, manualOpen: false)
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
            let data = ListingDetailData.listingAPI(listing: listing, thumbnailImage: nil, originFrame: nil)
            navigator?.openListing(data, source: .chat, showKeyboardOnFirstAppearIfNeeded: false)
        }
    }
    
    func userInfoPressed() {
        switch chatStatus {
        case .forbidden, .userPendingDelete, .userDeleted:
            break
        case .productDeleted, .available, .blocked, .blockedBy, .productSold:
            guard let user = otherUser else { return }
            let data = UserDetailData.userAPI(user: user, source: .chat)
            navigator?.openUser(data)
        }
    }

    func reviewUserPressed() {
        keyValueStorage[.userRatingTooltipAlreadyShown] = true
        guard let otherUser = otherUser, let reviewData = RateUserData(user: otherUser) else { return }
        navigator?.openUserRating(.chat, data: reviewData)
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
        if chat.isSaved && directAnswersState.value != .notAvailable {
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
                actions.append({ [weak self] in self?.blockUserPressed(position: .threeDots) })
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
    
    func send(sticker: Sticker) {
        sendMessage(type: .chatSticker(sticker))
    }
    
    func send(text: String) {
        sendMessage(type: .text(text))
    }

    func send(quickAnswer: QuickAnswer) {
        sendMessage(type: .quickAnswer(quickAnswer))
    }
    
    func isMatchingConversationData(_ data: ConversationData) -> Bool {
        switch data {
        case .conversation(let conversationId):
            return conversationId == chat.objectId
        case let .productBuyer(productId, buyerId):
            return productId == listing.objectId && buyerId == buyer?.objectId
        }
    }

    func stickersShown() {
        keyValueStorage[.stickersBadgeAlreadyShown] = true
        shouldShowStickerBadge = false
        delegate?.vmDidUpdateProduct(messageToShow: nil)
    }

    func bannerActionButtonTapped() {
        guard let listingId = listing.objectId else { return }
        navigator?.openExpressChat(relatedListings, sourceListingId: listingId, manualOpen: true)
    }

    func directAnswersButtonPressed() {
        toggleDirectAnswers()
    }

    
    // MARK: - private methods
    
    fileprivate func initUsers() {
        if otherUser == nil || otherUser?.objectId == nil {
            if let myUser = myUserRepository.myUser {
                self.otherUser = LocalUser(userListing: chat.otherUser(myUser: myUser))
            } else {
                self.otherUser = LocalUser(userListing: chat.userTo)
            }
        }

        if let _ = myUserRepository.myUser {
            self.buyer = LocalUser(userListing: chat.buyer)
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
            guard let listingId = self?.listing.objectId else {return .hidden }
            if $0 { return .visible(listingId: listingId) }
            guard let didntAnswer = $1 else { return .loading } // If still checking if seller didn't answer. set loading state
            return didntAnswer ? .visible(listingId: listingId) : .hidden
        }
        .bindTo(relatedProductsState).addDisposableTo(disposeBag)

        let expressBannerTriggered = Observable.combineLatest(firstInteractionDone.asObservable(),
                                                              expressBannerTimerFinished.asObservable()) { $0 || $1 }
        /**
         Express chat banner is shown after 3 seconds or 1st interaction if:
            - the listing has related products
            - we're not showing the related products already over the keyboard
            - user hasn't SENT messages via express chat for this listing
         */
        Observable.combineLatest(expressBannerTriggered,
            hasRelatedProducts.asObservable(),
            relatedProductsState.asObservable().map { (state: ChatRelatedItemsState) -> Bool in return state.isVisible },
        expressMessagesAlreadySent.asObservable()) { $0 && $1 && !$2 && !$3 }
            .distinctUntilChanged().bindTo(shouldShowExpressBanner).addDisposableTo(disposeBag)

        userDirectAnswersEnabled.value = keyValueStorage.userLoadChatShowDirectAnswersForKey(userDefaultsSubKey)
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
        deepLinksRouter.chatDeepLinks.subscribeNext { [weak self] deepLink in
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

    fileprivate func sendMessage(type: ChatWrapperMessageType) {
        guard myUserRepository.myUser != nil else {
            loginAndResend(type: type)
            return
        }

        if isSendingMessage.value { return }
        let message = type.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard message.characters.count > 0 else { return }
        guard let toUserId = otherUser?.objectId, let productId = listing.objectId else { return }
        if type.isUserText {
            delegate?.vmClearText()
        }
        isSendingMessage.value = true

        let chatType = type.oldChatType
        chatRepository.sendMessage(chatType, message: message, listingId: productId, recipientId: toUserId) { [weak self] result in
            guard let strongSelf = self else { return }
            if let sentMessage = result.value, let adapter = self?.chatViewMessageAdapter {
                //This is required to be called BEFORE any message insertion
                strongSelf.trackMessageSent(type: type)

                let viewMessage = adapter.adapt(sentMessage)
                strongSelf.loadedMessages.insert(viewMessage, at: 0)
                strongSelf.delegate?.vmDidSucceedSendingMessage(0)
                strongSelf.afterSendMessageEvents()
            } else if let error = result.error {
                strongSelf.trackMessageSentError(type: type, error: error)
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
            var okText: String
            var alertTitle: String
            var soldQuestionText: String
            
            if listing.price.free {
                okText = LGLocalizedString.directAnswerGivenAwayQuestionOk
                alertTitle = LGLocalizedString.directAnswerGivenAwayQuestionTitle
                soldQuestionText = LGLocalizedString.directAnswerGivenAwayQuestionMessage
            } else {
                okText = LGLocalizedString.directAnswerSoldQuestionOk
                alertTitle = LGLocalizedString.directAnswerSoldQuestionTitle
                soldQuestionText = LGLocalizedString.directAnswerSoldQuestionMessage
            }
            shouldAskProductSold = false
            delegate?.vmShowQuestion(title: alertTitle,
                                     message: soldQuestionText,
                                     positiveText: okText,
                                     positiveAction: { [weak self] in
                                        self?.markProductAsSold()
                },
                                     positiveActionStyle: nil,
                                     negativeText: LGLocalizedString.commonCancel, negativeAction: nil, negativeActionStyle: nil)
        } else if LGPushPermissionsManager.sharedInstance.shouldShowPushPermissionsAlertFromViewController(.chat(buyer: isBuyer)) {
            delegate?.vmShowPrePermissions(.chat(buyer: isBuyer))
        } else if LGRatingManager.sharedInstance.shouldShowRating {
            delegate?.vmHideKeyboard(animated: true)
            delay(1) { [weak self] in
                self?.delegate?.vmHideKeyboard(animated: true)
                self?.navigator?.openAppRating(.chat)
            }
        }
        delegate?.vmUpdateReviewButton()
    }

    private func setStickerBadge() {
        guard chatEnabled && !keyValueStorage[.stickersBadgeAlreadyShown] else { return }
        shouldShowStickerBadge = true
    }
    

    /**
     Retrieves the specified number of the newest messages
     
     - parameter numResults: the num of messages to retrieve
     */
    private func retrieveFirstPageWithNumResults(_ numResults: Int) {
        
        guard let listingId = listing.objectId, let userBuyerId = buyer?.objectId else { return }
        
        guard canRetrieve else { return }
        
        isLoading = true
        chatRepository.retrieveMessagesWithProductId(listingId, buyerId: userBuyerId, page: 0, numResults: numResults) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let chat = result.value {
                strongSelf.chat = chat

                strongSelf.updateDisclaimers()
                strongSelf.afterRetrieveChatMessagesEvents()
                strongSelf.checkSellerDidntAnswer(chat.messages, page: strongSelf.firstPage)
            }
            strongSelf.isLoading = false
        }
    }
    
    fileprivate func updateDisclaimers() {
        let chatMessages = chat.messages.map(chatViewMessageAdapter.adapt)
        let newChatMessages = chatViewMessageAdapter
            .addDisclaimers(chatMessages, disclaimerMessage: messageSuspiciousDisclaimerMessage)
        
        let insertedMessagesInfo = OldChatViewModel.insertNewMessagesAt(loadedMessages,
                                                                        newMessages: newChatMessages)
        loadedMessages = insertedMessagesInfo.messages
        delegate?.vmUpdateAfterReceivingMessagesAtPositions(insertedMessagesInfo.indexes,
                                                                       isUpdate: insertedMessagesInfo.isUpdate)
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
        guard let listingId = listing.objectId, let userBuyerId = buyer?.objectId else { return }
        //We just get the last one as backend will mark all of them as read
        chatRepository.retrieveMessagesWithProductId(listingId, buyerId: userBuyerId, page: 0, numResults: 1, completion: nil)
    }
    
    fileprivate func onProductSoldDirectAnswer() {
        if chatStatus == .available {
            shouldAskProductSold = true
        }
    }
    
    fileprivate func clearProductSoldDirectAnswer() {
        shouldAskProductSold = false
    }
    
    fileprivate func blockUserPressed(position: EventParameterBlockButtonPosition) {
        blockUser(position: position)
    }
    
    private func blockUser(position: EventParameterBlockButtonPosition) {
        
        delegate?.vmShowQuestion(title: LGLocalizedString.chatBlockUserAlertTitle,
                                 message: LGLocalizedString.chatBlockUserAlertText,
                                 positiveText: LGLocalizedString.chatBlockUserAlertBlockButton,
                                 positiveAction: { [weak self] in
                                    self?.blockUser(position: position) { [weak self] success in
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
    
    private func blockUser(position: EventParameterBlockButtonPosition, completion: @escaping (_ success: Bool) -> ()) {
        
        guard let user = otherUser, let userId = user.objectId else {
            completion(false)
            return
        }
        
        trackBlockUsers([userId], buttonPosition: position)
        
        self.userRepository.blockUserWithId(userId) { [weak self] result -> Void in
            let success = result.value != nil
            completion(success)
            
            if success {
                self?.delegate?.vmUpdateReviewButton()
                self?.updateDisclaimers()
            }
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
        
        self.userRepository.unblockUserWithId(userId) { [weak self] result -> Void in
            let success = result.value != nil
            completion(success)
            
            if success {
                self?.delegate?.vmUpdateReviewButton()
                self?.updateDisclaimers()
            }
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
                                            self?.navigator?.closeChatDetail()
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
        listingRepository.markAsSold(listing: listing) { [weak self] result in
            self?.delegate?.vmHideLoading(nil) { [weak self] in
                guard let strongSelf = self else { return }
                if let value = result.value {
                    strongSelf.listing = value
                    strongSelf.delegate?.vmDidUpdateProduct(messageToShow: LGLocalizedString.productMarkAsSoldSuccessMessage)
                    strongSelf.delegate?.vmUpdateRelationInfoView(strongSelf.chatStatus)
                    strongSelf.trackMarkAsSold()
                } else {
                    strongSelf.delegate?.vmShowMessage(LGLocalizedString.productMarkAsSoldErrorGeneric, completion: nil)
                }
            }
        }
    }

    
    // MARK: Tracking
    
    private func trackMessageSent(type: ChatWrapperMessageType) {
        guard let info = buildSendMessageInfo(withType: type, error: nil) else { return }

        if shouldSendFirstMessageEvent && !didSendMessage {
            shouldSendFirstMessageEvent = false
            tracker.trackEvent(TrackerEvent.firstMessage(info: info, productVisitSource: .unknown))
        }
        tracker.trackEvent(TrackerEvent.userMessageSent(info: info))
    }

    private func trackMessageSentError(type: ChatWrapperMessageType, error: RepositoryError) {
        guard let info = buildSendMessageInfo(withType: type, error: error) else { return }
        tracker.trackEvent(TrackerEvent.userMessageSentError(info: info))
    }
    
    private func trackBlockUsers(_ userIds: [String], buttonPosition: EventParameterBlockButtonPosition) {
        let blockUserEvent = TrackerEvent.profileBlock(.chat, blockedUsersIds: userIds, buttonPosition: buttonPosition)
        tracker.trackEvent(blockUserEvent)
    }
    
    private func trackUnblockUsers(_ userIds: [String]) {
        let unblockUserEvent = TrackerEvent.profileUnblock(.chat, unblockedUsersIds: userIds)
        tracker.trackEvent(unblockUserEvent)
    }
    
    private func trackVisit() {
        let chatWindowOpen = TrackerEvent.chatWindowVisit(source, chatEnabled: chatEnabled)
        tracker.trackEvent(chatWindowOpen)
    }

    private func trackMarkAsSold() {
        let trackingInfo = MarkAsSoldTrackingInfo.make(listing: listing,
                                                       isBumpedUp: .notAvailable,
                                                       isFreePostingModeAllowed: featureFlags.freePostingModeAllowed,
                                                       typePage: .chat)
        let markAsSold = TrackerEvent.productMarkAsSold(trackingInfo: trackingInfo)
        tracker.trackEvent(markAsSold)
    }

    private func buildSendMessageInfo(withType type: ChatWrapperMessageType, error: RepositoryError?) -> SendMessageTrackingInfo? {
        let sellerRating: Float? = isBuyer ? otherUser?.ratingAverage : myUserRepository.myUser?.ratingAverage
        let sendMessageInfo = SendMessageTrackingInfo()
            .set(listing: listing, freePostingModeAllowed: featureFlags.freePostingModeAllowed)
            .set(interlocutorId: otherUser?.objectId)
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
    
    // MARK: - Paginable
    
    func retrievePage(_ page: Int) {
        guard let listingId = listing.objectId, let userBuyerId = buyer?.objectId else { return }
        
        delegate?.vmDidStartRetrievingChatMessages(hasData: !loadedMessages.isEmpty)
        isLoading = true
        chatRepository.retrieveMessagesWithProductId(listingId, buyerId: userBuyerId, page: page, numResults: resultsPerPage) {
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
        // Add disclaimer at the bottom of the first page
        if let bottomDisclaimerMessage = bottomDisclaimerMessage, page == 0 {
            chatMessages = [bottomDisclaimerMessage] + chatMessages
        }
        if page == 0 {
            loadedMessages = chatMessages
        } else {
            loadedMessages += chatMessages
        }
        // Add user info as 1st message
        addUserInfoMessageToChat()
    }

    private func afterRetrieveChatMessagesEvents() {
        afterRetrieveMessagesBlock?()
        afterRetrieveMessagesBlock = nil

        if shouldShowSafetyTips {
            delegate?.vmShowSafetyTips()
        }
        delegate?.vmUpdateReviewButton()
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
    
    var directAnswers: [QuickAnswer] {
        let isFree = featureFlags.freePostingModeAllowed && listing.price.free
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
}


// MARK: - UserInfo

fileprivate extension OldChatViewModel {
    func retrieveInterlocutorInfo() {
        guard let otherUserId = otherUser?.objectId else { return }
        userRepository.show(otherUserId) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let user = result.value else { return }
            strongSelf.otherUser = LocalUser(user: user)
            strongSelf.addUserInfoMessageToChat()
            strongSelf.delegate?.vmDidRefreshChatMessages()
        }
    }

    fileprivate func addUserInfoMessageToChat() {
        guard let userInfoMessage = userInfoMessage else { return }
        guard isLastPage else { return }
        guard objectCount > 0 else { return }
        let lastMessageType = loadedMessages[objectCount-1].type
        switch lastMessageType {
        case .userInfo:
            loadedMessages[objectCount-1] = userInfoMessage
            return
        case .disclaimer, .offer, .sticker, .text:
            loadedMessages.append(userInfoMessage)
        }
    }
}


// MARK: - User verification & Second step login

fileprivate extension OldChatViewModel {
    func loginAndResend(type: ChatWrapperMessageType) {
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
            let myLocalUser = LocalUser(user: strongSelf.myUserRepository.myUser)
            strongSelf.chat = LocalChat(listing: strongSelf.listing , myUserProduct: myLocalUser)
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
                self?.sendMessage(type: type)
            }
            strongSelf.retrieveFirstPage()
            strongSelf.retrieveUsersRelation()
        }
        /* Needed to avoid showing the keyboard while login in (as the login is overCurrentContext) so chat will become
         'visible' while login screen is there */
        autoKeyboardEnabled = false
        delegate?.vmHideKeyboard(animated: false) // this forces SLKTextViewController to have correct keyboard info
        navigator?.openLoginIfNeededFromChatDetail(from: .askQuestion, loggedInAction: completion)
    }
}


// MARK: - Related products

extension OldChatViewModel: ChatRelatedProductsViewDelegate {

    func relatedProductsViewDidShow(_ view: ChatRelatedProductsView) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsStart(relatedShownReason))
    }

    func relatedProductsView(_ view: ChatRelatedProductsView, showListing listing: Listing, atIndex index: Int,
                             productListModels: [ListingCellModel], requester: ProductListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsComplete(index, shownReason: relatedShownReason))
        let data = ListingDetailData.listingList(listing: listing, cellModels: productListModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        navigator?.openListing(data, source: .chat, showKeyboardOnFirstAppearIfNeeded: false)
    }
}


// MARK: - Related products for express chat

extension OldChatViewModel {

    static let maxRelatedProductsForExpressChat = 4

    fileprivate func retrieveRelatedProducts() {
        guard isBuyer else { return }
        guard let productId = listing.objectId else { return }
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
        guard let productId = listing.objectId else { return false }
        for productSentId in keyValueStorage.userProductsWithExpressChatMessageSent {
            if productSentId == productId { return true }
        }
        return false
    }
}
