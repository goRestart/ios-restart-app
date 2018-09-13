import LGCoreKit
import RxSwift
import LGComponents

protocol ChatViewModelDelegate: BaseViewModelDelegate {

    func vmDidFailRetrievingChatMessages()
    
    func vmDidPressReportUser(_ reportUserViewModel: ReportUsersViewModel)

    func vmDidRequestSafetyTips()

    func vmDidSendMessage()
    func vmDidEndEditing(animated: Bool)
    func vmDidBeginEditing()
    
    func vmDidRequestShowPrePermissions(_ type: PrePermissionType)
    func vmDidNotifyMessage(_ message: String, completion: (() -> ())?)

    func vmAskPhoneNumber()
}

struct EmptyConversation: ChatConversation {
    var objectId: String?
    var unreadMessageCount: Int = 0
    var lastMessageSentAt: Date? = nil
    var listing: ChatListing? = nil
    var interlocutor: ChatInterlocutor? = nil
    var amISelling: Bool
    var interlocutorIsTyping = Variable<Bool>(false)
    
    init(objectId: String?,
         unreadMessageCount: Int,
         lastMessageSentAt: Date?,
         amISelling: Bool,
         listing: ChatListing?,
         interlocutor: ChatInterlocutor?) {
        
        self.objectId = objectId
        self.unreadMessageCount = unreadMessageCount
        self.lastMessageSentAt = lastMessageSentAt
        self.listing = listing
        self.interlocutor = interlocutor
        self.amISelling = amISelling
    }
}

struct InterlocutorProfessionalInfo {
    var isProfessional: Bool
    var phoneNumber: String?
}

enum DirectAnswersState {
    case notAvailable, visible, hidden
}

class ChatViewModel: ChatBaseViewModel {
    
    static let typingStartedThrottleTime: TimeInterval = 15
    static let userIsTypingTimeoutTime: TimeInterval = 10
    
    // MARK: - Properties
    
    // Protocols
    weak var delegate: ChatViewModelDelegate?
    var navigator: ChatDetailNavigator?
    
