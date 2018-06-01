import LGCoreKit
import RxSwift
import LGComponents

enum ChatConnectionBarStatus {
    case noNetwork
    case wsClosed(reconnectBlock: (() -> Void)?)
    case wsConnecting
    case wsConnected

    var title: NSAttributedString? {
        switch self {
        case .noNetwork:
            return NSAttributedString(string: R.Strings.chatStatusViewNoNetwork)
        case .wsClosed:
            let tryAgain = R.Strings.chatStatusViewTryAgain
            let tryAgainAttributes: [NSAttributedStringKey: Any] = [.foregroundColor : UIColor.macaroniAndCheese,
                                                                    .underlineStyle: NSUnderlineStyle.styleSingle.rawValue,
                                                                    .underlineColor: UIColor.macaroniAndCheese]
            let unableToConnectString = R.Strings.chatStatusViewUnableToConnect
            let finalAttributtedString = NSMutableAttributedString(string: unableToConnectString)
            let tryAgainRange = NSString(string: unableToConnectString).range(of: tryAgain)
            print(tryAgainRange)
            finalAttributtedString.setAttributes(tryAgainAttributes, range: tryAgainRange)
            return finalAttributtedString
        case .wsConnecting:
            return NSAttributedString(string: R.Strings.chatStatusViewConnecting)
        case .wsConnected:
            return nil
        }
    }

    var showActivityIndicator: Bool {
        switch self {
        case .noNetwork, .wsClosed, .wsConnected:
            return false
        case .wsConnecting:
            return true
        }
    }

    var actionBlock: (()->Void)? {
        switch self {
        case .noNetwork, .wsConnecting, .wsConnected:
            return nil
        case .wsClosed(let reconnectBlock):
            return reconnectBlock
        }
    }
}

typealias NavigationActionSheet = (cancelTitle: String, actions: [UIAction])

final class ChatConversationsListViewModel: BaseViewModel, Paginable {
    
    struct Localize {
        static let deleteAlertConfirmationTitle = R.Strings.chatListDeleteAlertTitleOne
        static let deleteAlertConfirmationMessage = R.Strings.chatListDeleteAlertTextOne
        static let deleteAlertConfirmationButtonOk = R.Strings.chatListDeleteAlertSend
        static let buttonCancel = R.Strings.commonCancel
        static let deleteAlertDidStart = R.Strings.commonLoading
        static let deleteAlertDidFailMessage = R.Strings.chatListDeleteErrorOne
    }
    
    weak var navigator: ChatsTabNavigator?

    private let chatRepository: ChatRepository
    private let sessionManager: SessionManager
    private let reachability: ReachabilityProtocol
    private let tracker: TrackerProxy
    private let featureFlags: FeatureFlaggeable
    
    var deleteConversationConfirmationBlock: ((ChatConversation) -> Void)?
    var deleteConversationDidStartBlock: ((String) -> Void)?
    var deleteConversationDidSuccessBlock: (() -> Void)?
    var deleteConversationDidFailBlock: ((String) -> Void)?
    private var websocketWasClosedDuringCurrentSession = false
    
    let rx_navigationBarTitle = Variable<String?>(nil)
    let rx_navigationBarFilterButtonImage = Variable<UIImage>(R.Asset.IconsButtons.icChatFilter.image)
    let rx_navigationActionSheet = PublishSubject<NavigationActionSheet>()
    let rx_isEditing = Variable<Bool>(false)
    let rx_conversations = Variable<[ChatConversation]>([])
    let rx_viewState = Variable<ViewState>(.loading)
    private let rx_filter = Variable<ChatConversationsListFilter>(.all)
    private let rx_inactiveConversationsCount = Variable<Int?>(nil)
    private let rx_wsChatStatus = Variable<WSChatStatus>(.closed)
    private let rx_isReachable = Variable<Bool>(true)
    private let bag = DisposeBag()
    private var conversationsFilterBag: DisposeBag? = DisposeBag()

    let rx_connectionBarStatus = Variable<ChatConnectionBarStatus>(.wsConnected)

    // MARK: Lifecycle
    
