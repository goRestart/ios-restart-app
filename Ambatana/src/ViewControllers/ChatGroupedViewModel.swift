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
}

class ChatGroupedViewModel: BaseViewModel {

    enum Tab: Int {
        case Selling = 0, Buying = 1, Archived = 2

        var chatsType: ChatsType {
            switch(self) {
            case .Selling:
                return .Selling
            case .Buying:
                return .Buying
            case .Archived:
                return .Archived
            }
        }
    }

    private var chatListViewModels: [ChatListViewModel]
    private var currentPageViewModel: ChatListViewModel {
        return chatListViewModels[currentTab.rawValue]
    }

    weak var delegate: ChatGroupedViewModelDelegate?


    // MARK: - Lifecycle

    override init() {
        chatListViewModels = []
        super.init()

        for index in 0..<tabCount {
            guard let tab = Tab(rawValue: index) else { continue }
            let chatListViewModel = ChatListViewModel(tab: tab)
            chatListViewModels.append(chatListViewModel)
        }
    }


    // MARK: - Public methods
    // MARK: > Tab

    var tabCount: Int {
        return 3
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
        }
        return string
    }

    var currentTab: Tab = .Buying {
        didSet {
            guard oldValue != currentTab else { return }
            delegate?.viewModelShouldUpdateNavigationBarButtons(self)
        }
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
        case .Selling, .Buying:
            return currentPageViewModel.objectCount > 0
        case .Archived:
            return false
        }
    }
}
