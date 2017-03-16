//
//  DirectAnswer.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum QuickAnswer {

    case interested
    case notInterested
    case meetUp
    case stillAvailable
    case isNegotiable
    case likeToBuy
    case productCondition
    case productStillForSale
    case productSold
    case whatsOffer
    case negotiableYes
    case negotiableNo
    case freeStillHave
    case freeYours
    case freeAvailable
    case freeNotAvailable

    var text: String {
        switch self {
        case .interested:
            return LGLocalizedString.directAnswerInterested
        case .notInterested:
            return LGLocalizedString.directAnswerNotInterested
        case .meetUp:
            return LGLocalizedString.directAnswerMeetUp
        case .stillAvailable:
            return LGLocalizedString.directAnswerStillAvailable
        case .isNegotiable:
            return LGLocalizedString.directAnswerIsNegotiable
        case .likeToBuy:
            return LGLocalizedString.directAnswerLikeToBuy
        case .productCondition:
            return LGLocalizedString.directAnswerCondition
        case .productStillForSale:
            return LGLocalizedString.directAnswerStillForSale
        case .productSold:
            return LGLocalizedString.directAnswerProductSold
        case .whatsOffer:
            return LGLocalizedString.directAnswerWhatsOffer
        case .negotiableYes:
            return LGLocalizedString.directAnswerNegotiableYes
        case .negotiableNo:
            return LGLocalizedString.directAnswerNegotiableNo
        case .freeStillHave:
            return LGLocalizedString.directAnswerFreeStillHave
        case .freeYours:
            return LGLocalizedString.directAnswerFreeYours
        case .freeAvailable:
            return LGLocalizedString.directAnswerFreeAvailable
        case .freeNotAvailable:
            return LGLocalizedString.directAnswerFreeNoAvailable
        }
    }

    var quickAnswerType: EventParameterQuickAnswerType {
        switch self {
        case .interested:
            return .interested
        case .notInterested:
            return .notInterested
        case .meetUp:
            return .meetUp
        case .stillAvailable:
            return .stillAvailable
        case .isNegotiable:
            return .isNegotiable
        case .likeToBuy:
            return .likeToBuy
        case .productCondition:
            return .productCondition
        case .productStillForSale:
            return .productStillForSale
        case .productSold:
            return .productSold
        case .whatsOffer:
            return .whatsOffer
        case .negotiableYes:
            return .negotiableYes
        case .negotiableNo:
            return .negotiableNo
        case .freeStillHave:
            return .freeStillHave
        case .freeYours:
            return .freeYours
        case .freeAvailable:
            return .freeAvailable
        case .freeNotAvailable:
            return .freeNotAvailable
        }
    }

    static func quickAnswersForChatWith(buyer: Bool, isFree: Bool) -> [QuickAnswer] {
        var result = [QuickAnswer]()
        if isFree {
            if buyer {
                result.append(.interested)
                result.append(.freeStillHave)
                result.append(.meetUp)
                result.append(.notInterested)
            } else {
                result.append(.freeYours)
                result.append(.freeAvailable)
                result.append(.meetUp)
                result.append(.freeNotAvailable)
            }
        } else {
            if buyer {
                result.append(.interested)
                result.append(.isNegotiable)
                result.append(.likeToBuy)
                result.append(.meetUp)
                result.append(.notInterested)
            } else {
                result.append(.productStillForSale)
                result.append(.whatsOffer)
                result.append(.negotiableYes)
                result.append(.negotiableNo)
                result.append(.notInterested)
                result.append(.productSold)
            }
        }
        return result
    }

    static func quickAnswersForPeriscope(isFree: Bool, repitingPlaceholderText: Bool) -> [QuickAnswer] {
        var result = [QuickAnswer]()
        if isFree {
            result.append(.interested)
            result.append(.meetUp)
            result.append(.productCondition)
        } else {
            if repitingPlaceholderText {
                result.append(.stillAvailable)
                result.append(.isNegotiable)
                result.append(.productCondition)
            } else {
                result.append(.interested)
                result.append(.likeToBuy)
                result.append(.isNegotiable)
                result.append(.meetUp)
            }
            
        }
        return result
    }
}
