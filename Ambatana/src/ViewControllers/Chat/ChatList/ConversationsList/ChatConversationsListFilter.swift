//
//  ChatConversationsListFilter.swift
//  LetGo
//
//  Created by Nestor on 09/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

enum ChatConversationsListFilter {
    case all
    case selling
    case buying
    
    var localizedString: String {
        switch self {
        case .all:
            return LGLocalizedString.chatConversationsListFilterAll
        case .selling:
            return LGLocalizedString.chatConversationsListFilterSelling
        case .buying:
            return LGLocalizedString.chatConversationsListFilterBuying
        }
    }
    
    var filterIcon: UIImage {
        switch self {
        case .all:
            return #imageLiteral(resourceName: "ic_chat_filter")
        case .selling, .buying:
            return #imageLiteral(resourceName: "ic_chat_filter_active")
        }
    }
    
    var emptyViewModelTitleLocalizedString: String {
        switch self {
        case .all:
            return LGLocalizedString.chatListAllEmptyTitle
        case .selling:
            return LGLocalizedString.chatListSellingEmptyTitle
        case .buying:
            return LGLocalizedString.chatListBuyingEmptyTitle
        }
    }
    
    var emptyViewModelPrimaryButtonTitleLocalizedString: String {
        switch self {
        case .all, .selling:
            return LGLocalizedString.chatListSellingEmptyButton
        case .buying:
            return LGLocalizedString.chatListBuyingEmptyButton
        }
    }
    
    var emptyViewModelSecundaryButtonTitleLocalizedString: String? {
        switch self {
        case .all:
            return LGLocalizedString.chatListBuyingEmptyButton
        case .selling, .buying:
            return nil
        }
    }
}
