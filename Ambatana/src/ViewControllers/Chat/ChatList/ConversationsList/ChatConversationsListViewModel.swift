import LGCoreKit
import RxSwift
import RxCocoa
import LGComponents
import GoogleMobileAds

final class ChatConversationsListViewModel: ChatBaseViewModel, Paginable {
    
    weak var navigator: ChatsTabNavigator?

    private let chatRepository: ChatRepository
    private let sessionManager: SessionManager
    private let notificationsManager: NotificationsManager
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    private var websocketWasClosedDuringCurrentSession = false
    private var localChatCounter: Int = 0
    private let myUserRepository: MyUserRepository
    private let monetizationRepository: MonetizationRepository
    var adData: ConversationAdCellData?
    
    let rx_navigationBarTitle = Variable<String?>(nil)
    let rx_navigationBarFilterButtonImage = Variable<UIImage>(R.Asset.IconsButtons.icChatFilter.image)
    let rx_isEditing = Variable<Bool>(false)
    let rx_conversations = Variable<[ChatConversation]>([])
    let rx_items = Variable<[Any]>([])
    let rx_ad = Variable<ConversationAdCellData?>(nil)
    let rx_viewState = Variable<ViewState>(.loading)
    var viewState: Driver<ViewState> { return rx_viewState.asDriver().distinctUntilChanged() }
    let rx_connectionBarStatus = Variable<ChatConnectionBarStatus>(.wsConnected)
    private let rx_filter = Variable<ChatConversationsListFilter>(.all)
    private let rx_inactiveConversationsCount = Variable<Int?>(nil)
    private let rx_wsChatStatus = Variable<WSChatStatus>(.closed)
    private var bumpeableCheckInProgress: Bool = false
    private var conversationsFilterBag: DisposeBag? = DisposeBag()

    // MARK: Lifecycle

    init(chatRepository: ChatRepository = Core.chatRepository,
         sessionManager: SessionManager = Core.sessionManager,
         notificationsManager: NotificationsManager = LGNotificationsManager.sharedInstance,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance,
         tracker: Tracker = TrackerProxy.sharedInstance,
         myUserRepository: MyUserRepository = Core.myUserRepository,
         monetizationRepository: MonetizationRepository = Core.monetizationRepository) {
        self.chatRepository = chatRepository
        self.sessionManager = sessionManager
        self.notificationsManager = notificationsManager
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.myUserRepository = myUserRepository
        self.monetizationRepository = monetizationRepository
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        
        if firstTime {
            setupChatRepositoryRx()
            setupRx()
        } else {
            retrieveFirstPageIfNeeded()
        }
    }
    
    private func reset() {
        rx_viewState.value = .loading
        rx_conversations.value = []
        rx_isEditing.value = false
        rx_inactiveConversationsCount.value = nil
    }
    
    // MARK: Navigation Bar
    
    func navigationBarTitle(with filter: ChatConversationsListFilter) -> String {
        if case .all = filter {
            return R.Strings.chatListTitle
        }
        return R.Strings.chatListTitle + " (\(filter.localizedString))"
    }
    
    // MARK: Navigation Bar Actions
    
    private func presentActionSheet(with actions: [UIAction]) {
        switchEditMode(isEditing: false)
        rx_vmPresentActionSheet.onNext(VMActionSheet(actions: actions))
    }
    
    private func presentDeleteAlert(for conversation: ChatConversation) {
        let cancelAction = VMAction(title: R.Strings.commonCancel,
                                    style: .cancel)
        let okAction = VMAction(title: R.Strings.chatListDeleteAlertSend,
                                style: .destructive) { [weak self] in
                                    self?.deleteConversation(conversation: conversation)
        }
        rx_vmPresentAlert.onNext(VMPresentAlert(title: R.Strings.chatListDeleteAlertTitleOne,
                                                message: R.Strings.chatListDeleteAlertTextOne,
                                                actions: [cancelAction, okAction]))
    }

    private func presentNotBumpeableAlert() {
        rx_vmPresentAutofadingAlert.onNext(VMPresentAutofadingAlert(title: nil,
                                                message: R.Strings.bumpUpChatListFailAlert))
    }
    
