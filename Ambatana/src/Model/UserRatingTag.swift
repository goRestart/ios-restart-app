//
//  UserRatingTag.swift
//  LetGo
//
//  Created by Albert Hernández López on 23/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

protocol UserRatingTag {
    var localizedText: String { get }
    static var allValues: [Self] { get }
    static func make(string: String) -> [Self]
}

extension UserRatingTag {
    static func make(string: String) -> [Self] {
        let components = string.components(separatedBy: ". ")
        return allValues.filter { components.contains($0.localizedText) }
    }
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

enum PositiveUserRatingTag: UserRatingTag {
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
    
    static var allValues: [PositiveUserRatingTag] {
        return [.polite, .showedUpOnTime, .quickResponses, .fairPrices, .helpful, .trustworthy]
    }
}
