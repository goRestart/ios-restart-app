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

    weak var delegate: ChatGroupedViewModelDelegate?

    var tabCount: Int {
        return 3
    }

    func chatListViewModelForTabAtIndex(index: Int) -> ChatListViewModel? {
        guard let tab = Tab(rawValue: index) else { return nil }
        return ChatListViewModel(chatsType: tab.chatsType)
    }

    func titleForTabAtIndex(index: Int, selected: Bool) -> NSAttributedString {
        let color: UIColor = selected ? StyleHelper.primaryColor : UIColor.blackColor()

        var titleAttributes = [String : AnyObject]()
        titleAttributes[NSForegroundColorAttributeName] = color

        let string = NSMutableAttributedString()
        switch index % 3 {
        case 0:
            string.appendAttributedString(NSAttributedString(string: LGLocalizedString.chatListBuyingTitle,
                attributes: titleAttributes))
        case 1:
            string.appendAttributedString(NSAttributedString(string: LGLocalizedString.chatListSellingTitle,
                attributes: titleAttributes))
        case 2:
            string.appendAttributedString(NSAttributedString(string: LGLocalizedString.chatListArchivedTitle,
                attributes: titleAttributes))
        default:
            break
        }
        return string
    }

    var hasEditButton: Bool {
        switch(currentTab) {
        case .Selling, .Buying:
            return true
        case .Archived:
            return false
        }
    }

    func startEdit() {
        switch(currentTab) {
        case .Selling, .Buying:
            break
        case .Archived:
            break
        }
    }

    func finishEdit() {
        switch(currentTab) {
        case .Selling, .Buying:
            break
        case .Archived:
            break
        }
    }

    var currentTab: Tab = .Buying {
        didSet {
            delegate?.viewModelShouldUpdateNavigationBarButtons(self)
        }
    }
}