    // Paginable
    var resultsPerPage: Int = SharedConstants.numMessagesPerPage
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return messages.value.count
    }

    // Connectivity
    private let rx_wsChatStatus = Variable<WSChatStatus>(.closed)
    let rx_connectionBarStatus = Variable<ChatConnectionBarStatus>(.wsConnected)


    // Public Model info
    let title = Variable<String>("")
    let listingName = Variable<String>("")
    let listingImageUrl = Variable<URL?>(nil)
    let listingPrice = Variable<String>("")
    let listingIsFree = Variable<Bool>(false)
    let interlocutorAvatarURL = Variable<URL?>(nil)
    let interlocutorName = Variable<String>("")
    let interlocutorId = Variable<String?>(nil)
    let interlocutorIsVerified = Variable<Bool>(false)
    let stickers = Variable<[Sticker]>([])
    let chatStatus = Variable<ChatInfoViewStatus>(.available)
    let chatEnabled = Variable<Bool>(true)
    let textBoxVisible = Variable<Bool>(true)
    let directAnswersState = Variable<DirectAnswersState>(.notAvailable)
    let userIsTyping = Variable<Bool>(false)
    let messages = CollectionVariable<ChatViewMessage>([])
    var relatedListings: [Listing] = []
    var shouldTrackFirstMessage: Bool = false
    let shouldShowExpressBanner = Variable<Bool>(false)
    let relatedListingsState = Variable<ChatRelatedItemsState>(.loading)
    var smartQuickAnswers: ChatSmartQuickAnswers?
    let shouldUpdateQuickAnswers = Variable<[QuickAnswer]?>(nil)
    let interlocutorProfessionalInfo = Variable<InterlocutorProfessionalInfo>(InterlocutorProfessionalInfo(isProfessional: false, phoneNumber: nil))
    let lastMessageSentType = Variable<ChatWrapperMessageType?>(nil)
    let messagesDidFinishRefreshing = Variable<Bool>(false)
    var interlocutorTypingChatViewMessage: ChatViewMessage?
    let chatBoxText = Variable<String>("")
    var userIsTypingTimeout: Timer?
    var stoppedTypingEventEnabled: Bool = true
    let chatUserInteractionsEnabled = Variable<Bool>(true)

    var keyForTextCaching: String { return userDefaultsSubKey }
    
    let showStickerBadge = Variable<Bool>(!KeyValueStorage.sharedInstance[.stickersBadgeAlreadyShown])
    
    var predefinedMessage: String? // is writen in the text field when opening the chat
    var openChatAutomaticMessage: ChatWrapperMessageType?  // is SENT when opening the chat
    var professionalBannerHasCallAction: Bool {
        return PhoneCallsHelper.deviceCanCall
    }
    fileprivate var hasSentAutomaticAnswerForPhoneMessage: Bool = false
    fileprivate var hasSentAutomaticAnswerForOtherMessage: Bool = false
    fileprivate var hasShownAskedPhoneMessage: Bool = false

    var meetingsEnabled: Bool {
        return featureFlags.chatNorris.isActive
    }
    
    var isUserDummy: Bool {
        guard let userType = conversation.value.interlocutor?.userType else { return false }
        if case userType = UserType.dummy {
            return true
        }
        return false
    }

    var showWhiteBackground: Bool {
        return featureFlags.showChatHeaderWithoutUser
    }


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
    fileprivate let hasRelatedListings = Variable<Bool>(false)
    fileprivate let expressMessagesAlreadySent = Variable<Bool>(false)
    fileprivate let interlocutorIsMuted = Variable<Bool>(false)
    private let interlocutorHasMutedYou = Variable<Bool>(false)
    fileprivate let sellerDidntAnswer = Variable<Bool?>(nil)
    fileprivate let conversation: Variable<ChatConversation>
    fileprivate var interlocutor: User?
    private let myMessagesCount = Variable<Int>(0)
    private let otherMessagesCount = Variable<Int>(0)
    fileprivate let isEmptyConversation = Variable<Bool>(true)

    fileprivate var isDeleted = false
    fileprivate var shouldAskListingSold: Bool = false
    fileprivate var listingId: String? // Only used when accessing a chat from a listing
    fileprivate var preSendMessageCompletion: ((_ type: ChatWrapperMessageType) -> Void)?
    fileprivate var afterRetrieveMessagesCompletion: (() -> Void)?

    fileprivate var showingSendMessageError = false

    fileprivate let disposeBag = DisposeBag()
    fileprivate var userIsTypingDisposeBag: DisposeBag? = DisposeBag()
    
    fileprivate var userDefaultsSubKey: String {
        return "\(String(describing: conversation.value.listing?.objectId ?? listingId)) + \(buyerId ?? "offline")"
    }

    fileprivate var isBuyer: Bool {
        return !conversation.value.amISelling
    }

    fileprivate var shouldShowOtherUserInfo: Bool {
        guard conversation.value.isSaved else { return true }
        let alreadyShown = messages.value.reduce(false) { (result, current)  in
            if case ChatViewMessageType.userInfo(_) = current.type {
                return true
            }
            return result
        }
        return !isLoading && isLastPage && !alreadyShown
    }

    fileprivate var safetyTipsAction: () -> Void {
        return { [weak self] in
            self?.delegate?.vmDidRequestSafetyTips()
        }
    }
    
    fileprivate var blockAction: () -> Void {
        return { [weak self] in
            self?.blockUserAction(buttonPosition: .safetyPopup)
        }
    }

    var listingIdentifier: String? {
        return conversation.value.listing?.objectId
    }
    
    var buyerId: String? {
        let myUserId = myUserRepository.myUser?.objectId
        let interlocutorId = conversation.value.interlocutor?.objectId
        let currentBuyer = conversation.value.amISelling ? interlocutorId : myUserId
        return currentBuyer
    }
    
    var sellerId: String? {
        return interlocutorId.value
    }
 

    fileprivate var shouldShowSafetyTips: Bool {
        guard !isUserDummy else { return false }
        return featureFlags.showChatSafetyTips && !keyValueStorage.userChatSafetyTipsShown && didReceiveMessageFromOtherUser
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
        case .forbidden, .userDeleted, .userPendingDelete, .inactiveConversation:
            return false
        case .available, .listingSold, .listingGivenAway, .listingDeleted, .blocked, .blockedBy:
            return true
        }
    }

    private var interlocutorAvatar: UIImage?
    private var defaultUserAvatarData: ChatMessageAvatarData {
        return ChatMessageAvatarData(avatarImage: interlocutorAvatar) { [weak self] in
            self?.userInfoPressed()
        }
    }
    
    // MARK: - Lifecycle

    convenience init(conversation: ChatConversation,
                     navigator: ChatDetailNavigator?,
                     source: EventParameterTypePage,
                     predefinedMessage: String?) {
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
                  source: source, ratingManager: ratingManager, pushPermissionsManager: pushPermissionsManager,
                  predefinedMessage: predefinedMessage, openChatAutomaticMessage: nil, interlocutor: nil)
    }
    
    convenience init?(listing: Listing,
                      navigator: ChatDetailNavigator?,
                      source: EventParameterTypePage,
                      openChatAutomaticMessage: ChatWrapperMessageType?,
                      interlocutor: User?) {
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
        let empty = EmptyConversation(objectId: nil, unreadMessageCount: 0, lastMessageSentAt: nil, amISelling: amISelling,
                                      listing: nil, interlocutor: nil)
        self.init(conversation: empty, myUserRepository: myUserRepository, chatRepository: chatRepository,
                  listingRepository: listingRepository, userRepository: userRepository,
                  stickersRepository: stickersRepository ,tracker: tracker, configManager: configManager,
                  sessionManager: sessionManager, keyValueStorage: keyValueStorage, navigator: navigator, featureFlags: featureFlags,
                  source: source, ratingManager: ratingManager, pushPermissionsManager: pushPermissionsManager, predefinedMessage: nil,
                  openChatAutomaticMessage: openChatAutomaticMessage, interlocutor: interlocutor)
        self.setupConversationFrom(listing: listing)
    }
    
    init(conversation: ChatConversation, myUserRepository: MyUserRepository, chatRepository: ChatRepository,
          listingRepository: ListingRepository, userRepository: UserRepository, stickersRepository: StickersRepository,
          tracker: Tracker, configManager: ConfigManager, sessionManager: SessionManager, keyValueStorage: KeyValueStorageable,
          navigator: ChatDetailNavigator?, featureFlags: FeatureFlaggeable, source: EventParameterTypePage,
          ratingManager: RatingManager, pushPermissionsManager: PushPermissionsManager, predefinedMessage: String?,
          openChatAutomaticMessage: ChatWrapperMessageType?, interlocutor: User?) {
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
        self.predefinedMessage = predefinedMessage
        self.openChatAutomaticMessage = openChatAutomaticMessage
        self.interlocutor = interlocutor
        if let isProfessional = interlocutor?.isProfessional {
            self.interlocutorProfessionalInfo.value = InterlocutorProfessionalInfo(isProfessional: isProfessional,
                                                                                   phoneNumber: interlocutor?.phone)
        } else if let userType = conversation.interlocutor?.userType, userType == .pro {
            self.interlocutorProfessionalInfo.value = InterlocutorProfessionalInfo(isProfessional: true,
                                                                                   phoneNumber: nil)
        }
        super.init()
        setupRx()
        loadStickers()
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)

        if firstTime {
            if isUserDummy {
                textBoxVisible.value = false
            }
            retrieveRelatedListings()
            setupExpressChat()
            refreshChat()
        }
        trackVisit()
    }

    func didAppear() {
        guard chatEnabled.value && !interlocutorProfessionalInfo.value.isProfessional else { return }
        delegate?.vmDidBeginEditing()
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
        guard userHasExpressChatEnabled() else { return }
        guard !userHasSeenExpressChat(for: listingId) else { return }
        navigator?.openExpressChat(relatedListings, sourceListingId: listingId, manualOpen: false)
    }
    
    private func userHasExpressChatEnabled() -> Bool {
        return keyValueStorage.userShouldShowExpressChat
    }
    
    private func userHasSeenExpressChat(for listingId: String) -> Bool {
        for productShownId in keyValueStorage.userProductsWithExpressChatAlreadyShown {
            if productShownId == listingId { return true }
        }
        return false
    }

    private func shouldShowExpressChatForListing(_ listingId: String?) -> Bool {
        guard let listingId = listingId else { return false }
        // user didn't pressed "Don't show again"
        guard keyValueStorage.userShouldShowExpressChat else { return false }
        // express chat hasn't been shown for this product
        guard !expressChatAlreadyShownForProduct(listingId) else { return false }
        return true
    }

    private func expressChatAlreadyShownForProduct(_ productId: String) -> Bool {
        for productShownId in keyValueStorage.userProductsWithExpressChatAlreadyShown {
            if productShownId == productId { return true }
        }
        return false
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
        chatRepository.showConversation(sellerId, listingId: listingId) { [weak self] result in
            if let value = result.value {
                self?.conversation.value = value
                if let autoMessage = self?.openChatAutomaticMessage {
                    self?.sendMessage(type: autoMessage)
                }
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
            self?.listingName.value = conversation.listing?.name ?? ""
            self?.listingImageUrl.value = conversation.listing?.image?.fileURL
            if let featureFlags = self?.featureFlags {
                self?.listingPrice.value = conversation.listing?.priceString(freeModeAllowed: featureFlags.freePostingModeAllowed) ?? ""
            }
            self?.listingIsFree.value = conversation.listing?.price.isFree ?? false
            if let _ = conversation.listing {
                self?.shouldUpdateQuickAnswers.value = self?.directAnswers
            }
            self?.interlocutorAvatarURL.value = conversation.interlocutor?.avatar?.fileURL
            self?.interlocutorName.value = conversation.interlocutor?.name ?? ""
            self?.interlocutorId.value = conversation.interlocutor?.objectId
        }.disposed(by: disposeBag)

        let placeHolder = Observable.combineLatest(interlocutorId.asObservable(),
                                                   interlocutorName.asObservable()) {
                                                    (id, name) -> UIImage? in
                                                    return LetgoAvatar.avatarWithID(id, name: name)
        }
        Observable.combineLatest(placeHolder, interlocutorAvatarURL.asObservable()) { ($0, $1) }
            .bind { [weak self] (placeholder, avatarUrl) in
                guard let showUserAvatarinCells = self?.featureFlags.showChatHeaderWithoutUser,
                    showUserAvatarinCells else {
                        self?.interlocutorAvatar = nil
                        return
                }
                if let url = avatarUrl {
                    do {
                        self?.interlocutorAvatar = try UIImage.imageFrom(url: url)
                    } catch {
                        self?.interlocutorAvatar = placeholder
                    }
                } else {
                    self?.interlocutorAvatar = placeholder
                }
            }.disposed(by: disposeBag)

        chatStatus.asObservable().subscribeNext { [weak self] status in
            guard let strongSelf = self else { return }
            
            if status == .forbidden {
                let disclaimer = strongSelf.chatViewMessageAdapter.createScammerDisclaimerMessage(
                    isBuyer: strongSelf.isBuyer, userName: strongSelf.conversation.value.interlocutor?.name,
                    action: strongSelf.safetyTipsAction)
                self?.messages.removeAll()
                self?.messages.append(disclaimer)
            }
        }.disposed(by: disposeBag)

        let relatedListingsConversation = conversation.asObservable().map { $0.relatedListingsEnabled }
        Observable.combineLatest(relatedListingsConversation, sellerDidntAnswer.asObservable()) { [weak self] in
            guard let strongSelf = self else { return .loading }
            guard strongSelf.isBuyer else { return .hidden } // Seller doesn't have related listings
            guard let listingId = strongSelf.conversation.value.listing?.objectId else { return .hidden }
            if $0 { return .visible(listingId: listingId) }
            guard let didntAnswer = $1 else { return .loading } // If still checking if seller didn't answer. set loading state
            return didntAnswer ? .visible(listingId: listingId) : .hidden
        }.bind(to: relatedListingsState).disposed(by: disposeBag)
        
        messages.changesObservable.subscribeNext { [weak self] change in
            self?.updateMessagesCounts(change)
        }.disposed(by: disposeBag)
        
        conversation.asObservable().map { $0.lastMessageSentAt == nil }.bind{ [weak self] result in
            self?.shouldTrackFirstMessage = result
        }.disposed(by: disposeBag)

        let emptyMyMessages = myMessagesCount.asObservable().map { $0 == 0 }
        let emptyOtherMessages = otherMessagesCount.asObservable().map { $0 == 0 }
        Observable.combineLatest(emptyMyMessages, emptyOtherMessages){ $0 && $1 }.distinctUntilChanged()
            .bind(to: isEmptyConversation).disposed(by: disposeBag)

        let expressBannerTriggered = Observable.combineLatest(firstInteractionDone.asObservable(),
                                                              expressBannerTimerFinished.asObservable()) { $0 || $1 }

        let relatedListingsObservable = Observable.combineLatest(hasRelatedListings.asObservable(),
                                                                 relatedListingsState.asObservable().map { !$0.isVisible }) { $0 && $1 }
        /**
            Express chat banner is shown after 3 seconds or 1st interaction if:
                - the listing has related listings
                - we're not showing the related listings already over the keyboard
                - user hasn't SENT messages via express chat for this listing
                - interlocutor is not professional
         */
        Observable.combineLatest(expressBannerTriggered,
                                 relatedListingsObservable,
                                 expressMessagesAlreadySent.asObservable(),
                                 interlocutorProfessionalInfo.asObservable()) { $0 && $1 && !$2 && !$3.isProfessional }
            .distinctUntilChanged().bind(to: shouldShowExpressBanner).disposed(by: disposeBag)

        let directAnswers: Observable<DirectAnswersState> = Observable.combineLatest(chatEnabled.asObservable(),
                                        relatedListingsState.asObservable(),
                                        resultSelector: { chatEnabled, relatedState in
                                            switch relatedState {
                                            case .loading, .visible:
                                                return .notAvailable
                                            case .hidden:
                                                guard chatEnabled else { return .notAvailable }
                                                return .visible
                                            }
                                        }).distinctUntilChanged()
        directAnswers.bind(to: directAnswersState).disposed(by: disposeBag)

        interlocutorId.asObservable().bind { [weak self] interlocutorId in
            guard let interlocutorId = interlocutorId, self?.interlocutor?.objectId != interlocutorId else { return }
            self?.userRepository.show(interlocutorId) { [weak self] result in
                guard let strongSelf = self else { return }
                guard let user = result.value else { return }
                strongSelf.interlocutor = user
                strongSelf.interlocutorIsVerified.value = user.hasBadge
                let proInfo = InterlocutorProfessionalInfo(isProfessional: user.isProfessional, phoneNumber: user.phone)
                strongSelf.interlocutorProfessionalInfo.value = proInfo
                if let userInfoMessage = strongSelf.userInfoMessage, strongSelf.shouldShowOtherUserInfo {
                    strongSelf.messages.append(userInfoMessage)
                }
            }
            }.disposed(by: disposeBag)

        let automaticMessagesSignal = Observable.combineLatest(messagesDidFinishRefreshing.asObservable(),
                                                               interlocutorProfessionalInfo.asObservable(),
                                                               lastMessageSentType.asObservable()) { ($0, $1, $2) }

        automaticMessagesSignal.asObservable().bind { [weak self] (messagesFinishedRefresh, proInfo, messageType) in
            guard messagesFinishedRefresh else { return }
            guard proInfo.isProfessional else { return }
            self?.professionalSellerAfterMessageEventsFor(messageType: messageType)
        }.disposed(by: disposeBag)

        setupUserIsTypingRx()
        setupChatEventsRx()
    }
    
    @objc func fireUserIsTypingTimeout() {
        userIsTyping.value = false
    }
    
    private func scheduleUserIsTypingTimeoutTimer() {
        userIsTypingTimeout?.invalidate()
        userIsTypingTimeout = Timer.scheduledTimer(timeInterval: ChatViewModel.userIsTypingTimeoutTime,
                                                   target: self,
                                                   selector: #selector(fireUserIsTypingTimeout),
                                                   userInfo: nil,
                                                   repeats: false)
    }
    
    private func setupInterlocutorIsTypingRx() {
        // show interlocutor is typing bubble in chat
        conversation.value.interlocutorIsTyping.asObservable()
            .distinctUntilChanged()
            .bind { [weak self] isTyping in
                isTyping ? self?.insertInterlocutorIsTypingMessage() : self?.removeInterlocutorIsTypingMessage()
            }
            .disposed(by: disposeBag)
    }
    
    private func setupUserIsTypingRx() {
        // send typing events to websocket & stop userIsTypingTimeout if needed
        userIsTyping.asObservable()
            .skip(1)
            .bind { [weak self] isTyping in
                guard let strongSelf = self else { return }
                if isTyping {
                    strongSelf.sendStartedTyping()
                } else {
                    strongSelf.userIsTypingTimeout?.invalidate()
                    strongSelf.addUserIsTypingThrottle()
                    strongSelf.sendStoppedTyping()
                }
            }
            .disposed(by: disposeBag)
    
        // reset userIsTypingTimeout timer on text change
        chatBoxText.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .bind { [weak self] _ in
                self?.scheduleUserIsTypingTimeoutTimer()
            }
            .disposed(by: disposeBag)
        
        addUserIsTypingThrottle()
        
        // set userIsTyping = false when text is empty (userIsTyping must be true)
        chatBoxText.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .filter { $0.isEmpty }
            .bind { [weak self] text in
                guard self?.userIsTyping.value == true else { return }
                self?.userIsTyping.value = false
            }
            .disposed(by: disposeBag)
    }
    
    private func addUserIsTypingThrottle() {
        // reset any previous rx added
        userIsTypingDisposeBag = DisposeBag()
        guard let userIsTypingDisposeBag = userIsTypingDisposeBag else { return }
        // set userIsTyping = true on every text change (max once every X seconds)
        chatBoxText.asObservable()
            .skip(1)
            .distinctUntilChanged()
            .filter { !$0.isEmpty }
            .throttle(ChatViewModel.typingStartedThrottleTime, latest: true, scheduler: MainScheduler.instance)
            .bind { [weak self] text in
                self?.userIsTyping.value = true
            }
            .disposed(by: userIsTypingDisposeBag)
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
        case .swap, .move:
            break
        case let .composite(changes):
            changes.forEach { [weak self] change in
                self?.updateMessagesCounts(change)
            }
        }
    }

    func setupChatEventsRx() {
        chatRepository.chatStatus
            .asObservable()
            .bind(to: rx_wsChatStatus)
            .disposed(by: disposeBag)

        rx_wsChatStatus.asObservable().bind { [weak self] wsChatStatus in
            guard let strongSelf = self else { return }
            switch wsChatStatus {
            case .openAuthenticated:
                //Reload messages if active, otherwise it will reload when active
                if strongSelf.active {
                    self?.refreshMessages()
                }
            case .closed, .closing, .opening, .openNotAuthenticated, .openNotVerified:
                break
            }
        }.disposed(by: disposeBag)

        guard let convId = conversation.value.objectId else { return }
        chatRepository.chatEventsIn(convId).subscribeNext { [weak self] event in
            switch event.type {
            case let .interlocutorMessageSent(messageId, sentAt, content):
                self?.handleNewMessageFromInterlocutor(messageId, sentAt: sentAt, text: content.text ?? "", type: content.type)
            case let .interlocutorReadConfirmed(messagesIds):
                self?.markMessagesAsRead(messagesIds)
            case let .interlocutorReceptionConfirmed(messagesIds):
                self?.markMessagesAsReceived(messagesIds)
            case .interlocutorTypingStarted:
                self?.conversation.value.interlocutorIsTyping.value = true
            case .interlocutorTypingStopped:
                self?.conversation.value.interlocutorIsTyping.value = false
            case .authenticationTokenExpired, .talkerUnauthenticated:
                break
            case .smartQuickAnswer(let sqa):
                guard let smartQuickAnswersActive = self?.featureFlags.smartQuickAnswers.isActive, smartQuickAnswersActive,
                    let isDummy = self?.isUserDummy, !isDummy,
                    let myUserId = self?.myUserRepository.myUser?.objectId, sqa.talkerId == myUserId
                    else { return }
                self?.smartQuickAnswers = sqa
                self?.shouldUpdateQuickAnswers.value = QuickAnswer.quickAnswers(for: sqa)
            }
        }.disposed(by: disposeBag)

        Observable.combineLatest(rx_wsChatStatus.asObservable(),
                                 rx_isReachable.asObservable())
            .asObservable()
            .skip(1)
            .bind { [weak self] (wsChatStatus, isReachable) in
                guard isReachable else {
                    self?.rx_connectionBarStatus.value = .noNetwork
                    return
                }
                switch wsChatStatus {
                case .openAuthenticated, .openNotVerified:
                    self?.rx_connectionBarStatus.value = .wsConnected
                case .closed, .closing:
                    self?.rx_connectionBarStatus.value = .wsClosed(reconnectBlock: { [weak self] in
                        self?.refreshMessages()
                    })
                case .opening, .openNotAuthenticated:
                    self?.rx_connectionBarStatus.value = .wsConnecting
                }
            }
            .disposed(by: disposeBag)

        rx_connectionBarStatus
            .asObservable()
            .map { $0.chatUserInteractionsEnabled }
            .bind(to: chatUserInteractionsEnabled)
            .disposed(by: disposeBag)
    }
    
    // MARK: - Public Methods
    
    func listingInfoPressed() {
        guard let listing = conversation.value.listing else { return }
        switch listing.status {
        case .deleted:
            break
        case .pending, .approved, .discarded, .sold, .soldOld:
            delegate?.vmDidEndEditing(animated: false)
            let data = ListingDetailData.listingChat(chatConversation: conversation.value)
            navigator?.openListing(data, source: .chat, actionOnFirstAppear: .nonexistent)
        }
    }
    
    func userInfoPressed() {
        guard let interlocutor = conversation.value.interlocutor else { return }
        let data = UserDetailData.userChat(user: interlocutor)
        navigator?.openUser(data)
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

    func expressChatBannerActionButtonTapped() {
        guard let listingId = conversation.value.listing?.objectId else { return }
        navigator?.openExpressChat(relatedListings, sourceListingId: listingId, manualOpen: true)
    }

    func professionalSellerBannerActionButtonTapped() {
        guard let phoneNumber = interlocutorProfessionalInfo.value.phoneNumber else { return }
        PhoneCallsHelper.call(phoneNumber: phoneNumber)

        trackCallSeller()
    }
}


