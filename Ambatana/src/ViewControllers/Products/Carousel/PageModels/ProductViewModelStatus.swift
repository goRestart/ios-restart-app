//
//  ProductViewModelStatus.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

enum ProductViewModelStatus {

    // When Mine:
    case pending
    case available
    case availableFree
    case sold
    case soldFree

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
            self = isMine ? .pending : .notAvailable
        case .discarded, .deleted:
            self = .notAvailable
        case .approved:
            if featureFlags.freePostingModeAllowed && listing.price.free {
                self = isMine ? .availableFree : .otherAvailableFree
            } else {
                self = isMine ? .available : .otherAvailable
            }
        case .sold, .soldOld:
            if featureFlags.freePostingModeAllowed && listing.price.free {
                self = isMine ? .soldFree : .otherSoldFree
            } else {
                self = isMine ? .sold : .otherSold
            }
        }
    }

    var isEditable: Bool {
        switch self {
        case .pending, .available, .availableFree:
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
             .otherSold, .otherAvailable:
            return false
        }
    }

    var isAvailable: Bool {
        switch self {
        case .availableFree, .otherAvailableFree, .available, .otherAvailable:
            return true
        case .pending, .notAvailable, .sold, .otherSold,
             .otherSoldFree, .soldFree:
            return false
        }
    }

    var directChatsAvailable: Bool {
        switch self {
        case .pending, .available, .soldFree,
             .otherSoldFree, .availableFree, .notAvailable, .sold, .otherSold:
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
             .notAvailable:
            return false
        }
    }

    var string: String? {
        switch self {
        case .sold, .otherSold:
            return LGLocalizedString.productListItemSoldStatusLabel
        case .soldFree, .otherSoldFree:
            return LGLocalizedString.productListItemGivenAwayStatusLabel
        case .pending, .available, .otherAvailable, .availableFree, .otherAvailableFree,
             .notAvailable:
            return nil
        }
    }

    var bgColor: UIColor {
        switch self {
        case .sold, .otherSold, .soldFree, .otherSoldFree:
            return UIColor.white
        case .pending, .available, .otherAvailable,
             .notAvailable, .availableFree, .otherAvailableFree:
            return UIColor.clear
        }
    }

    var labelColor: UIColor {
        switch self {
        case .sold, .otherSold:
            return UIColor.soldColor
        case .soldFree, .otherSoldFree:
            return UIColor.soldFreeColor
        case .pending, .available, .otherAvailable,
             .notAvailable, .availableFree, .otherAvailableFree:
            return UIColor.clear
        }
    }

    var isBumpeable: Bool {
        switch self {
        case .available, .availableFree:
            return true
        case .otherAvailable, .otherAvailableFree, .pending, .notAvailable, .sold, .otherSold, .otherSoldFree, .soldFree:
            return false
        }
    }
}
