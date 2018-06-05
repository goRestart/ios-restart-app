import LGCoreKit
import RxSwift
import LGComponents

protocol ChatGroupedViewModelDelegate: BaseViewModelDelegate {
    func vmDidPressDelete()
}

class ChatGroupedViewModel: BaseViewModel {

    enum Tab: Int {
        case all = 0, selling = 1, buying = 2, blockedUsers = 3

        var chatsType: ChatsType? {
            switch(self) {
            case .all:
                return .all
            case .selling:
                return .selling
            case .buying:
                return .buying
            case .blockedUsers:
                return nil
            }
        }

        func editButtonText(_ editing: Bool) -> String {
            guard !editing else { return R.Strings.commonCancel }

            switch(self) {
            case .all, .selling, .buying:
                return R.Strings.chatListDelete
            case .blockedUsers:
                return R.Strings.chatListUnblock
            }
        }
        
        func markAllConversationAsReadButtonEnabled(isFeatureFlagEnabled: Bool) -> Bool {
            guard isFeatureFlagEnabled else { return false }
            switch self {
            case .all, .selling, .buying:
                return true
            case .blockedUsers:
                return false
            }
        }

        static var allValues: [Tab] {
            return [.all, .selling, .buying, .blockedUsers]
        }
    }

    fileprivate var chatListViewModels: [ChatListViewModel]
    fileprivate(set) var blockedUsersListViewModel: BlockedUsersListViewModel
    fileprivate let currentPageViewModel = Variable<ChatGroupedListViewModelType?>(nil)

    fileprivate let myUserRepository: MyUserRepository
    fileprivate let chatRepository: ChatRepository
    fileprivate let featureFlags: FeatureFlaggeable
    private let tracker: TrackerProxy

    weak var tabNavigator: TabNavigator? {
        didSet {
            chatListViewModels.forEach { $0.tabNavigator = tabNavigator }
            blockedUsersListViewModel.tabNavigator = tabNavigator
        }
    }
    weak var delegate: ChatGroupedViewModelDelegate?
    var verificationPendingEmptyVM: LGEmptyViewModel?

    let editButtonText = Variable<String?>(nil)
    let editButtonEnabled = Variable<Bool>(true)

    let verificationPending = Variable<Bool>(false)

    fileprivate let disposeBag: DisposeBag


    // MARK: - Lifecycle