    convenience override init() {
        self.init(chatRepository: Core.chatRepository,
                  sessionManager: Core.sessionManager,
                  reachability: LGReachability(),
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(chatRepository: ChatRepository,
         sessionManager: SessionManager,
         reachability: ReachabilityProtocol,
         featureFlags: FeatureFlags,
         tracker: TrackerProxy) {
        self.chatRepository = chatRepository
        self.sessionManager = sessionManager
        self.reachability = reachability
        self.featureFlags = featureFlags
        self.tracker = tracker
        super.init()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        
        if firstTime {
            setupReachability()
            setupChatRepositoryRx()
            setupRx()
        } else {
            retrieveFirstPageIfNeeded()
        }
    }
    
    // MARK: Navigation Bar
    
    func navigationBarTitle(with filter: ChatConversationsListFilter) -> String {
        if case .all = filter {
            return R.Strings.chatListTitle
        }
        return R.Strings.chatListTitle + " (\(filter.localizedString))"
    }
    
    // MARK: Navigation Bar Actions
    
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
        if featureFlags.markAllConversationsAsRead.isActive {
            actions.append(markAllConvesationsAsReadAction)
        }
        if featureFlags.showInactiveConversations {
            actions.append(showInactiveConversationsAction)
        }
        actions.append(showBlockedUsersAction)
        rx_navigationActionSheet.onNext((cancelTitle: R.Strings.commonCancel, actions: actions))
    }
    
    func openFiltersActionSheet() {
        let filters: [ChatConversationsListFilter] = [.all, .selling, .buying]
        var actions: [UIAction] = []
        filters.forEach { filter in
            actions.append(UIAction(interface: .text(filter.localizedString),
                                    action: { [weak self] in self?.rx_filter.value = filter }))
        }
        rx_navigationActionSheet.onNext((cancelTitle: R.Strings.commonCancel, actions: actions))
    }
    
    func switchEditMode(isEditing: Bool) {
        rx_isEditing.value = isEditing
    }

    func markAllConversationAsRead() {
        tracker.trackEvent(TrackerEvent.chatMarkMessagesAsRead())
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
        guard rx_conversations.value.indices.contains(indexPath.row) else { return }
        let conversation = rx_conversations.value[indexPath.row]
        navigator?.openChat(.conversation(conversation: conversation),
                            source: .chatList,
                            predefinedMessage: nil)
    }
    
    func tableViewDidDeleteItem(at indexPath: IndexPath) {
        guard rx_conversations.value.indices.contains(indexPath.row) else { return }
        let conversation = rx_conversations.value[indexPath.row]
        deleteConversationConfirmationBlock?(conversation)
    }
    
    func deleteConversation(conversation: ChatConversation) {
        guard let conversationId = conversation.objectId else { return }
        deleteConversationDidStartBlock?(Localize.deleteAlertDidStart)
        chatRepository.archiveConversations([conversationId]) { [weak self] result in
            if let _ = result.value {
                self?.tracker.trackEvent(TrackerEvent.chatDeleteComplete(numberOfConversations: 1,
                                                                         isInactiveConversation: false))
                self?.deleteConversationDidSuccessBlock?()
            } else if let _ = result.error {
                self?.deleteConversationDidFailBlock?(Localize.deleteAlertDidFailMessage)
            }
        }
    }

    // MARK: Reachability
    
    private func setupReachability() {
        reachability.reachableBlock = { [weak self] in
            self?.rx_isReachable.value = true
        }
        reachability.unreachableBlock = { [weak self] in
            self?.rx_isReachable.value = false
        }
        reachability.start()
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
                    self?.rx_connectionBarStatus.value = .wsClosed { [weak self] in self?.retrieveFirstPage() }
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
        } else if rx_wsChatStatus.value != .openAuthenticated || objectCount == 0 {
            retrieveFirstPage()
        }
    }
    
    // MARK: Empty view models
    
    func setEmptyState(emptyViewModel: LGEmptyViewModel) {
        trackEmptyState(emptyViewModel: emptyViewModel)
    }
    
    private var verificationPendingEmptyViewModel: LGEmptyViewModel {
        return LGEmptyViewModel(icon: #imageLiteral(resourceName: "ic_build_trust_big"),
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
    
    private func emptyViewModel(forFilter filter: ChatConversationsListFilter) -> LGEmptyViewModel {
        let openSellAction: (() -> Void)? = { [weak self] in
            return self?.navigator?.openSell(source: .sellButton, postCategory: nil)
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
        return LGEmptyViewModel(icon: #imageLiteral(resourceName: "err_list_no_chats"),
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
    
    private func emptyViewModel(forError error: RepositoryError) -> LGEmptyViewModel? {
        return LGEmptyViewModel.map(from: error, action: { [weak self] in
            self?.retrieveFirstPage()
        })
    }
    
    // MARK: Trackings
    
    private func trackEmptyState(emptyViewModel: LGEmptyViewModel) {
        guard let emptyReason = emptyViewModel.emptyReason else { return }
        tracker.trackEvent(TrackerEvent.emptyStateVisit(typePage: .chatList,
                                                        reason: emptyReason,
                                                        errorCode: emptyViewModel.errorCode,
                                                        errorDescription: emptyViewModel.errorDescription))
    }
}
