//
//  DirectAnswer.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum QuickAnswer {

    case interested // Interested ! Yes, I'm interested vs I'm interested
    case notInterested // Not interested 
    case meetUp // Meet up
    case stillAvailable // Availability ! Is it still available?
    case isNegotiable // Price
    case likeToBuy
    case productCondition // Condition ! "What condition is the item in?" vs "What condition is this item in?"
    case productStillForSale // Yes, it's still for sale
    case productSold // Seller. Availability !. Sorry, it has been sold vs Sorry, the product has been sold!"
    case whatsOffer // Negotiable. Seller
    case negotiableYes // Negotiable. Seller
    case negotiableNo // Not negotiable
    case freeStillHave // Availability ! Do you still have it? vs Still have it?
    case freeYours
    case freeAvailable // Seller. Availability
    case freeNotAvailable
    
    case stillForSale // Availability. Is it still for sale?
    case priceFirm // Price. Is the price firm?
    case priceWillingToNegotiate // Price. Would you be willing to negotiate?
    case priceAsking // Price. Negotiable only. How much are you asking?
    case productConditionGood // Condition. Is it in good condition?
    case productConditionDescribe // Condition. Can you describe the condition?
    case meetUpWhereYouWant // Meet up. Where do you want to meet up?
    case meetUpLocated // Meet up. Where are you located?

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
            return "Is it still for sale?"
        case .priceFirm:
            return "Is the price firm?"
        case .priceWillingToNegotiate:
            return "Would you be willing to negotiate?"
        case .priceAsking:
            return "How much are you asking?"
        case .productConditionGood:
            return "Is it in good condition?"
        case .productConditionDescribe:
            return "Can you describe the condition?"
        case .meetUpWhereYouWant:
            return "Where do you want to meet up?"
        case .meetUpLocated:
            return "Where are you located?"
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
//FIXME TODO warning Dummy values. To fix
        case .stillForSale:
            return .interested
        case .priceFirm:
            return .interested
        case .priceWillingToNegotiate:
            return .interested
        case .priceAsking:
            return .interested
        case .productConditionGood:
            return .interested
        case .productConditionDescribe:
            return .interested
        case .meetUpWhereYouWant:
            return .interested
        case .meetUpLocated:
            return .interested
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

    static func quickAnswersForPeriscope(isFree: Bool, isDynamic: Bool) -> [QuickAnswer] {
        var result = [QuickAnswer]()
        if isDynamic {
            if isFree {
                result.append(.interested)
                result.append(.meetUp)
                result.append(.productCondition)
            } else {
                result.append(.stillAvailable)
                result.append(.isNegotiable)
                result.append(.productCondition)
            }
        } else {
            if isFree {
                result.append(.interested)
                result.append(.meetUp)
                result.append(.productCondition)
            } else {
                result.append(.stillAvailable)
                result.append(.isNegotiable)
                result.append(.productCondition)
            }
        }
        return result
    }
    
    enum StillAvailable {
        case isStillAvailable
        case isStillForSale
        case stillHaveIt
        
        var title: String {
            return "Availability"
        }
        
        var message: String {
            switch self {
            case .isStillAvailable:
                return LGLocalizedString.directAnswerStillAvailable
            case .isStillForSale:
                return "for sale"
            case .stillHaveIt:
                return "still have it"
            }
        }
    }
}
