import LGComponents

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
            return R.Strings.rateUserNegativeNotPolite
        case .didntShowUp:
            return R.Strings.rateUserNegativeDidntShowUp
        case .slowResponses:
            return R.Strings.rateUserNegativeSlowResponses
        case .unfairPrice:
            return R.Strings.rateUserNegativeUnfairPrice
        case .notTrustworthy:
            return R.Strings.rateUserNegativeNotTrustworthy
        case .itemNotAsAdvertised:
            return R.Strings.rateUserNegativeItemNotAsAdvertised
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
            return R.Strings.rateUserPositivePolite
        case .showedUpOnTime:
            return R.Strings.rateUserPositiveShowedUpOnTime
        case .quickResponses:
            return R.Strings.rateUserPositiveQuickResponses
        case .fairPrices:
            return R.Strings.rateUserPositiveFairPrices
        case .helpful:
            return R.Strings.rateUserPositiveHelpful
        case .trustworthy:
            return R.Strings.rateUserPositiveTrustworthy
        }
    }
    
    static var allValues: [PositiveUserRatingTag] {
        return [.polite, .showedUpOnTime, .quickResponses, .fairPrices, .helpful, .trustworthy]
    }
}