    func openOptionsActionSheet() {
        var deleteAction: UIAction {
            return UIAction(interface: .text(R.Strings.chatListDelete),
                            action: { [weak self] in self?.switchEditMode(isEditing: true) })
        }
        var markAllConvesationsAsReadAction: UIAction {
            return UIAction(interface: .text(R.Strings.chatMarkConversationAsReadButton),
                            action: { [weak self] in self?.markAllConversationAsRead() })
        }
        var showBlockedUsersAction: UIAction {
            return UIAction(interface: .text(R.Strings.chatConversationsListBlockedUsersButton),
                            action: { [weak self] in self?.openBlockedUsers() })
        }
        var showInactiveConversationsAction: UIAction {
            var buttonText: String = R.Strings.chatInactiveConversationsButton
            if let inactiveCount = rx_inactiveConversationsCount.value, inactiveCount > 0 {
                buttonText = buttonText + " (\(inactiveCount))"
            }
            return UIAction(interface: .text(buttonText),
                            action: { [weak self] in self?.openInactiveConversations() })
        }
        
        var actions: [UIAction] = []
        actions.append(deleteAction)
        actions.append(markAllConvesationsAsReadAction)
        if featureFlags.showInactiveConversations {
            actions.append(showInactiveConversationsAction)
        }
        actions.append(showBlockedUsersAction)
        presentActionSheet(with: actions)
    }
    
    func openFiltersActionSheet() {
        let filters: [ChatConversationsListFilter] = [.all, .selling, .buying]
        var actions: [UIAction] = []
        filters.forEach { filter in
            actions.append(UIAction(interface: .text(filter.localizedString),
                                    action: { [weak self] in self?.rx_filter.value = filter }))
        }
        presentActionSheet(with: actions)
    }
    
    func switchEditMode(isEditing: Bool) {
        rx_isEditing.value = isEditing
    }

    func markAllConversationAsRead() {
        trackMarkAllConversationsAsRead()
        chatRepository.markAllConversationsAsRead(completion: nil)
    }

    func openBlockedUsers() {
        navigator?.openBlockedUsers()
    }
    
    func openInactiveConversations() {
        navigator?.openInactiveConversations()
    }
    
    // MARK: Table View Actions
    
    func tableViewDidSelectItem(at indexPath: IndexPath) {
        var position: Int
        if let adData = adData {
            guard indexPath.row != adData.position else { return }
            position = (indexPath.row < adData.position) ? indexPath.row : indexPath.row - 1
        }
        else {
            position = indexPath.row
        }
        guard rx_conversations.value.indices.contains(position) else { return }
        let conversation = rx_conversations.value[position]
        navigator?.openChat(.conversation(conversation: conversation),
                            source: .chatList,
                            predefinedMessage: nil)
    }
    
    func tableViewDidDeleteItem(at indexPath: IndexPath) {
        var position: Int
        if let adData = adData {
            guard indexPath.row != adData.position else { return }
            position = (indexPath.row < adData.position) ? indexPath.row : indexPath.row - 1
        } else {
            position = indexPath.row
        }
        guard rx_conversations.value.indices.contains(position) else { return }
        let conversation = rx_conversations.value[position]
        presentDeleteAlert(for: conversation)
    }
    
    func deleteConversation(conversation: ChatConversation) {
        guard let conversationId = conversation.objectId else { return }
        rx_vmPresentLoadingMessage.onNext(VMPresentLoadingMessage())
        chatRepository.archiveConversations([conversationId]) { [weak self] result in
            if let _ = result.value {
                self?.trackChatDeleteComplete()
                self?.rx_vmDismissLoadingMessage.onNext(VMDismissLoadingMessage())
            } else if let _ = result.error {
                self?.rx_vmDismissLoadingMessage.onNext(
                    VMDismissLoadingMessage(endingMessage: R.Strings.chatListDeleteErrorOne,
                                            completion: { [weak self] in
                                                self?.retrieveFirstPage()
                    })
                )
            }
        }
    }
    
    // MARK: Ads
    
    func shouldShowAds() -> Bool {
        let creationDate = myUserRepository.myUser?.creationDate
        return featureFlags.multiAdRequestInChatSectionForUS.shouldShowAdsForUser(createdIn: creationDate) ||
            featureFlags.multiAdRequestInChatSectionForTR.shouldShowAdsForUser(createdIn: creationDate)
    }
    
    // MARK: Rx
    
