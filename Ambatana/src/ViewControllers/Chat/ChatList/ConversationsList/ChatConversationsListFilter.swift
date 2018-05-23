import LGComponents

enum ChatConversationsListFilter {
    case all
    case selling
    case buying
    
    var localizedString: String {
        switch self {
        case .all:
            return R.Strings.chatConversationsListFilterAll
        case .selling:
            return R.Strings.chatConversationsListFilterSelling
        case .buying:
            return R.Strings.chatConversationsListFilterBuying
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
            return R.Strings.chatListAllEmptyTitle
        case .selling:
            return R.Strings.chatListSellingEmptyTitle
        case .buying:
            return R.Strings.chatListBuyingEmptyTitle
        }
    }
    
    var emptyViewModelPrimaryButtonTitleLocalizedString: String {
        switch self {
        case .all, .selling:
            return R.Strings.chatListSellingEmptyButton
        case .buying:
            return R.Strings.chatListBuyingEmptyButton
        }
    }
    
    var emptyViewModelSecundaryButtonTitleLocalizedString: String? {
        switch self {
        case .all:
            return R.Strings.chatListBuyingEmptyButton
        case .selling, .buying:
            return nil
        }
    }
}
