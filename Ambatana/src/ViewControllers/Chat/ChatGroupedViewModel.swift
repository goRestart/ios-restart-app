//
//  ChatGroupedViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit
import RxSwift

protocol ChatGroupedViewModelDelegate: class {
    func viewModelShouldOpenHome(_ viewModel: ChatGroupedViewModel)
    func viewModelShouldOpenSell(_ viewModel: ChatGroupedViewModel)
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
            guard !editing else { return LGLocalizedString.commonCancel }

            switch(self) {
            case .all, .selling, .buying:
                return LGLocalizedString.chatListDelete
            case .blockedUsers:
                return LGLocalizedString.chatListUnblock
            }
        }

        static var allValues: [Tab] {
            return [.all, .selling, .buying, .blockedUsers]
        }
    }

    fileprivate var chatListViewModels: [ChatListViewModel]
    fileprivate(set) var blockedUsersListViewModel: BlockedUsersListViewModel
    fileprivate let currentPageViewModel = Variable<ChatGroupedListViewModelType?>(nil)

    fileprivate let sessionManager: SessionManager
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let chatRepository: ChatRepository
    fileprivate let featureFlags: FeatureFlaggeable

    weak var delegate: ChatGroupedViewModelDelegate?
    weak var tabNavigator: TabNavigator? {
        didSet {
            chatListViewModels.forEach { $0.tabNavigator = tabNavigator }
            blockedUsersListViewModel.tabNavigator = tabNavigator
        }
    }
    var verificationPendingEmptyVM: LGEmptyViewModel?

    let editButtonText = Variable<String?>(nil)
    let editButtonEnabled = Variable<Bool>(true)

    let verificationPending = Variable<Bool>(false)

    fileprivate let disposeBag: DisposeBag


    // MARK: - Lifecycle

    override convenience init() {
        self.init(myUserRepository: Core.myUserRepository, chatRepository: Core.chatRepository,
                  sessionManager: Core.sessionManager, featureFlags: FeatureFlags.sharedInstance)
    }

    init(myUserRepository: MyUserRepository, chatRepository: ChatRepository, sessionManager: SessionManager,
         featureFlags: FeatureFlaggeable) {
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.chatRepository = chatRepository
        self.featureFlags = featureFlags
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
                    icon: UIImage(named: "err_list_no_blocked_users"),
                    title: LGLocalizedString.chatListBlockedEmptyTitle,
                    body: LGLocalizedString.chatListBlockedEmptyBody, buttonTitle: nil, action: nil,
                    secondaryButtonTitle: nil, secondaryAction: nil, errorReason: .emptyResults)
            }
        }
        setupRxBindings()
        setupVerificationPendingEmptyVM()
    }

    func setupVerificationPendingEmptyVM() {
        verificationPendingEmptyVM = LGEmptyViewModel(icon: UIImage(named: "ic_build_trust_big"),
                                          title: LGLocalizedString.chatNotVerifiedStateTitle,
                                          body: LGLocalizedString.chatNotVerifiedStateMessage,
                                          buttonTitle: LGLocalizedString.chatNotVerifiedStateCheckButton,
                                          action: { [weak self] in self?.tryToReconnectChat() },
                                          secondaryButtonTitle: nil, secondaryAction: nil, errorReason: .verification)
    }

    // MARK: - Public methods
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

        var titleAttributes = [String : Any]()
        titleAttributes[NSForegroundColorAttributeName] = color
        titleAttributes[NSFontAttributeName] = selected ? UIFont.activeTabFont : UIFont.inactiveTabFont

        let string: NSAttributedString
        switch tab {
        case .all:
            string = NSAttributedString(string: LGLocalizedString.chatListAllTitle, attributes: titleAttributes)
        case .buying:
            string = NSAttributedString(string: LGLocalizedString.chatListBuyingTitle, attributes: titleAttributes)
        case .selling:
            string = NSAttributedString(string: LGLocalizedString.chatListSellingTitle, attributes: titleAttributes)
        case .blockedUsers:
            string = NSAttributedString(string: LGLocalizedString.chatListBlockedUsersTitle, attributes: titleAttributes)
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

    func oldChatListViewModelForTabAtIndex(_ index: Int) -> OldChatListViewModel? {
        guard let chatListVM = viewModelAtIndex(index) else { return nil }
        return chatListVM as? OldChatListViewModel
    }

    func wsChatListViewModelForTabAtIndex(_ index: Int) -> WSChatListViewModel? {
        guard let chatListVM = viewModelAtIndex(index) else { return nil }
        return chatListVM as? WSChatListViewModel
    }


    // MARK: > Current page

    func refreshCurrentPage() {
        currentPageViewModel.value?.reloadCurrentPagesWithCompletion(nil)
    }

    func setCurrentPageEditing(_ editing: Bool) {
        currentPageViewModel.value?.editing.value = editing
    }


    // MARK: - Private

    private func viewModelAtIndex(_ index: Int) -> ChatListViewModel? {
        guard 0..<chatListViewModels.count ~= index else { return nil }
        return chatListViewModels[index]
    }

    private func buildChatListAll(_ chatsType: ChatsType) -> ChatListViewModel {
        let emptyVM = LGEmptyViewModel(
            icon: UIImage(named: "err_list_no_chats"),
            title: LGLocalizedString.chatListAllEmptyTitle,
            body: nil, buttonTitle: LGLocalizedString.chatListSellingEmptyButton,
            action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelShouldOpenSell(strongSelf)
            },
            secondaryButtonTitle: LGLocalizedString.chatListBuyingEmptyButton,
            secondaryAction: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelShouldOpenHome(strongSelf)
            }, errorReason: .emptyResults
        )
        let chatListViewModel: ChatListViewModel
        if featureFlags.websocketChat {
            chatListViewModel = WSChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        } else {
            chatListViewModel = OldChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        }
        chatListViewModel.emptyStatusViewModel = emptyVM
        return chatListViewModel
    }

    private func buildChatListSelling(_ chatsType: ChatsType) -> ChatListViewModel {
        let emptyVM = LGEmptyViewModel(
            icon: UIImage(named: "err_list_no_chats"),
            title: LGLocalizedString.chatListSellingEmptyTitle,
            body: nil, buttonTitle: LGLocalizedString.chatListSellingEmptyButton,
            action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelShouldOpenSell(strongSelf)
            },
            secondaryButtonTitle: nil, secondaryAction: nil, errorReason: .emptyResults
        )
        let chatListViewModel: ChatListViewModel
        if featureFlags.websocketChat {
            chatListViewModel = WSChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        } else {
            chatListViewModel = OldChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        }
        chatListViewModel.emptyStatusViewModel = emptyVM
        return chatListViewModel
    }

    private func buildChatListBuying(_ chatsType: ChatsType) -> ChatListViewModel {
        let emptyVM = LGEmptyViewModel(
            icon: UIImage(named: "err_list_no_chats"),
            title: LGLocalizedString.chatListBuyingEmptyTitle,
            body: nil, buttonTitle: LGLocalizedString.chatListBuyingEmptyButton,
            action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelShouldOpenHome(strongSelf)
            },
            secondaryButtonTitle: nil, secondaryAction: nil, errorReason: .emptyResults
        )
        let chatListViewModel: ChatListViewModel
        if featureFlags.websocketChat {
            chatListViewModel = WSChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        } else {
            chatListViewModel = OldChatListViewModel(chatsType: chatsType, tabNavigator: tabNavigator)
        }
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
        }.bindTo(currentPageViewModel).addDisposableTo(disposeBag)

        // Observe current page view model changes
        currentPageViewModel.asObservable().subscribeNext { [weak self] viewModel in
            guard let strongSelf = self else { return }

            // Observe property update (and stop when current page view model changes, skipping initial value)
            viewModel?.rx_objectCount.asObservable()
                .takeUntil(strongSelf.currentPageViewModel.asObservable().skip(1))
                .map { $0 > 0 }
                .bindTo(strongSelf.editButtonEnabled)
                .addDisposableTo(strongSelf.disposeBag)

            viewModel?.editing.asObservable()
                .takeUntil(strongSelf.currentPageViewModel.asObservable().skip(1))
                .map { editing in return strongSelf.currentTab.value.editButtonText(editing) }
                .bindTo(strongSelf.editButtonText)
                .addDisposableTo(strongSelf.disposeBag)

        }.addDisposableTo(disposeBag)

        chatRepository.chatStatus.map { $0.verifiedPending }.bindTo(verificationPending).addDisposableTo(disposeBag)
        chatRepository.chatStatus.map { $0.available }.bindTo(editButtonEnabled).addDisposableTo(disposeBag)

        // When verification pending changes from false to true then display verify accounts
        verificationPending.asObservable().filter { $0 }.distinctUntilChanged().subscribeNext { [weak self] _ in
            self?.tabNavigator?.openVerifyAccounts([.facebook, .google, .email(self?.myUserRepository.myUser?.email)],
                source: .chat(title: LGLocalizedString.chatConnectAccountsTitle,
                    description: LGLocalizedString.chatNotVerifiedAlertMessage),
                completionBlock: nil)
        }.addDisposableTo(disposeBag)
    }

    func tryToReconnectChat() {
        sessionManager.connectChat()
    }
}
