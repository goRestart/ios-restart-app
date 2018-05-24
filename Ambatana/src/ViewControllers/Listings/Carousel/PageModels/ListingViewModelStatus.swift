import LGCoreKit
import LGComponents

enum ListingViewModelStatus {

    // When Mine:
    case pending
    case available
    case availableFree
    case sold
    case soldFree
    case pendingAndFeatured


    // Other Selling:
    case otherAvailable
    case otherAvailableFree
    case otherSold
    case otherSoldFree

    // Common:
    case notAvailable

    init(listing: Listing, isMine: Bool, featureFlags: FeatureFlaggeable) {
        switch listing.status {
        case .pending:
            if isMine {
                let featured = listing.featured ?? false
                self = featured ? .pendingAndFeatured : .pending
            } else {
                self = .notAvailable
            }
        case .discarded, .deleted:
            self = .notAvailable
        case .approved:
            if featureFlags.freePostingModeAllowed && listing.price.isFree {
                self = isMine ? .availableFree : .otherAvailableFree
            } else {
                self = isMine ? .available : .otherAvailable
            }
        case .sold, .soldOld:
            if featureFlags.freePostingModeAllowed && listing.price.isFree {
                self = isMine ? .soldFree : .otherSoldFree
            } else {
                self = isMine ? .sold : .otherSold
            }
        }
    }

    var isEditable: Bool {
        switch self {
        case .pending, .available, .availableFree, .pendingAndFeatured:
            return true
        case .notAvailable, .sold, .otherSold, .otherAvailable, .otherSoldFree, .soldFree, .otherAvailableFree:
            return false
        }
    }

    var isFree: Bool {
        switch self {
        case .availableFree, .otherAvailableFree, .otherSoldFree, .soldFree :
            return true
        case .pending, .available, .notAvailable, .sold,
             .otherSold, .otherAvailable, .pendingAndFeatured:
            return false
        }
    }
    
    var isSold: Bool {
        switch self {
        case .sold, .soldFree:
            return true
        case .pending, .available, .availableFree, .otherAvailable, .otherAvailableFree, .otherSold, .otherSoldFree,
             .notAvailable, .pendingAndFeatured:
            return false
        }
    }

    var isAvailable: Bool {
        switch self {
        case .availableFree, .otherAvailableFree, .available, .otherAvailable:
            return true
        case .pending, .notAvailable, .sold, .otherSold,
             .otherSoldFree, .soldFree, .pendingAndFeatured:
            return false
        }
    }

    var directChatsAvailable: Bool {
        switch self {
        case .pending, .available, .soldFree,
             .otherSoldFree, .availableFree, .notAvailable, .sold, .otherSold, .pendingAndFeatured:
            return false
        case  .otherAvailable,  .otherAvailableFree:
            return true
        }
    }

    var shouldShowStatus: Bool {
        switch self {
        case .sold, .otherSold, .soldFree, .otherSoldFree:
            return true
        case .pending, .available, .otherAvailable, .availableFree, .otherAvailableFree,
             .notAvailable, .pendingAndFeatured:
            return false
        }
    }

    var string: String? {
        switch self {
        case .sold, .otherSold:
            return R.Strings.productListItemSoldStatusLabel
        case .soldFree, .otherSoldFree:
            return R.Strings.productListItemGivenAwayStatusLabel
        case .pending, .available, .otherAvailable, .availableFree, .otherAvailableFree,
             .notAvailable, .pendingAndFeatured:
            return nil
        }
    }

    var bgColor: UIColor {
        switch self {
        case .sold, .otherSold, .soldFree, .otherSoldFree:
            return UIColor.white
        case .pending, .available, .otherAvailable,
             .notAvailable, .availableFree, .otherAvailableFree, .pendingAndFeatured:
            return .clear
        }
    }

    var labelColor: UIColor {
        switch self {
        case .sold, .otherSold:
            return UIColor.soldColor
        case .soldFree, .otherSoldFree:
            return UIColor.soldFreeColor
        case .pending, .available, .otherAvailable,
             .notAvailable, .availableFree, .otherAvailableFree, .pendingAndFeatured:
            return .clear
        }
    }

    var shouldRefreshBumpBanner: Bool {
        switch self {
        case .available, .availableFree, .pendingAndFeatured, .pending:
            return true
        case .otherAvailable, .otherAvailableFree, .notAvailable, .sold, .otherSold, .otherSoldFree, .soldFree:
            return false
        }
    }
}