// MARK: - Private methods

extension ChatViewModel {
    
    func isMatchingConversationId(_ conversationId: String) -> Bool {
        return conversationId == conversation.value.objectId
    }
}


// MARK: - Message operations

extension ChatViewModel {

    func sendMeetingMessage(meeting: AssistantMeeting, isSuggestedPlace: Bool?) {
        let meetingText = meeting.textForMeeting
        sendMessage(type: .meeting(meeting: meeting, text: meetingText, isSuggestedPlace: isSuggestedPlace))
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

    func send(phone: String) {
        sendMessage(type: .phone(phone))
    }

    func sendPhoneFrom(alert: UIAlertController) {
        guard let textField = alert.textFields?.first,
            let textFieldText = textField.text?.replacingOccurrences(of: "-", with: ""),
            textFieldText.isPhoneNumber else {
                delegate?.vmShowAutoFadingMessage(R.Strings.professionalDealerAskPhoneAlertNotValidPhone, completion: nil)
                return
        }
        send(phone: textFieldText)
        tracker.trackEvent(TrackerEvent.phoneNumberSent(typePage: .chat))
    }

    fileprivate func sendMessage(type: ChatWrapperMessageType) {
        userIsTypingDisposeBag = nil
        stoppedTypingEventEnabled = false
        if let preSendMessageCompletion = preSendMessageCompletion {
            preSendMessageCompletion(type)
            return
        }

        let message = type.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard message.count > 0 else { return }
        guard let convId = conversation.value.objectId else { return }
        guard let userId = myUserRepository.myUser?.objectId else { return }

        if type.isUserText {
            delegate?.vmDidSendMessage()
        }

        let newMessage = chatRepository.createNewMessage(messageId: nil,
                                                         talkerId: userId,
                                                         text: message,
                                                         type: type.chatType)
        let viewMessage = chatViewMessageAdapter.adapt(newMessage, userAvatarData: nil)?.markAsSent()
        guard let messageId = newMessage.objectId else { return }
        insertFirst(viewMessage: viewMessage)
        chatRepository.sendMessage(convId, messageId: messageId, type: type.websocketType, text: message, answerKey: type.quickAnswerKey) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let _ = result.value {
                strongSelf.afterSendMessageEvents(type: type)
                strongSelf.trackMessageSent(type: type)
                strongSelf.updateMeetingsStatusAfterSending(message: newMessage)
            } else if let error = result.error {
                strongSelf.trackMessageSentError(type: type, error: error)
                // Removing message until we implement the retry-message state behavior
                strongSelf.removeMessage(messageId: messageId)
                switch error {
                case let .wsChatError(chatRepositoryError):
                    switch chatRepositoryError {
                    case .notAuthenticated, .userBlocked, .internalError, .network, .apiError, .userNotVerified:
                        self?.showSendMessageError(withText: R.Strings.chatSendErrorGeneric)
                    case .differentCountry:
                        self?.showSendMessageError(withText: R.Strings.chatSendErrorDifferentCountry)
                    }
                case .forbidden, .internalError, .network, .notFound, .tooManyRequests, .unauthorized, .serverError,
                     .searchAlertError, .userNotVerified:
                    self?.showSendMessageError(withText: R.Strings.chatSendErrorGeneric)
                }
            }
        }
    }

