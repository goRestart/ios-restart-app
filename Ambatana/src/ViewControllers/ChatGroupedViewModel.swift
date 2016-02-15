//
//  ChatGroupedViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 27/01/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ChatGroupedViewModelDelegate: class {
    func viewModelShouldUpdateNavigationBarButtons(viewModel: ChatGroupedViewModel)
    func viewModelShouldOpenHome(viewModel: ChatGroupedViewModel)
    func viewModelShouldOpenSell(viewModel: ChatGroupedViewModel)
}

class ChatGroupedViewModel: BaseViewModel {

    enum Tab: Int {
        case Selling = 0, Buying = 1, Archived = 2, BlockedUsers = 3

        var chatsType: ChatsType? {
            switch(self) {
            case .Selling:
                return .Selling
            case .Buying:
                return .Buying
            case .Archived:
                return .Archived
            case .BlockedUsers:
                return nil
            }
        }

        static var allValues: [Tab] {
            return [.Selling, .Buying, .Archived, .BlockedUsers]
        }
    }

    private var chatListViewModels: [ChatListViewModel]
    private(set) var blockedUsersListViewModel: BlockedUsersListViewModel

    private var currentPageViewModel: ChatGroupedListViewModelType {
        switch currentTab {
        case .Selling, .Buying, .Archived:
            return chatListViewModels[currentTab.rawValue]
        case .BlockedUsers:
            return blockedUsersListViewModel
        }
    }


    weak var delegate: ChatGroupedViewModelDelegate?


    // MARK: - Lifecycle

    override init() {
        chatListViewModels = []
        blockedUsersListViewModel = BlockedUsersListViewModel()
        super.init()

        for index in 0..<tabCount {
            guard let tab = Tab(rawValue: index) else { continue }
            guard let chatsType = tab.chatsType else { continue }
            switch tab {
            case .Selling:
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
                let chatListViewModel = ChatListViewModel(chatsType: chatsType)
                chatListViewModel.emptyIcon = UIImage(named: "err_list_no_chats")
                chatListViewModel.emptyTitle = LGLocalizedString.chatListBuyingEmptyTitle
                chatListViewModel.emptyButtonTitle = LGLocalizedString.chatListBuyingEmptyButton
                chatListViewModel.emptyAction = { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.delegate?.viewModelShouldOpenHome(strongSelf)
                }
                chatListViewModels.append(chatListViewModel)
            case .Archived:
                let chatListViewModel = ChatListViewModel(chatsType: chatsType)
                chatListViewModel.emptyIcon = UIImage(named: "err_list_no_archived_chats")
                chatListViewModel.emptyTitle = LGLocalizedString.chatListArchiveEmptyTitle
                chatListViewModel.emptyBody = LGLocalizedString.chatListArchiveEmptyBody
                chatListViewModels.append(chatListViewModel)
            case .BlockedUsers:
                blockedUsersListViewModel.emptyIcon = UIImage(named: "err_list_no_chats")
                blockedUsersListViewModel.emptyTitle = "_ No blocked users yet"
                blockedUsersListViewModel.emptyBody = "_ No blocked users yet"
            }
        }
    }


    // MARK: - Public methods
    // MARK: > Tab

    var tabCount: Int {
        return Tab.allValues.count
    }

    var chatListsCount: Int {
        return chatListViewModels.count
    }

    var currentTab: Tab = .Buying {
        didSet {
            guard oldValue != currentTab else { return }
            delegate?.viewModelShouldUpdateNavigationBarButtons(self)
        }
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
        case .Archived:
            string = NSAttributedString(string: LGLocalizedString.chatListArchivedTitle, attributes: titleAttributes)
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
        currentPageViewModel.reloadCurrentPagesWithCompletion(nil)
    }

    func setCurrentPageEditing(editing: Bool, animated: Bool) {
        currentPageViewModel.setEditing(editing, animated: animated)
    }

    var editButtonVisible: Bool {
        switch currentTab {
        case .Selling, .Buying, .BlockedUsers:
            return currentPageViewModel.objectCount > 0
        case .Archived:
            return false
        }
    }
}