    private func setupChatRepositoryRx() {
        chatRepository.inactiveConversationsCount
            .asObservable()
            .bind(to: rx_inactiveConversationsCount)
            .disposed(by: bag)
        
        chatRepository.chatStatus
            .asObservable()
            .bind(to: rx_wsChatStatus)
            .disposed(by: bag)
        
        sessionManager.sessionEvents
            .filter { return $0.isLogout }
            .bind(onNext: { [weak self] _ in
                self?.reset()
            })
            .disposed(by: bag)
    }
    
    private func setupRx() {
        rx_filter
            .asObservable()
            .bind { [weak self] filter in
                self?.rx_navigationBarTitle.value = self?.navigationBarTitle(with: filter)
                self?.rx_navigationBarFilterButtonImage.value = filter.filterIcon
                self?.rx_viewState.value = .loading
                self?.rx_conversations.value = []
                self?.setupRx(for: filter)
                self?.retrieveFirstPageIfNeeded()
            }
            .disposed(by: bag)
        
        rx_filter
            .asObservable()
            .skip(1)
            .bind { [weak self] filter in
                self?.trackFilterChanged(filter)
            }
            .disposed(by: bag)
        
        Observable.combineLatest(rx_wsChatStatus.asObservable(),
                                 rx_isReachable.asObservable())
            .asObservable()
            .skip(1)
            .bind { [weak self] (wsChatStatus, isReachable) in
                if wsChatStatus == .closed || !isReachable {
                    self?.websocketWasClosedDuringCurrentSession = true
                }
                guard isReachable else {
                    self?.rx_connectionBarStatus.value = .noNetwork
                    return
                }
                switch wsChatStatus {
                case .openAuthenticated, .openNotVerified:
                    self?.rx_connectionBarStatus.value = .wsConnected
                case .closed, .closing:
                    self?.rx_connectionBarStatus.value = .wsClosed(reconnectBlock: { [weak self] in
                        self?.retrieveFirstPage()
                    })
                case .opening, .openNotAuthenticated:
                    self?.rx_connectionBarStatus.value = .wsConnecting
                }
            }
            .disposed(by: bag)

        rx_viewState
            .asObservable()
            .bind { [weak self] viewState in
                if case .error(let emptyViewModel) = viewState {
                    self?.trackEmptyState(emptyViewModel: emptyViewModel)
                }
            }
            .disposed(by: bag)
        
        rx_conversations
            .asObservable()
            .bind { [weak self] conversations in
                self?.updateViewState(for: conversations)
                self?.updateChatCounter(for: conversations)
            }
            .disposed(by: bag)
        
        notificationsManager.unreadMessagesCount
            .asObservable()
            .ignoreNil()
            .distinctUntilChanged()
            .bind { [weak self] unreadMessagesCount in
                self?.localChatCounter = unreadMessagesCount
            }
            .disposed(by: bag)
    }
    
    private func setupRx(for filter: ChatConversationsListFilter) {
        conversationsFilterBag = DisposeBag()
        guard let conversationsFilterBag = conversationsFilterBag else { return }
        
        let collectionVariable = filter.collectionVariable(from: chatRepository)
        collectionVariable
            .observable
            .bind { [weak self] conversations in
                self?.rx_conversations.value = conversations
            }
            .disposed(by: conversationsFilterBag)
    }
    
    // MARK: Helpers
    
    private func updateViewState(for conversations: [ChatConversation]) {
        guard conversations.count > 0 else { return }
        if rx_viewState.value != .data {
            rx_viewState.value = .data
        }
    }
    
    private func updateChatCounter(for conversations: [ChatConversation]) {
        let chatCounter = unreadCount(for: conversations)
        if localChatCounter != chatCounter {
            localChatCounter = chatCounter
            notificationsManager.updateChatCounters()
        }
    }
    
    func unreadCount(for conversations: [ChatConversation]) -> Int {
        return conversations
            .map { $0.unreadMessageCount }
            .reduce(0, +)
    }
    
    // MARK: Pagination protocol

