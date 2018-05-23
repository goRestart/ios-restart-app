import LGCoreKit
import RxSwift
import LGComponents

typealias NavigationActionSheet = (cancelTitle: String, actions: [UIAction])

final class ChatConversationsListViewModel: BaseViewModel, RxPaginable {
    
    weak var navigator: ChatsTabNavigator?

    private let chatRepository: ChatRepository
    private let sessionManager: SessionManager
    private let tracker: TrackerProxy
    private let featureFlags: FeatureFlaggeable
    
    let rx_navigationBarTitle = Variable<String?>(nil)
    let rx_navigationBarFilterButtonImage = Variable<UIImage?>(nil)
    let rx_navigationActionSheet = PublishSubject<NavigationActionSheet>()
    let rx_isEditing = Variable<Bool>(false)
    let rx_conversations = Variable<[ChatConversation]>([])
    let rx_filter = Variable<ChatConversationsListFilter>(.all)
    let rx_inactiveConversationsCount = Variable<Int?>(nil)
    let rx_viewState = Variable<ViewState>(.loading)
    let rx_wsChatStatus = Variable<WSChatStatus>(.closed)
    let rx_reachability = Variable<Bool>(true)
    
    private let bag = DisposeBag()
    private var conversationsFilterBag: DisposeBag? = DisposeBag()
    
    var deleteActionBlock: (() -> Void)?
    
    // MARK: Lifecycle
    
    convenience override init() {
        self.init(chatRepository: Core.chatRepository,
                  sessionManager: Core.sessionManager,
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }
    
    init(chatRepository: ChatRepository,
         sessionManager: SessionManager,
         featureFlags: FeatureFlags,
         tracker: TrackerProxy) {
        self.chatRepository = chatRepository
        self.sessionManager = sessionManager
        self.featureFlags = featureFlags
        self.tracker = tracker
        super.init()
        setupRx()
    }
    
    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        
        
    }
    
    // MARK: Navigation Bar
    
    func navigationBarTitle(with filter: ChatConversationsListFilter) -> String {
        if case .all = filter {
            return R.Strings.chatListTitle
        }
        return R.Strings.chatListTitle + " (\(filter.localizedString))"
    }
    
    // MARK: Actions
    
    func openOptionsActionSheet() {
        var deleteAction: UIAction {
            return UIAction(interface: .text(R.Strings.chatListDelete),
                            action: { [weak self] in self?.deleteActionBlock?() })
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
    
    func switchEditing() {
        rx_isEditing.value = !rx_isEditing.value
    }

    // MARK: Rx
    
    private func setupRx() {
        rx_filter
            .asObservable()
            .bind { [weak self] filter in
                self?.rx_navigationBarTitle.value = self?.navigationBarTitle(with: filter)
                self?.rx_navigationBarFilterButtonImage.value = filter.filterIcon
                self?.setupRx(for: filter)
            }
            .disposed(by: bag)
        
        chatRepository.inactiveConversationsCount
            .asObservable()
            .bind(to: rx_inactiveConversationsCount)
            .disposed(by: bag)
        
        chatRepository.chatStatus
            .asObservable()
            .bind(to: rx_wsChatStatus)
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
        
        func bind(_ collection: CollectionVariable<ChatConversation>,
                  to conversations: Variable<[ChatConversation]>) {
            collection
                .observable
                .bind { [weak self] conversations in
                    self?.rx_conversations.value = conversations
                }
                .disposed(by: conversationsFilterBag)
        }
        
        switch filter {
        case .all:
            bind(chatRepository.allConversations, to: rx_conversations)
        case .selling:
            bind(chatRepository.sellingConversations, to: rx_conversations)
        case .buying:
            bind(chatRepository.buyingConversations, to: rx_conversations)
        }
    }
    
    // MARK: Pagination protocol

    var firstPage: Int = 1
    var resultsPerPage: Int = 20
    var nextPage: Int = 1
    var isLastPage: Bool = false
    var isLoading: Bool = false
    var objectCount: Int {
        return rx_objectCount.value
    }
    var rx_objectCount = Variable<Int>(0)
    
    func retrievePage(_ page: Int) {

    }
    
    // MARK: Pagination helpers

    func refreshCurrentPage(completion: (() -> Void)? = nil) {
        // refresh data from chat repo
        completion?()
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
                                action: { [weak self] in self?.refreshCurrentPage() },
                                secondaryButtonTitle: nil,
                                secondaryAction: nil,
                                emptyReason: .verification,
                                errorCode: nil,
                                errorDescription: nil)
    }
    
    private func emptyViewModel(for filter: ChatConversationsListFilter) -> LGEmptyViewModel {
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
    
    private func emptyViewModel(for error: RepositoryError) -> LGEmptyViewModel? {
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
                                                        errorDescription: nil))
    }
}
