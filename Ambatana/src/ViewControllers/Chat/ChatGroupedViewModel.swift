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
    func viewModelShouldOpenHome(viewModel: ChatGroupedViewModel)
    func viewModelShouldOpenSell(viewModel: ChatGroupedViewModel)
}

class ChatGroupedViewModel: BaseViewModel {

    enum Tab: Int {
        case All = 0, Selling = 1, Buying = 2, BlockedUsers = 3

        var chatsType: ChatsType? {
            switch(self) {
            case .All:
                return .All
            case .Selling:
                return .Selling
            case .Buying:
                return .Buying
            case .BlockedUsers:
                return nil
            }
        }

        func editButtonText(editing: Bool) -> String {
            guard !editing else { return LGLocalizedString.commonCancel }

            switch(self) {
            case .All, .Selling, .Buying:
                return LGLocalizedString.chatListDelete
            case .BlockedUsers:
                return LGLocalizedString.chatListUnblock
            }
        }

        static var allValues: [Tab] {
            return [.All, .Selling, .Buying, .BlockedUsers]
        }
    }

    private var chatListViewModels: [ChatListViewModel]
    private(set) var blockedUsersListViewModel: BlockedUsersListViewModel
    private let currentPageViewModel = Variable<ChatGroupedListViewModelType?>(nil)

    private let sessionManager: SessionManager
    private let chatHeadManager: ChatHeadManager
    private let myUserRepository: MyUserRepository
    private let chatRepository: ChatRepository
    private let featureFlags: FeatureFlags

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

    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    override convenience init() {
        self.init(myUserRepository: Core.myUserRepository, chatRepository: Core.chatRepository,
                  sessionManager: Core.sessionManager, chatHeadManager: ChatHeadManager.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(myUserRepository: MyUserRepository, chatRepository: ChatRepository,
         sessionManager: SessionManager, chatHeadManager: ChatHeadManager, featureFlags: FeatureFlags) {
        self.sessionManager = sessionManager
        self.chatHeadManager = chatHeadManager
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
            case .All:
                guard let chatsType = tab.chatsType else { continue }
                chatListViewModels.append(buildChatListAll(chatsType))
            case.Selling:
                guard let chatsType = tab.chatsType else { continue }
                chatListViewModels.append(buildChatListSelling(chatsType))
            case .Buying:
                guard let chatsType = tab.chatsType else { continue }
                chatListViewModels.append(buildChatListBuying(chatsType))
            case .BlockedUsers:
                blockedUsersListViewModel.emptyStatusViewModel = LGEmptyViewModel(
                    icon: UIImage(named: "err_list_no_blocked_users"),
                    title: LGLocalizedString.chatListBlockedEmptyTitle,
                    body: LGLocalizedString.chatListBlockedEmptyBody, buttonTitle: nil, action: nil,
                    secondaryButtonTitle: nil, secondaryAction: nil)
            }
        }
        setupRxBindings()
        setupVerificationPendingEmptyVM()
    }

    override func didBecomeActive(firstTime: Bool) {
        super.didBecomeActive(firstTime)
        chatHeadManager.updateChatHeadDatas()
    }

    func setupVerificationPendingEmptyVM() {
        verificationPendingEmptyVM = LGEmptyViewModel(icon: UIImage(named: "ic_build_trust_big"),
                                          title: LGLocalizedString.chatNotVerifiedStateTitle,
                                          body: LGLocalizedString.chatNotVerifiedStateMessage,
                                          buttonTitle: LGLocalizedString.chatNotVerifiedStateCheckButton,
                                          action: { [weak self] in self?.tryToReconnectChat() },
                                          secondaryButtonTitle: nil, secondaryAction: nil)
    }

    // MARK: - Public methods
    // MARK: > Tab

    var tabCount: Int {
        return Tab.allValues.count
    }

    var chatListsCount: Int {
        return chatListViewModels.count
    }

    let currentTab = Variable<Tab>(.Buying)

    func showInfoBadgeAtIndex(index: Int) -> Bool {
        guard let chatListVM = viewModelAtIndex(index) else { return false }
        return chatListVM.hasMessagesToRead
    }

    func titleForTabAtIndex(index: Int, selected: Bool) -> NSAttributedString {
        guard let tab = Tab(rawValue: index) else { return NSMutableAttributedString() }

        let color: UIColor = selected ? UIColor.primaryColor : UIColor.blackColor()

        var titleAttributes = [String : AnyObject]()
        titleAttributes[NSForegroundColorAttributeName] = color
        titleAttributes[NSFontAttributeName] = selected ? UIFont.activeTabFont : UIFont.inactiveTabFont

        let string: NSAttributedString
        switch tab {
        case .All:
            string = NSAttributedString(string: LGLocalizedString.chatListAllTitle, attributes: titleAttributes)
        case .Buying:
            string = NSAttributedString(string: LGLocalizedString.chatListBuyingTitle, attributes: titleAttributes)
        case .Selling:
            string = NSAttributedString(string: LGLocalizedString.chatListSellingTitle, attributes: titleAttributes)
        case .BlockedUsers:
            string = NSAttributedString(string: LGLocalizedString.chatListBlockedUsersTitle, attributes: titleAttributes)
        }
        return string
    }
    
