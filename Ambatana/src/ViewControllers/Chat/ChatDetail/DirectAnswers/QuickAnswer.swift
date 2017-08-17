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
    
    enum QuickAnswerType: String {
        case availability = "Availability"
        case price = "Price"
        case condition = "Condition"
        case meetUp = "Meet up"
        case interested = "Interested"
        case notInterested = "Not interested"
        case sold = "Sold"
        case notAvailable = "Not available"
        case negotiable = "Negotiable"
        case notNegotiable = "Not negotiable"
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
    
    var title: String {
        switch self {
        case .interested:
            return QuickAnswerType.interested.rawValue
        case .notInterested:
            return QuickAnswerType.notInterested.rawValue
        case .meetUp:
            return QuickAnswerType.meetUp.rawValue
        case .stillAvailable:
            return QuickAnswerType.availability.rawValue
        case .isNegotiable:
            return QuickAnswerType.negotiable.rawValue
        case .likeToBuy:
            return "unknown"
        case .productCondition:
            return QuickAnswerType.condition.rawValue
        case .productStillForSale:
            return QuickAnswerType.availability.rawValue
        case .productSold:
            return QuickAnswerType.sold.rawValue
        case .whatsOffer:
            return QuickAnswerType.negotiable.rawValue
        case .negotiableYes:
            return QuickAnswerType.negotiable.rawValue
        case .negotiableNo:
            return QuickAnswerType.notNegotiable.rawValue
        case .freeStillHave:
            return QuickAnswerType.availability.rawValue
        case .freeYours:
            return "unknown"
        case .freeAvailable:
            return QuickAnswerType.availability.rawValue
        case .freeNotAvailable:
            return "unknown"
        case .stillForSale:
            return QuickAnswerType.availability.rawValue
        case .priceFirm:
            return QuickAnswerType.price.rawValue
        case .priceWillingToNegotiate:
            return QuickAnswerType.price.rawValue
        case .priceAsking:
            return QuickAnswerType.price.rawValue
        case .productConditionGood:
            return QuickAnswerType.condition.rawValue
        case .productConditionDescribe:
            return QuickAnswerType.condition.rawValue
        case .meetUpWhereYouWant:
            return QuickAnswerType.meetUp.rawValue
        case .meetUpLocated:
            return QuickAnswerType.meetUp.rawValue
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
                result.append(randomAvailabilityQA())
                result.append(randomMeetUpQA())
                result.append(randomConditionQA())
            } else {
                result.append(randomAvailabilityQA())
                result.append(randomMeetUpQA())
                result.append(randomConditionQA())
            }
        } else {
            if isFree {
                result.append(.stillAvailable)
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
    
    static func randomAvailabilityQA() -> QuickAnswer {
        let qas : [QuickAnswer]
        qas = [.stillAvailable, .stillForSale, .freeStillHave]
        return qas.random() ?? .stillAvailable
    }
    
    static func randomPriceQA() -> QuickAnswer {
        let qas : [QuickAnswer]
        qas = [.isNegotiable, .priceFirm, .priceWillingToNegotiate, .priceAsking]
        return qas.random() ?? .isNegotiable
    }
    
    static func randomConditionQA() -> QuickAnswer {
        let qas : [QuickAnswer]
        qas = [.productCondition, .productConditionGood, .productConditionDescribe]
        return qas.random() ?? .productCondition
    }
    
    static func randomMeetUpQA() -> QuickAnswer {
        let qas : [QuickAnswer]
        qas = [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
        return qas.random() ?? .meetUp
    }
    
    static func randomNegotiableQA() -> QuickAnswer {
        let qas : [QuickAnswer]
        qas = [.negotiableYes, .productSold]
        return qas.random() ?? .negotiableYes
    }
}
