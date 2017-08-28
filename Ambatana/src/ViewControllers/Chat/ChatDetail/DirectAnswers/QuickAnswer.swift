//
//  QuickAnswer.swift
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
    
    // New dynamic quick answers feature flag
    case stillForSale
    case priceFirm
    case priceWillingToNegotiate
    case priceAsking
    case productConditionGood
    case productConditionDescribe
    case meetUpWhereYouWant
    case meetUpLocated
    
    enum QuickAnswerType: String {
        case availability
        case price
        case condition
        case meetUp
        case interested
        case notInterested
        case sold
        case givenAway
        case negotiable
        case notNegotiable
        
        var name: String {
            switch self {
            case .availability:
                return LGLocalizedString.directAnswerAvailabilityTitle
            case .price:
                return LGLocalizedString.directAnswerPriceTitle
            case .condition:
                return LGLocalizedString.directAnswerConditionTitle
            case .meetUp:
                return LGLocalizedString.directAnswerMeetUpTitle
            case .interested:
                return LGLocalizedString.directAnswerInterestedTitle
            case .notInterested:
                return LGLocalizedString.directAnswerNotInterestedTitle
            case .sold:
                return LGLocalizedString.directAnswerSoldTitle
            case .givenAway:
                return LGLocalizedString.directAnswerGivenAwayTitle
            case .negotiable:
                return LGLocalizedString.directAnswerNegotiableTitle
            case .notNegotiable:
                return LGLocalizedString.directAnswerNotNegotiableTitle
            }
        }
    }

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
        case .stillForSale:
            return LGLocalizedString.directAnswerStillForSaleBuyer
        case .priceFirm:
            return LGLocalizedString.directAnswerPriceFirm
        case .priceWillingToNegotiate:
            return LGLocalizedString.directAnswerWillingToNegotiate
        case .priceAsking:
            return LGLocalizedString.directAnswerHowMuchAsking
        case .productConditionGood:
            return LGLocalizedString.directAnswerGoodCondition
        case .productConditionDescribe:
            return LGLocalizedString.directAnswerDescribeCondition
        case .meetUpWhereYouWant:
            return LGLocalizedString.directAnswerWhereMeetUp
        case .meetUpLocated:
            return LGLocalizedString.directAnswerWhereLocated
        }
    }

    // Delete nilable when Dynamic QA ABTest no longer exists OR existing tracking for new QAs
    var quickAnswerType: EventParameterQuickAnswerType? {
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
        default: // New dynamic quick answers
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .interested:
            return QuickAnswerType.interested.name
        case .notInterested:
            return QuickAnswerType.notInterested.name
        case .meetUp:
            return QuickAnswerType.meetUp.name
        case .stillAvailable:
            return QuickAnswerType.availability.name
        case .isNegotiable:
            return QuickAnswerType.negotiable.name
        case .productCondition:
            return QuickAnswerType.condition.name
        case .productStillForSale:
            return QuickAnswerType.availability.name
        case .productSold:
            return QuickAnswerType.sold.name
        case .whatsOffer:
            return QuickAnswerType.negotiable.name
        case .negotiableYes:
            return QuickAnswerType.negotiable.name
        case .negotiableNo:
            return QuickAnswerType.notNegotiable.name
        case .freeStillHave:
            return QuickAnswerType.availability.name
        case .freeAvailable:
            return QuickAnswerType.availability.name
        case .freeNotAvailable:
            return QuickAnswerType.givenAway.name
        case .stillForSale:
            return QuickAnswerType.availability.name
        case .priceFirm:
            return QuickAnswerType.price.name
        case .priceWillingToNegotiate:
            return QuickAnswerType.price.name
        case .priceAsking:
            return QuickAnswerType.price.name
        case .productConditionGood:
            return QuickAnswerType.condition.name
        case .productConditionDescribe:
            return QuickAnswerType.condition.name
        case .meetUpWhereYouWant:
            return QuickAnswerType.meetUp.name
        case .meetUpLocated:
            return QuickAnswerType.meetUp.name
        default:
            return nil
        }
    }

    static func quickAnswersForChatWith(buyer: Bool, isFree: Bool, isDynamic: Bool, isNegotiable: Bool) -> [[QuickAnswer]] {
        var result = [[QuickAnswer]]()
        if isDynamic {
            if isFree {
                if buyer {
                    result.append(availabilityQuickAnswers(isFree: isFree))
                    result.append(conditionQuickAnswers())
                    result.append(meetUpQuickAnswers())
                    result.append([.interested])
                    result.append([.notInterested])
                } else {
                    result.append([.freeAvailable])
                    result.append([.freeNotAvailable])
                    result.append([.interested])
                    result.append([.notInterested])
                    result.append(meetUpQuickAnswers())
                }
            } else {
                if buyer {
                    result.append(availabilityQuickAnswers(isFree: isFree))
                    if isNegotiable {
                        result.append([.priceAsking])
                    } else {
                        result.append(noNegotiablePriceQuickAnswers())
                    }
                    result.append(conditionQuickAnswers())
                    result.append(meetUpQuickAnswers())
                    result.append([.interested])
                    result.append([.notInterested])
                } else {
                    result.append([.freeAvailable])
                    result.append([.productSold])
                    if isNegotiable {
                        result.append(negotiablePriceSellerQuickAnswers())
                    } else {
                        result.append([.negotiableNo])
                    }
                    result.append([.interested])
                    result.append([.notInterested])
                    result.append(meetUpQuickAnswers())
                }
            }
        } else {
            if isFree {
                if buyer {
                    result.append([.interested])
                    result.append([.freeStillHave])
                    result.append([.meetUp])
                    result.append([.notInterested])
                } else {
                    result.append([.freeYours])
                    result.append([.freeAvailable])
                    result.append([.meetUp])
                    result.append([.freeNotAvailable])
                }
            } else {
                if buyer {
                    result.append([.interested])
                    result.append([.isNegotiable])
                    result.append([.likeToBuy])
                    result.append([.meetUp])
                    result.append([.notInterested])
                } else {
                    result.append([.productStillForSale])
                    result.append([.whatsOffer])
                    result.append([.negotiableYes])
                    result.append([.negotiableNo])
                    result.append([.notInterested])
                    result.append([.productSold])
                }
            }
        }
        return result
    }

    static func quickAnswersForPeriscope(isFree: Bool, isDynamic: Bool, isNegotiable: Bool) -> [[QuickAnswer]] {
        var result = [[QuickAnswer]]()
        if isDynamic {
            result.append(availabilityQuickAnswers(isFree: isFree))
            result.append(meetUpQuickAnswers())
            result.append(conditionQuickAnswers())
            if !isFree {
                if isNegotiable {
                    result.append([.priceAsking])
                } else {
                    result.append(noNegotiablePriceQuickAnswers())
                }
            }
        } else {
            if isFree {
                result.append([.interested])
                result.append([.meetUp])
                result.append([.productCondition])
            } else {
                result.append([.stillAvailable])
                result.append([.isNegotiable])
                result.append([.productCondition])
            }
        }
        return result
    }
    
    static func availabilityQuickAnswers(isFree: Bool) -> [QuickAnswer] {
        if isFree {
            return [.stillAvailable, .freeStillHave]
        } else {
            return [.stillAvailable, .stillForSale, .freeStillHave]
        }
    }
    
    static func noNegotiablePriceQuickAnswers() -> [QuickAnswer] {
        return [.isNegotiable, .priceFirm, .priceWillingToNegotiate]
    }
    
    static func conditionQuickAnswers() -> [QuickAnswer] {
        return [.productCondition, .productConditionGood, .productConditionDescribe]
    }
    
    static func meetUpQuickAnswers() -> [QuickAnswer] {
        return [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
    }
    
    static func negotiablePriceSellerQuickAnswers() -> [QuickAnswer] {
        return [.negotiableYes, .whatsOffer]
    }
}
