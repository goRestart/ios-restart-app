//
//  UserRatingTag.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol UserRatingTag {
    var localizedText: String { get }
}

enum NegativeUserRatingTag: UserRatingTag {
    case notPolite, didntShowUp, slowResponses, unfairPrice, notTrustworthy, itemNotAsAdvertised
    
    var localizedText: String {
        switch self {
        case .notPolite:
            return LGLocalizedString.rateUserNegativeNotPolite
        case .didntShowUp:
            return LGLocalizedString.rateUserNegativeDidntShowUp
        case .slowResponses:
            return LGLocalizedString.rateUserNegativeSlowResponses
        case .unfairPrice:
            return LGLocalizedString.rateUserNegativeUnfairPrice
        case .notTrustworthy:
            return LGLocalizedString.rateUserNegativeNotTrustworthy
        case .itemNotAsAdvertised:
            return LGLocalizedString.rateUserNegativeItemNotAsAdvertised
        }
    }
    
    static var allValues: [NegativeUserRatingTag] {
        return [.notPolite, .didntShowUp, .slowResponses, .unfairPrice, .notTrustworthy, .itemNotAsAdvertised]
    }
}

enum PositiveUserRativeTag: UserRatingTag {
    case polite, showedUpOnTime, quickResponses, fairPrices, helpful, trustworthy
    
    var localizedText: String {
        switch self {
        case .polite:
            return LGLocalizedString.rateUserPositivePolite
        case .showedUpOnTime:
            return LGLocalizedString.rateUserPositiveShowedUpOnTime
        case .quickResponses:
            return LGLocalizedString.rateUserPositiveQuickResponses
        case .fairPrices:
            return LGLocalizedString.rateUserPositiveFairPrices
        case .helpful:
            return LGLocalizedString.rateUserPositiveHelpful
        case .trustworthy:
            return LGLocalizedString.rateUserPositiveTrustworthy
        }
    }
    
    static var allValues: [PositiveUserRativeTag] {
        return [.polite, .showedUpOnTime, .quickResponses, .helpful, .trustworthy]
    }
}
