import LGCoreKit
import LGComponents

enum ConversationCellStatus {
    case available
    case forbidden
    case listingSold
    case listingGivenAway
    case listingDeleted
    case userPendingDelete
    case userDeleted
    case userBlocked
    case blockedByUser
    
    var icon: UIImage? {
        switch self {
        case .forbidden:
            return R.Asset.IconsButtons.icPendingModeration.image
        case .listingSold, .listingGivenAway:
            return R.Asset.BackgroundsAndImages.icDollarSold.image
        case .userPendingDelete, .userDeleted:
            return R.Asset.BackgroundsAndImages.icAlertYellowWhiteInside.image
        case .userBlocked, .blockedByUser:
            return R.Asset.BackgroundsAndImages.icBlocked.image
        case .available, .listingDeleted:
            return nil
        }
    }
    
    var message: String? {
        switch self {
        case .forbidden:
            return R.Strings.accountPendingModeration
        case .listingSold:
            return R.Strings.commonProductSold
        case .listingGivenAway:
            return R.Strings.commonProductGivenAway
        case .userPendingDelete:
            return R.Strings.chatListAccountDeleted
        case .userDeleted:
            return R.Strings.chatListAccountDeleted
        case .userBlocked:
            return R.Strings.chatListBlockedUserLabel
        case .blockedByUser:
            return R.Strings.chatBlockedByOtherLabel
        case .available, .listingDeleted:
            return nil
        }
    }

    var listingStatusIsAvailable: Bool {
        switch self {
        case .available, .forbidden, .userPendingDelete, .userDeleted, .userBlocked, .blockedByUser:
            return true
        case .listingSold, .listingGivenAway, .listingDeleted:
            return false
        }
    }
}

extension ChatConversation {
    var conversationCellStatus: ConversationCellStatus {
        guard let listing = listing, let interlocutor = interlocutor else { return .userDeleted }
        if interlocutor.isBanned { return .forbidden }
        
        switch interlocutor.status {
        case .scammer:
            return .forbidden
        case .pendingDelete:
            return .userPendingDelete
        case .deleted:
            return .userDeleted
        case .active, .inactive, .notFound:
            break // In this case we rely on the product status
        }
        
        if interlocutor.isMuted {
            return .userBlocked
        }
        if interlocutor.hasMutedYou {
            return .blockedByUser
        }
        
        switch listing.status {
        case .deleted, .discarded:
            return .listingDeleted
        case .sold, .soldOld:
            return listing.price == .free ? .listingGivenAway : .listingSold
        case .approved, .pending:
            return .available
        }
    }
}