    var firstPage: Int = 1
    var resultsPerPage: Int = 30
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return rx_conversations.value.count
    }
    
    func retrievePage(_ page: Int) {
        retrieve(page: page)
    }
    
    // MARK: Pagination helpers
    
    func retrieve(page: Int, completion: (() -> Void)? = nil) {
        guard canRetrieve else {
            completion?()
            return
        }
        let isFirstPage = (page == 1)
        var hasEmptyData: Bool {
            return isFirstPage && objectCount == 0
        }
        isLoading = true
        chatRepository.indexConversations(resultsPerPage,
                                          offset: max(0, page - 1) * resultsPerPage,
                                          filter: rx_filter.value.webSocketConversationFilter)
        { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.isLoading = false
            if let value = result.value {
                strongSelf.isLastPage = value.count < strongSelf.resultsPerPage
                strongSelf.nextPage = page + 1
                strongSelf.rx_viewState.value = hasEmptyData ?
                    .empty(strongSelf.emptyViewModel(forFilter: strongSelf.rx_filter.value)) :
                    .data
            } else if let error = result.error {
                if hasEmptyData, let emptyViewModel = strongSelf.emptyViewModel(forError: error) {
                    strongSelf.rx_viewState.value = .error(emptyViewModel)
                } else {
                    strongSelf.rx_viewState.value = .data
                }
            }
            completion?()
        }
    }

    func retrieveFirstPage(completion: (() -> Void)? = nil) {
        retrieve(page: 1, completion: completion)
    }
    
    /// We fetch if we don't have any conversation or the socket was not yet openAndAuthenticated.
    /// This way we prevent refreshing the first page when it's not needed (coming back to Chat tab).
    /// Also it prevents refreshing a filter that was previously refreshed.
    /// The idea is behind the fact that once the websocket is open and authenticated, any new conversation will come as
    /// a new event and it will be automatically handle to us from chatRepository.xxxConversations.
    private func retrieveFirstPageIfNeeded() {
        // We keep a flag for the case where the client reconnects to the chat at some point (where some events
        // could be missed) and therefor we force a refresh next time it goes to the chat tab
        if websocketWasClosedDuringCurrentSession {
            websocketWasClosedDuringCurrentSession = false
            retrieveFirstPage()
        } else if rx_wsChatStatus.value != .openAuthenticated || rx_viewState.value != .data {
            retrieveFirstPage()
        }
    }
    
    // MARK: Empty view models
    
    var verificationPendingEmptyViewModel: LGEmptyViewModel {
        return LGEmptyViewModel(icon: R.Asset.IconsButtons.icBuildTrustBig.image,
                                title: R.Strings.chatNotVerifiedStateTitle,
                                body: R.Strings.chatNotVerifiedStateMessage,
                                buttonTitle: R.Strings.chatNotVerifiedStateCheckButton,
                                action: { [weak self] in
                                    self?.retrieveFirstPage() },
                                secondaryButtonTitle: nil,
                                secondaryAction: nil,
                                emptyReason: .verification,
                                errorCode: nil,
                                errorDescription: nil)
    }
    
    func emptyViewModel(forFilter filter: ChatConversationsListFilter) -> LGEmptyViewModel {
        let openSellAction: (() -> Void)? = { [weak self] in
            let source: PostingSource = .chatList
            self?.trackStartSelling(source: source)
            self?.navigator?.openSell(source: source, postCategory: nil)
        }
        let openHomeAction: (() -> Void)? = { [weak self] in
            return self?.navigator?.openHome()
        }
        
        let primaryAction: (() -> Void)?
        var secundaryAction: (() -> Void)? = nil
        switch filter {
        case .all:
            primaryAction = openSellAction
            secundaryAction = openHomeAction
        case .selling:
            primaryAction = openSellAction
        case .buying:
            primaryAction = openHomeAction
        }
        return LGEmptyViewModel(icon: R.Asset.Errors.errListNoChats.image,
                                title: filter.emptyViewModelTitleLocalizedString,
                                body: nil,
                                buttonTitle: filter.emptyViewModelPrimaryButtonTitleLocalizedString,
                                action: primaryAction,
                                secondaryButtonTitle: filter.emptyViewModelSecundaryButtonTitleLocalizedString,
                                secondaryAction: secundaryAction,
                                emptyReason: nil,
                                errorCode: nil,
                                errorDescription: nil)
    }
    
    func emptyViewModel(forError error: RepositoryError) -> LGEmptyViewModel? {
        return LGEmptyViewModel.map(from: error, action: { [weak self] in
            self?.retrieveFirstPage()
        })
    }

    func bumpUpPressedFor(listingId: String) {
        guard !bumpeableCheckInProgress else { return }
        bumpeableCheckInProgress = true
        let bumpCheckOkCompletion = { [weak self] in
            let data = ListingDetailData.id(listingId: listingId)
            let actionOnFirstAppear = ProductCarouselActionOnFirstAppear.triggerBumpUp(purchases: [],
                                                                                       maxCountdown: 0,
                                                                                       bumpUpType: nil,
                                                                                       triggerBumpUpSource: .chatList,
                                                                                       typePage: .chatList)
            self?.navigator?.openListing(data, source: .chat, actionOnFirstAppear: actionOnFirstAppear)
        }
        monetizationRepository.retrieveBumpeableListingInfo(listingId: listingId,
                                                            completion: { [weak self] result in
                                                                if let _ = result.value {
                                                                    bumpCheckOkCompletion()
                                                                } else {
                                                                    self?.presentNotBumpeableAlert()
                                                                }
                                                                self?.bumpeableCheckInProgress = false
        })
    }


    // MARK: - Trackings

    private func trackFilterChanged(_ filter: ChatConversationsListFilter) {
        tracker.trackEvent(.chatFilterChanged(filter))
    }
    
    private func trackEmptyState(emptyViewModel: LGEmptyViewModel) {
        guard let emptyReason = emptyViewModel.emptyReason else { return }
        tracker.trackEvent(TrackerEvent.emptyStateVisit(typePage: .chatList,
                                                        reason: emptyReason,
                                                        errorCode: emptyViewModel.errorCode,
                                                        errorDescription: emptyViewModel.errorDescription))
    }

    private func trackStartSelling(source: PostingSource) {
        tracker.trackEvent(TrackerEvent.listingSellStart(typePage: source.typePage,
                                                         buttonName: source.buttonName,
                                                         sellButtonPosition: source.sellButtonPosition,
                                                         category: nil))
    }
    private func trackMarkAllConversationsAsRead() {
        tracker.trackEvent(TrackerEvent.chatMarkMessagesAsRead())
    }
    
    private func trackChatDeleteComplete() {
        tracker.trackEvent(TrackerEvent.chatDeleteComplete(numberOfConversations: 1,
                                                           isInactiveConversation: false))
    }
    
    func adTapped(willLeaveApp: Bool, bannerSize: CGSize) {
        let adType = AdRequestType.dfp.trackingParamValueFor(size: bannerSize)
        let willLeave = EventParameterBoolean(bool: willLeaveApp)
        let isMine: EventParameterBoolean = .falseParameter
        let trackerEvent = TrackerEvent.adTapped(listingId: nil,
                                                 adType: adType,
                                                 isMine: isMine,
                                                 queryType: nil,
                                                 query: nil,
                                                 willLeaveApp: willLeave,
                                                 hasVideoContent: nil,
                                                 typePage: EventParameterTypePage.chatList,
                                                 categories: nil,
                                                 feedPosition: .none)
        tracker.trackEvent(trackerEvent)
    }
    
    func adShown(bannerSize: CGSize) {
        let adType = AdRequestType.dfp.trackingParamValueFor(size: bannerSize)
        let adShown: EventParameterBoolean = .trueParameter
        let isMine: EventParameterBoolean = .falseParameter
        let trackerEvent = TrackerEvent.adShown(listingId: nil,
                                                adType: adType,
                                                isMine: isMine,
                                                queryType: nil,
                                                query: nil,
                                                adShown: adShown,
                                                typePage: EventParameterTypePage.chatList,
                                                categories: nil,
                                                feedPosition: .none)
        tracker.trackEvent(trackerEvent)
    }
    func adError(bannerSize: CGSize, errorCode: GADErrorCode) {
        let errorReason: EventParameterAdSenseRequestErrorReason? = EventParameterAdSenseRequestErrorReason(errorCode: errorCode)
        let adType = AdRequestType.dfp.trackingParamValueFor(size: nil)
        let adShown: EventParameterBoolean = .falseParameter
        let trackerEvent = TrackerEvent.adError(adShown: adShown, adType: adType, typePage: EventParameterTypePage.chatList, errorReason: errorReason)
        
        tracker.trackEvent(trackerEvent)
        
    }
    
    
}
