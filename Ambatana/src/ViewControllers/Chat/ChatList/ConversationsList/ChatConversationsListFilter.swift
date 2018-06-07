import LGComponents
import LGCoreKit

enum ChatConversationsListFilter {
    case all
    case selling
    case buying
    
    func collectionVariable(from chatRepository: ChatRepository) -> CollectionVariable<ChatConversation> {
        switch self {
        case .all:
            return chatRepository.allConversations
        case .selling:
            return chatRepository.sellingConversations
        case .buying:
            return chatRepository.buyingConversations
        }
    }
    
    var webSocketConversationFilter: WebSocketConversationFilter {
        switch self {
        case .all:
            return .all
        case .selling:
            return .asSeller
        case .buying:
            return .asBuyer
        }
    }
    
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
            return R.Asset.Chat.icFilter.image
        case .selling, .buying:
            return R.Asset.Chat.icFilterActive.image
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