    private func afterSendMessageEvents(type: ChatWrapperMessageType) {
        openChatAutomaticMessage = nil
        firstInteractionDone.value = true
        lastMessageSentType.value = type

        if shouldAskListingSold {
            var interfaceText: String
            var alertTitle: String
            var soldQuestionText: String
            
            if listingIsFree.value {
                interfaceText = R.Strings.directAnswerGivenAwayQuestionOk
                alertTitle = R.Strings.directAnswerGivenAwayQuestionTitle
                soldQuestionText = R.Strings.directAnswerGivenAwayQuestionMessage
            } else {
                interfaceText = R.Strings.directAnswerSoldQuestionOk
                alertTitle = R.Strings.directAnswerSoldQuestionTitle
                soldQuestionText = R.Strings.directAnswerSoldQuestionMessage
            }
            shouldAskListingSold = false
            let action = UIAction(interface: UIActionInterface.text(interfaceText),
                                  action: { [weak self] in self?.markListingAsSold() })
            delegate?.vmShowAlert(alertTitle,
                                  message: soldQuestionText,
                                  cancelLabel: R.Strings.commonCancel,
                                  actions: [action])
        } else if pushPermissionsManager.shouldShowPushPermissionsAlertFromViewController(.chat(buyer: isBuyer)) {
            delegate?.vmDidRequestShowPrePermissions(.chat(buyer: isBuyer))
        } else if ratingManager.shouldShowRating {
            delegate?.vmDidEndEditing(animated: true)
            delay(1.0) { [weak self] in
                self?.delegate?.vmDidEndEditing(animated: true)
                self?.navigator?.openAppRating(.chat)
            }
        }
    }

    private func professionalSellerAfterMessageEventsFor(messageType: ChatWrapperMessageType?) {
        guard let listingId = conversation.value.listing?.objectId,
            !keyValueStorage.proSellerAlreadySentPhoneInChat.contains(listingId) else { return }
        guard let type = messageType else {
            insertAskPhoneNumberMessage()
            return
        }

        switch type {
        case .phone:
            saveProSellerAlreadySentPhoneInChatFor(listingId: listingId)
            if !hasSentAutomaticAnswerForPhoneMessage {
                sendProfessionalAutomaticAnswerWith(message: R.Strings.professionalDealerAskPhoneThanksPhoneCellMessage,
                                                    isPhone: true)
                disableAskPhoneMessageButton()
            }
        case .text, .quickAnswer, .chatSticker, .expressChat, .periscopeDirect, .favoritedListing, .meeting, .interested:
            insertAskPhoneNumberMessage()
            if !hasSentAutomaticAnswerForOtherMessage {
                sendProfessionalAutomaticAnswerWith(message: R.Strings.professionalDealerAskPhoneThanksOtherCellMessage,
                                                    isPhone: false)
            }
        }
    }

    private func insertAskPhoneNumberMessage() {
        if let askPhoneNumber = askPhoneMessage {
            messages.insert(askPhoneNumber, atIndex: 0)
        }
    }

    private func showSendMessageError(withText text: String) {
        guard !showingSendMessageError else { return }
        showingSendMessageError = true
        delegate?.vmShowAutoFadingMessage(text) { [weak self] in
            self?.showingSendMessageError = false
        }
    }
    
    private func sendStartedTyping() {
        guard let conversationId = conversation.value.objectId else { return }
        stoppedTypingEventEnabled = true
        chatRepository.typingStarted(conversationId)
    }
    
    private func sendStoppedTyping() {
        guard let conversationId = conversation.value.objectId,
            stoppedTypingEventEnabled
            else { return }
        chatRepository.typingStopped(conversationId)
    }