    override convenience init() {
        self.init(myUserRepository: Core.myUserRepository,
                  chatRepository: Core.chatRepository,
                  featureFlags: FeatureFlags.sharedInstance,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(myUserRepository: MyUserRepository,
         chatRepository: ChatRepository,
         featureFlags: FeatureFlaggeable,
         tracker: TrackerProxy) {
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.featureFlags = featureFlags
        self.tracker = tracker
        self.chatListViewModels = []
        self.blockedUsersListViewModel = BlockedUsersListViewModel()
        self.disposeBag = DisposeBag()
        
        super.init()

        for index in 0..<tabCount {
            guard let tab = Tab(rawValue: index) else { continue }
            switch tab {
            case .all:
                guard let chatsType = tab.chatsType else { continue }
                chatListViewModels.append(buildChatListAll(chatsType))
            case.selling:
                guard let chatsType = tab.chatsType else { continue }
                chatListViewModels.append(buildChatListSelling(chatsType))
            case .buying:
                guard let chatsType = tab.chatsType else { continue }
                chatListViewModels.append(buildChatListBuying(chatsType))
            case .blockedUsers:
                blockedUsersListViewModel.emptyStatusViewModel = LGEmptyViewModel(
                    icon: R.Asset.Errors.errListNoBlockedUsers.image,
                    title: R.Strings.chatListBlockedEmptyTitle,
                    body: R.Strings.chatListBlockedEmptyBody, buttonTitle: nil, action: nil,
                    secondaryButtonTitle: nil, secondaryAction: nil, emptyReason: .emptyResults, errorCode: nil,
                    errorDescription: nil)
            }
        }
        setupRxBindings()
        setupVerificationPendingEmptyVM()
    }

    func setupVerificationPendingEmptyVM() {
        verificationPendingEmptyVM = LGEmptyViewModel(icon: R.Asset.IconsButtons.icBuildTrustBig.image,
                                                      title: R.Strings.chatNotVerifiedStateTitle,
                                                      body: R.Strings.chatNotVerifiedStateMessage,
                                                      buttonTitle: R.Strings.chatNotVerifiedStateCheckButton,
                                                      action: { [weak self] in
                                                        self?.refreshCurrentPage()
                                                        },
                                                      secondaryButtonTitle: nil, secondaryAction: nil,
                                                      emptyReason: .verification, errorCode: nil, errorDescription: nil)
    }

    // MARK: - Public methods
    
    func setNeedsRefreshConversations() {
        chatListViewModels.forEach { $0.shouldRefreshConversationsTabTrigger = true }
    }
    
    // MARK: > Tab

    var tabCount: Int {
        return Tab.allValues.count
    }

    var chatListsCount: Int {
        return chatListViewModels.count
    }

    let currentTab = Variable<Tab>(.buying)

    func showInfoBadgeAtIndex(_ index: Int) -> Bool {
        guard let chatListVM = viewModelAtIndex(index) else { return false }
        return chatListVM.hasMessagesToRead
    }

    func titleForTabAtIndex(_ index: Int, selected: Bool) -> NSAttributedString {
        guard let tab = Tab(rawValue: index) else { return NSMutableAttributedString() }

        let color: UIColor = selected ? UIColor.primaryColor : UIColor.black

        var titleAttributes = [NSAttributedStringKey : Any]()
        titleAttributes[NSAttributedStringKey.foregroundColor] = color
        titleAttributes[NSAttributedStringKey.font] = selected ? UIFont.activeTabFont : UIFont.inactiveTabFont

        let string: NSAttributedString
        switch tab {
        case .all:
            string = NSAttributedString(string: R.Strings.chatListAllTitle, attributes: titleAttributes)
        case .buying:
            string = NSAttributedString(string: R.Strings.chatListBuyingTitle, attributes: titleAttributes)
        case .selling:
            string = NSAttributedString(string: R.Strings.chatListSellingTitle, attributes: titleAttributes)
        case .blockedUsers:
            string = NSAttributedString(string: R.Strings.chatListBlockedUsersTitle, attributes: titleAttributes)
        }
        return string
    }
    
    func accessibilityIdentifierForTabButtonAtIndex(_ index: Int) -> AccessibilityId? {
        guard let tab = Tab(rawValue: index) else { return nil }
        switch tab {
        case .all: return .chatListViewTabAll
        case .buying: return .chatListViewTabBuying
        case .selling: return .chatListViewTabSelling
        case .blockedUsers: return .chatListViewTabBlockedUsers
        }
    }
    
    func accessibilityIdentifierForTableViewAtIndex(_ index: Int) -> AccessibilityId? {
        guard let tab = Tab(rawValue: index) else { return nil }
        switch tab {
        case .all: return .chatListViewTabAllTableView
        case .buying: return .chatListViewTabBuyingTableView
        case .selling: return .chatListViewTabSellingTableView
        case .blockedUsers: return .chatListViewTabBlockedUsersTableView
        }
    }
    
    func blockedUserPressed(_ user: User) {
        let data = UserDetailData.userAPI(user: user, source: .chat)
        tabNavigator?.openUser(data)
    }

    func chatListViewModelForTabAtIndex(_ index: Int) -> ChatListViewModel? {
        guard let chatListVM = viewModelAtIndex(index) else { return nil }
        return chatListVM
    }
    
    func markAllConversationAsRead() {
        tracker.trackEvent(TrackerEvent.chatMarkMessagesAsRead())
        chatRepository.markAllConversationsAsRead(completion: nil)
    }


    // MARK: > Current page

    func refreshCurrentPage() {
        currentPageViewModel.value?.refresh(completion: nil)
    }

    func setCurrentPageEditing(_ editing: Bool) {
        currentPageViewModel.value?.editing.value = editing
    }
    
    func openMenuActionSheet() {
        var actions: [UIAction] = []
        
        if editButtonEnabled.value {
            actions.append(UIAction(interface: UIActionInterface.text(currentTab.value.editButtonText(false)),
                                    action: { [weak self] in
                                        self?.delegate?.vmDidPressDelete()
            }))
        }
        
        if currentTab.value.markAllConversationAsReadButtonEnabled(isFeatureFlagEnabled: featureFlags.markAllConversationsAsRead.isActive) {
            actions.append(UIAction(interface: UIActionInterface.text(R.Strings.chatMarkConversationAsReadButton),
                                    action: { [weak self] in
                                        self?.markAllConversationAsRead()
            }))
        }
        
        if let vm = currentPageViewModel.value, vm.shouldShowInactiveConversations {
            var buttonText: String = R.Strings.chatInactiveConversationsButton
            if let inactiveCount = vm.inactiveConversationsCount, inactiveCount > 0 {
                buttonText = buttonText + " (\(inactiveCount))"
            }
            actions.append(UIAction(interface: UIActionInterface.text(buttonText),
                                    action: { [weak self] in
                                        self?.currentPageViewModel.value?.openInactiveConversations()
            }))
        }
        
        delegate?.vmShowActionSheet(R.Strings.commonCancel, actions: actions)
    }

    // MARK: - Private

    private func viewModelAtIndex(_ index: Int) -> ChatListViewModel? {
        guard 0..<chatListViewModels.count ~= index else { return nil }
        return chatListViewModels[index]
    }

    private func buildChatListAll(_ chatsType: ChatsType) -> ChatListViewModel {
        let emptyVM = LGEmptyViewModel(
            icon: R.Asset.Errors.errListNoChats.image,
            title: R.Strings.chatListAllEmptyTitle,
            body: nil, buttonTitle: R.Strings.chatListSellingEmptyButton,
            action: { [weak self] in
                self?.tabNavigator?.openSell(source: .sellButton, postCategory: nil)
            },
            secondaryButtonTitle: R.Strings.chatListBuyingEmptyButton,
            secondaryAction: { [weak self] in
                self?.tabNavigator?.openHome()
            }, emptyReason: nil, errorCode: nil, errorDescription: nil)
        let chatListViewModel: ChatListViewModel
        chatListViewModel = ChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        chatListViewModel.emptyStatusViewModel = emptyVM
        return chatListViewModel
    }

    private func buildChatListSelling(_ chatsType: ChatsType) -> ChatListViewModel {
        let emptyVM = LGEmptyViewModel(
            icon: R.Asset.Errors.errListNoChats.image,
            title: R.Strings.chatListSellingEmptyTitle,
            body: nil, buttonTitle: R.Strings.chatListSellingEmptyButton,
            action: { [weak self] in
                self?.tabNavigator?.openSell(source: .sellButton, postCategory: nil)
            },
            secondaryButtonTitle: nil, secondaryAction: nil, emptyReason: nil, errorCode: nil, errorDescription: nil)
        let chatListViewModel: ChatListViewModel
        chatListViewModel = ChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        chatListViewModel.emptyStatusViewModel = emptyVM
        return chatListViewModel
    }

    private func buildChatListBuying(_ chatsType: ChatsType) -> ChatListViewModel {
        let emptyVM = LGEmptyViewModel(
            icon: R.Asset.Errors.errListNoChats.image,
            title: R.Strings.chatListBuyingEmptyTitle,
            body: nil, buttonTitle: R.Strings.chatListBuyingEmptyButton,
            action: { [weak self] in
                self?.tabNavigator?.openHome()
            },
            secondaryButtonTitle: nil, secondaryAction: nil, emptyReason: nil, errorCode: nil, errorDescription: nil)
        let chatListViewModel: ChatListViewModel
        chatListViewModel = ChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        chatListViewModel.emptyStatusViewModel = emptyVM
        return chatListViewModel
    }
}


// MARK: - Rx

extension ChatGroupedViewModel {
    fileprivate func setupRxBindings() {
        currentTab.asObservable().map { [weak self] tab -> ChatGroupedListViewModelType? in
            switch tab {
            case .all, .selling, .buying:
                return self?.chatListViewModels[tab.rawValue]
            case .blockedUsers:
                return self?.blockedUsersListViewModel
            }
        }.bind(to: currentPageViewModel).disposed(by: disposeBag)

        // Observe current page view model changes
        currentPageViewModel.asObservable().subscribeNext { [weak self] viewModel in
            guard let strongSelf = self else { return }

            // Observe property update (and stop when current page view model changes, skipping initial value)
            viewModel?.rx_objectCount.asObservable()
                .takeUntil(strongSelf.currentPageViewModel.asObservable().skip(1))
                .map { $0 > 0 }
                .bind(to: strongSelf.editButtonEnabled)
                .disposed(by: strongSelf.disposeBag)

            viewModel?.editing.asObservable()
                .takeUntil(strongSelf.currentPageViewModel.asObservable().skip(1))
                .map { editing in return strongSelf.currentTab.value.editButtonText(editing) }
                .bind(to: strongSelf.editButtonText)
                .disposed(by: strongSelf.disposeBag)

        }.disposed(by: disposeBag)

        chatRepository.chatStatus.map { $0 == .openAuthenticated }.bind(to: editButtonEnabled).disposed(by: disposeBag)

        chatRepository.chatStatus.bind { [weak self] (status) in
            if status == .openNotVerified {
                self?.verificationPending.value = true
            } else if status == .openAuthenticated || status == .closed {
                self?.verificationPending.value = false
            }
        }.disposed(by: disposeBag)
        
        chatRepository.chatStatus.map { $0 == .openNotVerified }.distinctUntilChanged().filter { $0 }.subscribeNext { [weak self] _ in
            self?.tabNavigator?.openVerifyAccounts([.facebook, .google, .email(self?.myUserRepository.myUser?.email)],
                source: .chat(title: R.Strings.chatConnectAccountsTitle,
                    description: R.Strings.chatNotVerifiedAlertMessage),
                completionBlock: nil)
        }.disposed(by: disposeBag)
    }
}
