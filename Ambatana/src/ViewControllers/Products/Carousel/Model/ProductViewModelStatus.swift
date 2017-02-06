//
//  ProductViewModelStatus.swift
//  LetGo
//
//  Created by Eli Kohen on 06/02/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//


enum ProductViewModelStatus {

    // When Mine:
    case pending
    case pendingAndCommercializable
    case available
    case availableAndCommercializable
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

    var isEditable: Bool {
        switch self {
        case .pending, .pendingAndCommercializable, .available, .availableAndCommercializable, .availableFree:
            return true
        case .notAvailable, .sold, .otherSold, .otherAvailable, .otherSoldFree, .soldFree, .otherAvailableFree:
            return false
        }
    }

    var isFree: Bool {
        switch self {
        case .availableFree, .otherAvailableFree, .otherSoldFree, .soldFree :
            return true
        case .pending, .pendingAndCommercializable, .available, .availableAndCommercializable, .notAvailable, .sold,
             .otherSold, .otherAvailable:
            return false
        }
    }

    var isAvailable: Bool {
        switch self {
        case .availableFree, .otherAvailableFree, .available, .otherAvailable:
            return true
        case .pending, .pendingAndCommercializable, .availableAndCommercializable, .notAvailable, .sold, .otherSold,
             .otherSoldFree, .soldFree:
            return false
        }
    }

    var directChatsAvailable: Bool {
        switch self {
        case .pending, .pendingAndCommercializable, .available, .availableAndCommercializable, .soldFree,
             .otherSoldFree, .availableFree, .notAvailable, .sold, .otherSold:
            return false
        case  .otherAvailable,  .otherAvailableFree:
            return true
        }
    }

    var string: String? {
        switch self {
        case .sold, .otherSold:
            return LGLocalizedString.productListItemSoldStatusLabel
        case .soldFree, .otherSoldFree:
            return LGLocalizedString.productListItemGivenAwayStatusLabel
        case .pending, .pendingAndCommercializable, .available, .availableAndCommercializable, .otherAvailable, .availableFree, .otherAvailableFree,
             .notAvailable:
            return nil
        }
    }

    var labelColor: UIColor {
        switch self {
        case .sold, .otherSold, .soldFree, .otherSoldFree:
            return UIColor.white
        case .pending, .pendingAndCommercializable, .available, .availableAndCommercializable, .otherAvailable,
             .notAvailable, .availableFree, .otherAvailableFree:
            return UIColor.clear
        }
    }

    var bgColor: UIColor {
        switch self {
        case .sold, .otherSold:
            return UIColor.soldColor
        case .soldFree, .otherSoldFree:
            return UIColor.soldFreeColor
        case .pending, .pendingAndCommercializable, .available, .availableAndCommercializable, .otherAvailable,
             .notAvailable, .availableFree, .otherAvailableFree:
            return UIColor.clear
        }
    }

    func setCommercializable(_ active: Bool) -> ProductViewModelStatus {
        switch self {
        case .pending, .pendingAndCommercializable:
            return active ? .pendingAndCommercializable : .pending
        case .available, .availableAndCommercializable:
            return active ? .availableAndCommercializable : .available
        case .sold, .otherSold, .notAvailable, .otherAvailable, .otherSoldFree, .otherAvailableFree, .soldFree, .availableFree:
            return self
        }
    }

    var isBumpeable: Bool {
        switch self {
        case .available, .availableAndCommercializable, .availableFree, .otherAvailable, .otherAvailableFree:
            return true
        case .pending, .pendingAndCommercializable, .notAvailable, .sold, .otherSold, .otherSoldFree, .soldFree:
            return false
        }
    }
}