    func accessibilityIdentifierForTabButtonAtIndex(index: Int) -> AccessibilityId? {
        guard let tab = Tab(rawValue: index) else { return nil }
        switch tab {
        case .All: return .ChatListViewTabAll
        case .Buying: return .ChatListViewTabBuying
        case .Selling: return .ChatListViewTabSelling
        case .BlockedUsers: return .ChatListViewTabBlockedUsers
        }
    }
    
    func accessibilityIdentifierForTableViewAtIndex(index: Int) -> AccessibilityId? {
        guard let tab = Tab(rawValue: index) else { return nil }
        switch tab {
        case .All: return .ChatListViewTabAllTableView
        case .Buying: return .ChatListViewTabBuyingTableView
        case .Selling: return .ChatListViewTabSellingTableView
        case .BlockedUsers: return .ChatListViewTabBlockedUsersTableView
        }
    }
    
    func blockedUserPressed(user: User) {
        let data = UserDetailData.UserAPI(user: user, source: .Chat)
        tabNavigator?.openUser(data)
    }

    func oldChatListViewModelForTabAtIndex(index: Int) -> OldChatListViewModel? {
        guard let chatListVM = viewModelAtIndex(index) else { return nil }
        return chatListVM as? OldChatListViewModel
    }

    func wsChatListViewModelForTabAtIndex(index: Int) -> WSChatListViewModel? {
        guard let chatListVM = viewModelAtIndex(index) else { return nil }
        return chatListVM as? WSChatListViewModel
    }


    // MARK: > Current page

    func refreshCurrentPage() {
        currentPageViewModel.value?.reloadCurrentPagesWithCompletion(nil)
    }

    func setCurrentPageEditing(editing: Bool) {
        currentPageViewModel.value?.editing.value = editing
    }


    // MARK: - Private

    private func viewModelAtIndex(index: Int) -> ChatListViewModel? {
        guard 0..<chatListViewModels.count ~= index else { return nil }
        return chatListViewModels[index]
    }

    private func buildChatListAll(chatsType: ChatsType) -> ChatListViewModel {
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
            }
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

    private func buildChatListSelling(chatsType: ChatsType) -> ChatListViewModel {
        let emptyVM = LGEmptyViewModel(
            icon: UIImage(named: "err_list_no_chats"),
            title: LGLocalizedString.chatListSellingEmptyTitle,
            body: nil, buttonTitle: LGLocalizedString.chatListSellingEmptyButton,
            action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelShouldOpenSell(strongSelf)
            },
            secondaryButtonTitle: nil, secondaryAction: nil
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

    private func buildChatListBuying(chatsType: ChatsType) -> ChatListViewModel {
        let emptyVM = LGEmptyViewModel(
            icon: UIImage(named: "err_list_no_chats"),
            title: LGLocalizedString.chatListBuyingEmptyTitle,
            body: nil, buttonTitle: LGLocalizedString.chatListBuyingEmptyButton,
            action: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.delegate?.viewModelShouldOpenHome(strongSelf)
            },
            secondaryButtonTitle: nil, secondaryAction: nil
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
    private func setupRxBindings() {
        currentTab.asObservable().map { [weak self] tab -> ChatGroupedListViewModelType? in
            switch tab {
            case .All, .Selling, .Buying:
                return self?.chatListViewModels[tab.rawValue]
            case .BlockedUsers:
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

        chatRepository.wsChatStatus.asObservable().map { wsChatStatus in
            switch wsChatStatus {
            case .Closed, .Closing, .Opening, .OpenAuthenticated, .OpenNotAuthenticated:
                return false
            case .OpenNotVerified:
                return true
            }
        }.bindTo(verificationPending).addDisposableTo(disposeBag)

        verificationPending.asObservable().filter { !$0 }.bindTo(editButtonEnabled).addDisposableTo(disposeBag)
    }

    func tryToReconnectChat() {
        sessionManager.connectChat { [weak self] result in
            if let _ = result.value {
                self?.verificationPending.value = false
            } else {
                self?.tabNavigator?.openVerifyAccounts([.Facebook, .Google, .Email(self?.myUserRepository.myUser?.email)],
                    source: .Chat(title: LGLocalizedString.chatConnectAccountsTitle,
                        description: LGLocalizedString.chatNotVerifiedAlertMessage),
                    completionBlock: nil)
            }
        }
    }
}