    private func resendEmailVerification(_ email: String) {
        myUserRepository.linkAccount(email) { [weak self] result in
            if let error = result.error {
                switch error {
                case .tooManyRequests:
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.profileVerifyEmailTooManyRequests, completion: nil)
                case .network:
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorNetworkBody, completion: nil)
                case .forbidden, .internalError, .notFound, .unauthorized, .userNotVerified, .serverError, .wsChatError,
                     .searchAlertError:
                    self?.delegate?.vmShowAutoFadingMessage(R.Strings.commonErrorGenericBody, completion: nil)
                }
            } else {
                self?.delegate?.vmShowAutoFadingMessage(R.Strings.profileVerifyEmailSuccess, completion: nil)
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
    
    private func insertInterlocutorIsTypingMessage() {
        interlocutorTypingChatViewMessage = chatViewMessageAdapter.createInterlocutorIsTyping(userAvatarData: defaultUserAvatarData)
        guard let interlocutorTypingMessage = interlocutorTypingChatViewMessage else { return }
        messages.insert(interlocutorTypingMessage, atIndex: 0)
    }
    
    private func removeInterlocutorIsTypingMessage() {
        guard let interlocutorTypingMessage = interlocutorTypingChatViewMessage else { return }
        if let index = messages.value.index(where: {$0 == interlocutorTypingMessage}) {
            messages.removeAtIndex(index)
        }
    }
    
    private func insertFirst(viewMessage: ChatViewMessage?, fromInterlocutor: Bool = false) {
        guard let viewMessage = viewMessage else { return }
        if conversation.value.interlocutorIsTyping.value && messages.value.count >= 1 {
            if fromInterlocutor {
                messages.replace(0..<1, with: [viewMessage])
                conversation.value.interlocutorIsTyping.value = false
            } else {
                messages.insert(viewMessage, atIndex: 1)
            }
        } else {
            messages.insert(viewMessage, atIndex: 0)
        }
        shouldUpdateQuickAnswers.value = directAnswers
        trackLetgoServiceMessageReceived()
    }

    fileprivate func handleNewMessageFromInterlocutor(_ messageId: String, sentAt: Date, text: String?, type: ChatMessageType) {
        guard let convId = conversation.value.objectId else { return }
        guard let interlocutorId = conversation.value.interlocutor?.objectId else { return }
        let message: ChatMessage = chatRepository.createNewMessage(messageId: messageId,
                                                                   talkerId: interlocutorId,
                                                                   text: text,
                                                                   type: type)
        updateMeetingsStatusAfterReceiving(message: message)

        let viewMessage = chatViewMessageAdapter.adapt(message, userAvatarData: defaultUserAvatarData)?.markAsSent(date: sentAt).markAsReceived().markAsRead()
        insertFirst(viewMessage: viewMessage, fromInterlocutor: true)
        chatRepository.confirmRead(convId, messageIds: [messageId], completion: nil)
        if let securityMeetingIndex = securityMeetingIndex(for: messages.value) {
            messages.insert(chatViewMessageAdapter.createSecurityMeetingDisclaimerMessage(),
                            atIndex: securityMeetingIndex)
        }
        guard isBuyer else { return }
        sellerDidntAnswer.value = false
    }

    fileprivate func saveProSellerAlreadySentPhoneInChatFor(listingId: String) {
        var listingsWithPhoneSent = keyValueStorage.proSellerAlreadySentPhoneInChat

        for listingWithPhone in listingsWithPhoneSent {
            if listingWithPhone == listingId { return }
        }
        listingsWithPhoneSent.append(listingId)
        keyValueStorage.proSellerAlreadySentPhoneInChat = listingsWithPhoneSent
    }

    fileprivate func sendProfessionalAutomaticAnswerWith(message: String, isPhone: Bool) {
        guard let automaticAnswerMessage = chatViewMessageAdapter.createAutomaticAnswerWith(message: message,
                                                                                            userAvatarData: defaultUserAvatarData) else { return }
        insertFirst(viewMessage: automaticAnswerMessage)
        hasSentAutomaticAnswerForPhoneMessage = isPhone
        hasSentAutomaticAnswerForOtherMessage = true
    }

    private func disableAskPhoneMessageButton() {
        guard let index = messages.value.index(where: { $0.type.isAskPhoneNumber }) else { return }
        guard let newMessage = chatViewMessageAdapter.createAskPhoneMessageWith(action: nil,
                                                                                userAvatarData: defaultUserAvatarData) else { return }
        let range = index..<(index+1)
        messages.replace(range, with: [newMessage])
    }
}


// MARK: - Listing Operations

extension ChatViewModel {
    fileprivate func markListingAsSold() {
        guard conversation.value.amISelling else { return }
        guard let listingId = conversation.value.listing?.objectId else { return }
        
        delegate?.vmShowLoading(nil)
        listingRepository.markAsSold(listingId: listingId) { [weak self] result in
            if let _ = result.value {
                self?.trackMarkAsSold()
            }
            let errorMessage: String? = result.error != nil ? R.Strings.productMarkAsSoldErrorGeneric : nil
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
        
        let safetyTips = UIAction(interface: UIActionInterface.text(R.Strings.chatSafetyTips), action: { [weak self] in
            self?.delegate?.vmDidRequestSafetyTips()
        })
        actions.append(safetyTips)

        if conversation.value.isSaved {
            if !isDeleted && !isEmptyConversation.value {
                let delete = UIAction(interface: UIActionInterface.text(R.Strings.chatListDelete),
                                                   action: deleteAction)
                actions.append(delete)
            }

            if interlocutorEnabled {
                let report = UIAction(interface: UIActionInterface.text(R.Strings.reportUserTitle),
                                      action: reportUserAction)
                actions.append(report)
              
                if interlocutorIsMuted.value {
                    let unblock = UIAction(interface: UIActionInterface.text(R.Strings.chatUnblockUser),
                                          action: unblockUserAction)
                    actions.append(unblock)
                } else {
                    let block = UIAction(interface: UIActionInterface.text(R.Strings.chatBlockUser),
                                         action:  { [weak self] in self?.blockUserAction(buttonPosition: .threeDots) } )
                    actions.append(block)
                }
            }
        }

        // FIXME: Remove this action and use the final production version before merging this branch into develop (@juolgon)
        let p2pPaymentsFlowActions = actionForP2PPaymentsFlowTesting()
        actions.append(contentsOf: p2pPaymentsFlowActions)

        delegate?.vmShowActionSheet(R.Strings.commonCancel, actions: actions)
    }
    
    private func deleteAction() {
        guard !isDeleted else { return }
        
        
        let action = UIAction(interface: .styledText(R.Strings.chatListDeleteAlertSend, .destructive), action: {
            [weak self] in
            self?.delete() { [weak self] success in
                if success {
                    self?.isDeleted = true
                    self?.tracker.trackEvent(TrackerEvent.chatDeleteComplete(numberOfConversations: 1,
                                                                             isInactiveConversation: false))
                }
                let message = success ? R.Strings.chatListDeleteOkOne : R.Strings.chatListDeleteErrorOne
                self?.delegate?.vmDidNotifyMessage(message) { [weak self] in
                    self?.navigator?.closeChatDetail()
                }
            }
        })
        delegate?.vmShowAlert(R.Strings.chatListDeleteAlertTitleOne,
                              message: R.Strings.chatListDeleteAlertTextOne,
                              cancelLabel: R.Strings.commonCancel,
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
        delegate?.vmDidPressReportUser(reportVM)
    }
    
    fileprivate func blockUserAction(buttonPosition: EventParameterBlockButtonPosition) {
        
        let action = UIAction(interface: .styledText(R.Strings.chatBlockUserAlertBlockButton, .destructive), action: {
            [weak self] in
            self?.blockUser(buttonPosition: buttonPosition) { [weak self] success in
                if success {
                    self?.interlocutorIsMuted.value = true
                    self?.chatStatus.value = .blocked
                    self?.chatEnabled.value = false
                    self?.refreshChat()
                } else {
                    self?.delegate?.vmDidNotifyMessage(R.Strings.blockUserErrorGeneric, completion: nil)
                }
            }
        })
        
        delegate?.vmShowAlert(R.Strings.chatBlockUserAlertTitle,
                              message: R.Strings.chatBlockUserAlertText,
                              cancelLabel: R.Strings.commonCancel,
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
            guard let strongSelf = self else { return }
            if success {
                strongSelf.interlocutorIsMuted.value = false
                strongSelf.refreshChat()
                strongSelf.chatStatus.value = strongSelf.recoverConversationChatStatusForUnblock()
                switch strongSelf.chatStatus.value {
                case .forbidden, .blocked, .blockedBy, .userPendingDelete, .userDeleted, .inactiveConversation:
                    strongSelf.chatEnabled.value = false
                case .available, .listingSold, .listingGivenAway, .listingDeleted:
                    strongSelf.chatEnabled.value = true
                }
            } else {
                strongSelf.delegate?.vmDidNotifyMessage(R.Strings.unblockUserErrorGeneric, completion: nil)
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

    /**
     Checks the same conditions as the chatStatus ChatConversation extension, except if the interlocutor is muted
     NEVER returns blocked
     */
    private func recoverConversationChatStatusForUnblock() -> ChatInfoViewStatus {
        let actualConversation = conversation.value
        guard let interlocutor = actualConversation.interlocutor else { return .available }
        guard let listing = actualConversation.listing else { return .available }

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
        if interlocutor.hasMutedYou { return .blockedBy }

        switch listing.status {
        case .deleted, .discarded:
            return .listingDeleted
        case .sold, .soldOld:
            return .listingSold
        case .approved, .pending:
            return .available
        }
    }
}

// MARK: - P2P Payments Testing
// TODO: @juolgon Change this code for the final production code before merging the feature branch into develop

extension ChatViewModel {
    private func actionForP2PPaymentsFlowTesting() -> [UIAction] {
        return [UIAction(interface: UIActionInterface.text("P2P Payments - Offer"), action: openP2PPaymentsMakeAnOfferFlow),
                UIAction(interface: UIActionInterface.text("P2P Payments - Status"), action: openP2PPaymentsOfferStatusFlow)]
    }

    private func openP2PPaymentsMakeAnOfferFlow() {
        // TODO: Start P2P Payments flow here (@juolgon)
        navigator?.openMakeAnOffer(chatConversation: conversation.value)
    }

    private func openP2PPaymentsOfferStatusFlow() {
        // TODO: Start P2P Payments flow here (@juolgon)
        guard let offerId = UIPasteboard.general.string else { return }
        navigator?.openOfferStatus(offerId: offerId)
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
        return chatViewMessageAdapter.createUserInfoMessage(interlocutor, userAvatarData: defaultUserAvatarData)
    }

    private var bottomDisclaimerMessage: ChatViewMessage? {
        switch chatStatus.value {
        case .userDeleted, .userPendingDelete:
            return chatViewMessageAdapter.createUserDeletedDisclaimerMessage(conversation.value.interlocutor?.name)
        case .available, .blocked, .blockedBy, .forbidden, .listingDeleted, .listingSold, .listingGivenAway, .inactiveConversation:
            return nil
        }
    }

    var shouldShowAskPhoneMessage: Bool {
        if let openAutomaticMessage = openChatAutomaticMessage, openAutomaticMessage.isPhone {
            return false
        }
        guard let lastMessage = lastMessageSentType.value else { return !hasShownAskedPhoneMessage }
        return !hasShownAskedPhoneMessage &&
            interlocutorProfessionalInfo.value.isProfessional &&
            messagesDidFinishRefreshing.value &&
            !lastMessage.isPhone
    }

    var askPhoneMessage: ChatViewMessage? {
        guard let listingId = conversation.value.listing?.objectId,
            !keyValueStorage.proSellerAlreadySentPhoneInChat.contains(listingId),
            shouldShowAskPhoneMessage else { return nil }

        let askPhoneAction: (() -> Void)? = { [weak self] in
            self?.delegate?.vmAskPhoneNumber()
            self?.tracker.trackEvent(TrackerEvent.phoneNumberRequest(typePage: .chat))
        }
        hasShownAskedPhoneMessage = true
        return chatViewMessageAdapter.createAskPhoneMessageWith(action: askPhoneAction, userAvatarData: defaultUserAvatarData)
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
                if strongSelf.meetingsEnabled, let meeting = strongSelf.firstMeetingIn(messages: value) {
                    strongSelf.updateMeetingsStatusAfterReceiving(message: meeting)
                }
                strongSelf.messagesDidFinishRefreshing.value = true
            } else if let _ = result.error {
                strongSelf.delegate?.vmDidFailRetrievingChatMessages()
            }
            strongSelf.setupInterlocutorIsTypingRx()
            strongSelf.shouldUpdateQuickAnswers.value = strongSelf.directAnswers
            strongSelf.trackLetgoServiceMessageReceived()
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
                if strongSelf.meetingsEnabled, let meeting = strongSelf.firstMeetingIn(messages: value) {
                    strongSelf.updateMeetingsStatusAfterReceiving(message: meeting)
                }
                strongSelf.messagesDidFinishRefreshing.value = true
            } else if let _ = result.error {
                strongSelf.delegate?.vmDidFailRetrievingChatMessages()
            }
        }
    }

    private func refreshLastMessages(_ convId: String) {
        isLoading = true
        chatRepository.indexMessages(convId, numResults: resultsPerPage, offset: 0) { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            guard let newMessages = result.value else { return }
            strongSelf.mergeMessages(newMessages: newMessages)
            strongSelf.messagesDidFinishRefreshing.value = true
            if strongSelf.meetingsEnabled, let meeting = strongSelf.firstMeetingIn(messages: newMessages) {
                strongSelf.updateMeetingsStatusAfterReceiving(message: meeting)
            }
        }
    }

    private func markAsReadMessages(_ chatMessages: [ChatMessage] ) {
        guard let convId = conversation.value.objectId else { return }
        guard let interlocutorId = conversation.value.interlocutor?.objectId else { return }

        let readIds: [String] = chatMessages.filter { return $0.talkerId == interlocutorId && $0.readAt == nil }
            .compactMap { $0.objectId }
        if !readIds.isEmpty {
            chatRepository.confirmRead(convId, messageIds: readIds, completion: nil)
        }
    }

    private func updateMessages(newMessages: [ChatMessage], isFirstPage: Bool) {
        markAsReadMessages(newMessages)

        // Add message disclaimer (message flagged)
        let mappedChatMessages = newMessages.compactMap { [weak self] message in
            return self?.chatViewMessageAdapter.adapt(message, userAvatarData: self?.defaultUserAvatarData)
        }

        var chatMessages = chatViewMessageAdapter.addDisclaimers(mappedChatMessages,
                                                                 disclaimerMessage: defaultDisclaimerMessage)
        // Add user info as 1st message
        if let userInfoMessage = userInfoMessage, shouldShowOtherUserInfo {
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
        defer {
            // Add user info as 1st message
            if let userInfoMessage = userInfoMessage, shouldShowOtherUserInfo {
                messages.append(userInfoMessage)
            }
        }

        let newViewMessages = newMessages.compactMap { [weak self] message in
            return self?.chatViewMessageAdapter.adapt(message, userAvatarData: self?.defaultUserAvatarData)
        }

        guard !newViewMessages.isEmpty else { return }

        // We need to remove extra messages & disclaimers to be able to merge correctly. Will be added back before returning
        var filteredViewMessages = messages.value.filter { $0.objectId != nil }

        filteredViewMessages.merge(
            another: newViewMessages,
            matcher: { $0.objectId == $1.objectId },
            sortBy: { (message1, message2) -> Bool in
                if message1.sentAt == nil && message2.sentAt != nil { return true }
                guard let sentAt1 = message1.sentAt,
                    let sentAt2 = message2.sentAt
                    else { return false }
                return sentAt1 > sentAt2
            }
        )

        var chatMessages = chatViewMessageAdapter.addDisclaimers(filteredViewMessages,
                                                                 disclaimerMessage: defaultDisclaimerMessage)
        if let securityMeetingIndex = securityMeetingIndex(for: chatMessages) {
            chatMessages.insert(chatViewMessageAdapter.createSecurityMeetingDisclaimerMessage(),
                                at: securityMeetingIndex)
        }
        // Add disclaimer at the bottom of the first page
        if let bottomDisclaimerMessage = bottomDisclaimerMessage {
            chatMessages.insert(bottomDisclaimerMessage, at: 0)
        }

        messages.removeAll()
        messages.appendContentsOf(chatMessages)
    }
    
    fileprivate func securityMeetingIndex(for messages: [ChatViewMessage]) -> Int? {
        guard !isUserDummy else { return nil }
        
        var isFirstPage: Bool {
            return messages.count < SharedConstants.numMessagesPerPage
        }
        var priceIsEqualOrHigherThan250: Bool {
            guard let price = conversation.value.listing?.price.value else { return false }
            return price >= 250
        }
        var firstInterlocutorMessageIndex: Int? {
            guard let i = messages.reversed().index(where: {
                switch $0.type {
                case .disclaimer, .userInfo, .askPhoneNumber, .interlocutorIsTyping, .multiAnswer, .cta, .carousel:
                    return false
                case .offer, .sticker, .text, .meeting, .unsupported:
                    return $0.talkerId != myUserRepository.myUser?.objectId
                }
            }) else { return nil }
            let index = messages.index(before: i.base)
            return index
        }
        var securityTooltipWasShownToday: Bool {
            guard let lastShownDate = keyValueStorage[.lastShownSecurityWarningDate] else { return false }
            return lastShownDate.isFromLast24h()
        }
        
        guard isFirstPage else { return nil }
        guard priceIsEqualOrHigherThan250 else { return nil }
        if isBuyer {
            return firstInterlocutorMessageIndex
        } else if !securityTooltipWasShownToday {
            keyValueStorage[.lastShownSecurityWarningDate] = Date()
            return firstInterlocutorMessageIndex
        }
        return nil
    }

    private func afterRetrieveChatMessagesEvents() {
        if shouldShowSafetyTips {
            delegate?.vmDidRequestSafetyTips()
        }

        afterRetrieveMessagesCompletion?()
    }

    private func checkSellerDidntAnswer(_ messages: [ChatMessage]) {
        guard isBuyer else { return }

        guard let myUserId = myUserRepository.myUser?.objectId else { return }

        let calendar = Calendar.current
        guard let twoDaysAgo = (calendar as NSCalendar).date(byAdding: .day, value: -2, to: Date(), options: []) else {
            sellerDidntAnswer.value = nil
            return
        }

        var hasOldMessages = false
        if let oldestMessageDate = messages.last?.sentAt {
            hasOldMessages = oldestMessageDate.compare(twoDaysAgo) == .orderedAscending
        }

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
            (hasOldMessages || messages.count == SharedConstants.numMessagesPerPage)
    }

    private func checkShouldShowDirectAnswers(_ messages: [ChatMessage]) {
        // If there's no previous message from me, we should show direct answers
        guard let myUserId = myUserRepository.myUser?.objectId else { return }
        for message in messages {
            guard message.talkerId != myUserId else { return }
        }
    }
}


// MARK: - Second step login

fileprivate extension ChatViewModel {
    func setupNotLoggedIn(_ listing: Listing) {
        guard let listingId = listing.objectId, let sellerId = listing.user.objectId else { return }
        self.listingId = listingId

        // Configure listing + user info
        title.value = listing.title ?? ""
        listingName.value = listing.title ?? ""
        listingImageUrl.value = listing.thumbnail?.fileURL
        listingPrice.value = listing.priceString(freeModeAllowed: featureFlags.freePostingModeAllowed)
        interlocutorAvatarURL.value = listing.user.avatar?.fileURL
        interlocutorName.value = listing.user.name ?? ""
        interlocutorId.value = sellerId

        // Configure login + send actions
        preSendMessageCompletion = { [weak self] (type: ChatWrapperMessageType) in
            self?.delegate?.vmDidEndEditing(animated: false)
            self?.navigator?.openLoginIfNeededFromChatDetail(from: .askQuestion, loggedInAction: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.preSendMessageCompletion = nil
                guard sellerId != strongSelf.myUserRepository.myUser?.objectId else {
                    //A user cannot have a conversation with himself
                    strongSelf.delegate?.vmShowAutoFadingMessage(R.Strings.chatWithYourselfAlertMsg) {
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

    func trackLetgoServiceMessageReceived() {
        guard let lastMessage = messages.value.first else { return }
        if case .multiAnswer(let question, _) = lastMessage.type,
            let questionKey = question.key {
            tracker.trackEvent(TrackerEvent.chatLetgoServiceQuestionReceived(questionKey: questionKey,
                                                                             listingId: conversation.value.listing?.objectId))
        } else if case .cta(let data, _) = lastMessage.type,
            let key = data.key {
            tracker.trackEvent(TrackerEvent.chatLetgoServiceCTAReceived(questionKey: key,
                                                                        listingId: conversation.value.listing?.objectId))
        }
    }
    
    func trackMessageSent(type: ChatWrapperMessageType) {
        guard let info = buildSendMessageInfo(withType: type, error: nil) else { return }
        var isProfessional: Bool? = nil
        if let interlocutor = interlocutor {
            isProfessional = interlocutor.isProfessional
        }
        if shouldTrackFirstMessage {
            shouldTrackFirstMessage = false
            let badgeParameter: EventParameterUserBadge
            if let interlocutor = interlocutor {
                badgeParameter = EventParameterUserBadge(userBadge: interlocutor.reputationBadge)
            } else {
                badgeParameter = EventParameterUserBadge.noBadge
            }
            tracker.trackEvent(TrackerEvent.firstMessage(info: info,
                                                         listingVisitSource: .unknown,
                                                         feedPosition: .none,
                                                         userBadge: badgeParameter,
                                                         containsVideo: .notAvailable,
                                                         isProfessional: isProfessional,
                                                         sectionName: nil))
        }
        tracker.trackEvent(TrackerEvent.userMessageSent(info: info, isProfessional: isProfessional))
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
        let markAsSold = TrackerEvent.listingMarkAsSold(trackingInfo: trackingInfo)
        tracker.trackEvent(markAsSold)
    }

    func trackCallSeller() {
        guard let chatListing = conversation.value.listing else { return }

        let isFreePosting: Bool? = conversation.value.listing?.price.isFree
        let callSeller = TrackerEvent.chatBannerCall(chatListing,
                                                     source: .unknown,
                                                     typePage: EventParameterTypePage.chat,
                                                     sellerAverageUserRating: interlocutor?.ratingAverage,
                                                     isFreePosting: EventParameterBoolean.init(bool: isFreePosting),
                                                     isBumpedUp: .notAvailable)
        tracker.trackEvent(callSeller)
    }

    private func buildSendMessageInfo(withType type: ChatWrapperMessageType, error: RepositoryError?) -> SendMessageTrackingInfo? {
        guard let listing = conversation.value.listing else { return nil }
        guard let userId = conversation.value.interlocutor?.objectId else { return nil }

        let sellerRating = conversation.value.amISelling ?
            myUserRepository.myUser?.ratingAverage : interlocutor?.ratingAverage

        let typePage: EventParameterTypePage = source == .listingListFeatured ? .listingListFeatured : .chat

        let sendMessageInfo = SendMessageTrackingInfo()
            .set(chatListing: listing, freePostingModeAllowed: featureFlags.freePostingModeAllowed)
            .set(interlocutorId: userId)
            .set(messageType: type.chatTrackerType)
            .set(quickAnswerTypeParameter: type.quickAnswerTypeParameter)
            .set(typePage: typePage)
            .set(sellerRating: sellerRating)
            .set(isBumpedUp: .falseParameter)
            .set(containsEmoji: type.text.containsEmoji)
            .set(assistantMeeting: type.assistantMeeting, isSuggestedPlace: type.isSuggestedPlace)
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
            return .listingDeleted
        case .sold, .soldOld:
            return listing.price == .free ? .listingGivenAway : .listingSold
        case .approved, .pending:
            return .available
        }
    }
    
    var chatEnabled: Bool {
        switch chatStatus {
        case .forbidden, .blocked, .blockedBy, .userPendingDelete, .userDeleted, .inactiveConversation:
            return false
        case .available, .listingSold, .listingDeleted, .listingGivenAway:
            return true
        }
    }

    var relatedListingsEnabled: Bool {
        switch chatStatus {
        case .forbidden,  .userPendingDelete, .userDeleted, .listingDeleted, .listingSold, .listingGivenAway:
            return !amISelling
        case .available, .blocked, .blockedBy, .inactiveConversation:
            return false
        }
    }
}


// MARK: - DirectAnswers

extension ChatViewModel: DirectAnswersPresenterDelegate {
    
    /*
     Quick answers priorities:
     1- dynamic answers (embedded in a chat message)
     2- smart quick answers (provided by chat event)
     3- legacy quick answers (hardcoded in app)
     */
    var directAnswers: [QuickAnswer] {
        if let lastMessage = messages.value.first,
            let userId = myUserRepository.myUser?.objectId,
            lastMessage.talkerId != userId,
            let quickAnswers = QuickAnswer.quickAnswersForChatMessage(chatViewMessage: lastMessage) {
            return quickAnswers
        } else if let sqa = smartQuickAnswers {
            return QuickAnswer.quickAnswers(for: sqa)
        } else if !isUserDummy {
            let isFree = featureFlags.freePostingModeAllowed && listingIsFree.value
            let isBuyer = !conversation.value.amISelling
            return QuickAnswer.quickAnswersForChatWith(buyer: isBuyer,
                                                       isFree: isFree,
                                                       chatNorrisABtestVersion: featureFlags.chatNorris)
        }
        return []
    }

    func directAnswersDidTapAnswer(_ controller: DirectAnswersPresenter, answer: QuickAnswer) {
        switch answer {
        case .listingSold, .freeNotAvailable:
            onListingSoldDirectAnswer()
            send(quickAnswer: answer)
        case .interested, .notInterested, .meetUp, .stillAvailable, .isNegotiable, .likeToBuy, .listingCondition,
             .listingStillForSale, .whatsOffer, .negotiableYes, .negotiableNo, .freeStillHave, .freeYours,
             .freeAvailable:
            clearListingSoldDirectAnswer()
            send(quickAnswer: answer)
        case .meetingAssistant:
            onMeetingAssistantPressed()
        case .dynamic(let chatAnswer):
            send(quickAnswer: QuickAnswer.dynamic(chatAnswer: chatAnswer))
            if case .callToAction(_, _, let deeplinkURL) = chatAnswer.type {
                navigator?.navigate(with: deeplinkURL)
            }
        case .dynamicInterested:
            // Ignore. At the moment this case does not appear in chat
            break
        }
    }
    
    private func clearListingSoldDirectAnswer() {
        shouldAskListingSold = false
    }
    
    private func onListingSoldDirectAnswer() {
        if chatStatus.value == .available {
            shouldAskListingSold = true
        }
    }

    private func onMeetingAssistantPressed() {
        guard let listingId = conversation.value.listing?.objectId else { return }
        navigator?.openAssistantFor(listingId: listingId, dataDelegate: self)
    }
}


// MARK: - Related listings

extension ChatViewModel: ChatRelatedListingsViewDelegate {

    func relatedListingsViewDidShow(_ view: ChatRelatedListingsView) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus.value)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsStart(relatedShownReason))
    }

    func relatedListingsView(_ view: ChatRelatedListingsView, showListing listing: Listing, atIndex index: Int,
                             listingListModels: [ListingCellModel], requester: ListingListRequester,
                             thumbnailImage: UIImage?, originFrame: CGRect?) {
        let relatedShownReason = EventParameterRelatedShownReason(chatInfoStatus: chatStatus.value)
        tracker.trackEvent(TrackerEvent.chatRelatedItemsComplete(index, shownReason: relatedShownReason))
        let data = ListingDetailData.listingList(listing: listing, cellModels: listingListModels, requester: requester,
                                                 thumbnailImage: thumbnailImage, originFrame: originFrame,
                                                 showRelated: false, index: 0)
        navigator?.openListing(data, source: .chat, actionOnFirstAppear: .nonexistent)
    }
}


// MARK: - Related listings for express chat

extension ChatViewModel {

    static let maxRelatedListingsForExpressChat = 4

    fileprivate func retrieveRelatedListings() {
        guard isBuyer, !isUserDummy else { return }
        guard let listingId = conversation.value.listing?.objectId else { return }
        listingRepository.indexRelated(listingId: listingId, params: RetrieveListingParams()) {
            [weak self] result in
            guard let strongSelf = self else { return }
            if let listings = result.value {
                strongSelf.relatedListings = strongSelf.relatedWithoutMyListings(listings)
                strongSelf.hasRelatedListings.value = !strongSelf.relatedListings.isEmpty
            }
        }
    }

    private func relatedWithoutMyListings(_ listings: [Listing]) -> [Listing] {
        var cleanRelatedListings: [Listing] = []
        for listing in listings {
            if listing.user.objectId != myUserRepository.myUser?.objectId { cleanRelatedListings.append(listing) }
            if cleanRelatedListings.count == ChatViewModel.maxRelatedListingsForExpressChat {
                return cleanRelatedListings
            }
        }
        return cleanRelatedListings
    }


    // Express Chat Banner methods

    fileprivate func setupExpressChat() {
        guard !isUserDummy else { return }
        expressMessagesAlreadySent.value = expressChatMessageSentForCurrentListing()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(3)) { [weak self] in
            self?.expressBannerTimerFinished.value = true
        }
    }

    private func expressChatMessageSentForCurrentListing() -> Bool {
        guard let listingId = conversation.value.listing?.objectId else { return false }
        for listingSentId in keyValueStorage.userListingsWithExpressChatMessageSent {
            if listingSentId == listingId { return true }
        }
        return false
    }
}

extension ChatViewModel: MeetingAssistantDataDelegate {
    func sendMeeting(meeting: AssistantMeeting, isSuggestedPlace: Bool?) {
        sendMeetingMessage(meeting: meeting, isSuggestedPlace: isSuggestedPlace)
    }
}


extension ChatViewModel {

    func openDeeplink(url: URL, trackingKey: String?) {
        if let trackingKey = trackingKey {
            let isLetgoAssistant = EventParameterBoolean(bool: isUserDummy)
            let trackerEvent = TrackerEvent.chatCallToActionTapped(ctaKey: trackingKey,
                                                                   isLetgoAssistant: isLetgoAssistant)
            tracker.trackEvent(trackerEvent)
        }
        navigator?.navigate(with: url)
    }

    func acceptMeeting() {
        let acceptedMeeting = LGAssistantMeeting(meetingType: .accepted,
                                                 date: nil,
                                                 locationName: nil,
                                                 coordinates: nil,
                                                 status: .accepted)
        sendMeetingMessage(meeting: acceptedMeeting, isSuggestedPlace: nil)
        markAsAcceptedLastMeetingAndRejectOthers()
    }

    func rejectMeeting() {
        let rejectedMeeting = LGAssistantMeeting(meetingType: .rejected,
                                                 date: nil,
                                                 locationName: nil,
                                                 coordinates: nil,
                                                 status: .rejected)
        sendMeetingMessage(meeting: rejectedMeeting, isSuggestedPlace: nil)
    }

    private func markAsAcceptedLastMeetingAndRejectOthers() {
        var firstMeetingId: String?
        var otherMeetingIds: [String] = []
        for chatViewMessage in messages.value {
            if case .meeting(let type, _, _, _, _, _) = chatViewMessage.type,
                let meetingId = chatViewMessage.objectId, type == .requested {
                
                if firstMeetingId == nil {
                    firstMeetingId = meetingId
                } else {
                    otherMeetingIds.append(meetingId)
                }
            }
        }
        markMeetingAsAccepted(firstMeetingId)
        markMeetingsAsRejected(otherMeetingIds)
    }

    private func markAllPreviousRequestedMeetingsAsRejectedAfter(messageId: String?) {
        var meetingIds: [String] = []
        for chatViewMessage in messages.value {
            if case .meeting(let type, _, _, _, _, _) = chatViewMessage.type,
                let meetingId = chatViewMessage.objectId,
                type == .requested,
                meetingId != messageId {
                
                meetingIds.append(meetingId)
            }
        }
        markMeetingsAsRejected(meetingIds)
    }

    private func markMeetingsAsRejected(_ messagesIds: [String]) {
        messagesIds.forEach { [weak self] messageId in
            self?.updateMessageWithAction(messageId) { $0.markAsRejected() }
        }
    }

    private func markMeetingAsAccepted(_ messageId: String?) {
        guard let messageId = messageId else { return }
        updateMessageWithAction(messageId) { $0.markAsAccepted() }
    }

    private func updateMeetingsStatusAfterReceiving(message: ChatMessage) {
        updateMeetingsStatusFor(message: message)
    }

    private func updateMeetingsStatusAfterSending(message: ChatMessage) {
        updateMeetingsStatusFor(message: message)
    }

    private func updateMeetingsStatusFor(message: ChatMessage) {
        guard let meeting = message.assistantMeeting else { return }
        switch meeting.meetingType {
        case .rejected:
            markAllPreviousRequestedMeetingsAsRejectedAfter(messageId: nil)
        case .accepted:
            markAsAcceptedLastMeetingAndRejectOthers()
        case .requested:
            markAllPreviousRequestedMeetingsAsRejectedAfter(messageId: message.objectId)
        }
    }

    private func firstMeetingIn(messages: [ChatMessage]) -> ChatMessage? {
        return messages.first(matching: { $0.content.type == .meeting } )
    }
}
