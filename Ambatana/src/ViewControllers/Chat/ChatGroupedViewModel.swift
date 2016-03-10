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
        case Selling = 0, Buying = 1, BlockedUsers = 2

        var chatsType: ChatsType? {
            switch(self) {
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
            case .Selling, .Buying:
                return LGLocalizedString.chatListDelete
            case .BlockedUsers:
                return LGLocalizedString.chatListUnblock
            }
        }

        static var allValues: [Tab] {
            return [.Selling, .Buying, .BlockedUsers]
        }
    }

    private var chatListViewModels: [ChatListViewModel]
    private(set) var blockedUsersListViewModel: BlockedUsersListViewModel

    private let currentPageViewModel = Variable<ChatGroupedListViewModelType?>(nil)

    weak var delegate: ChatGroupedViewModelDelegate?

    let editButtonText = Variable<String?>(nil)
    let editButtonEnabled = Variable<Bool>(true)
    private let disposeBag: DisposeBag


    // MARK: - Lifecycle

    override init() {
        self.chatListViewModels = []
        self.blockedUsersListViewModel = BlockedUsersListViewModel()
        self.disposeBag = DisposeBag()
        super.init()

        for index in 0..<tabCount {
            guard let tab = Tab(rawValue: index) else { continue }
            switch tab {
            case .Selling:
                guard let chatsType = tab.chatsType else { continue }
                let chatListViewModel = ChatListViewModel(chatsType: chatsType)
                chatListViewModel.emptyIcon = UIImage(named: "err_list_no_chats")
                chatListViewModel.emptyTitle = LGLocalizedString.chatListSellingEmptyTitle
                chatListViewModel.emptyButtonTitle = LGLocalizedString.chatListSellingEmptyButton
                chatListViewModel.emptyAction = { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.viewModelShouldOpenSell(strongSelf)
                }
                chatListViewModels.append(chatListViewModel)
            case .Buying:
                guard let chatsType = tab.chatsType else { continue }
                let chatListViewModel = ChatListViewModel(chatsType: chatsType)
                chatListViewModel.emptyIcon = UIImage(named: "err_list_no_chats")
                chatListViewModel.emptyTitle = LGLocalizedString.chatListBuyingEmptyTitle
                chatListViewModel.emptyButtonTitle = LGLocalizedString.chatListBuyingEmptyButton
                chatListViewModel.emptyAction = { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.viewModelShouldOpenHome(strongSelf)
                }
                chatListViewModels.append(chatListViewModel)
            case .BlockedUsers:
                blockedUsersListViewModel.emptyIcon = UIImage(named: "err_list_no_blocked_users")
                blockedUsersListViewModel.emptyTitle = LGLocalizedString.chatListBlockedEmptyTitle
                blockedUsersListViewModel.emptyBody = LGLocalizedString.chatListBlockedEmptyBody
            }
        }

        setupRxBindings()
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
        guard index >= 0 && index < chatListViewModels.count else { return false }
        let chatListVM = chatListViewModels[index]
        return chatListVM.hasMessagesToRead
    }

    func titleForTabAtIndex(index: Int, selected: Bool) -> NSAttributedString {
        guard let tab = Tab(rawValue: index) else { return NSMutableAttributedString() }

        let color: UIColor = selected ? StyleHelper.primaryColor : UIColor.blackColor()

        var titleAttributes = [String : AnyObject]()
        titleAttributes[NSForegroundColorAttributeName] = color
        titleAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(14)

        let string: NSAttributedString
        switch tab {
        case .Buying:
            string = NSAttributedString(string: LGLocalizedString.chatListBuyingTitle, attributes: titleAttributes)
        case .Selling:
            string = NSAttributedString(string: LGLocalizedString.chatListSellingTitle, attributes: titleAttributes)
        case .BlockedUsers:
            string = NSAttributedString(string: LGLocalizedString.chatListBlockedUsersTitle, attributes: titleAttributes)
        }
        return string
    }

    func chatListViewModelForTabAtIndex(index: Int) -> ChatListViewModel? {
        guard index >= 0 && index < chatListViewModels.count else { return nil }
        return chatListViewModels[index]
    }


    // MARK: > Current page

    func refreshCurrentPage() {
        currentPageViewModel.value?.reloadCurrentPagesWithCompletion(nil)
    }

    func setCurrentPageEditing(editing: Bool) {
        currentPageViewModel.value?.editing.value = editing
    }
}


// MARK: - Rx

extension ChatGroupedViewModel {
    private func setupRxBindings() {
        currentTab.asObservable().map { [weak self] tab -> ChatGroupedListViewModelType? in
            switch tab {
            case .Selling, .Buying:
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
    }
}
