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
    case listingCondition
    case listingStillForSale
    case listingSold
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
    case listingConditionGood
    case listingConditionDescribe
    case meetUpWhereYouWant
    case meetUpLocated

    // 🦄 hackaton
    case meetingAssistant(chatNorrisABtestVersion: ChatNorris)

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
        case meetingAssistant
        
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
            case .meetingAssistant:
                return "_Meeting Assistant"
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
        case .listingCondition:
            return LGLocalizedString.directAnswerCondition
        case .listingStillForSale:
            return LGLocalizedString.directAnswerStillForSale
        case .listingSold:
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
        case .listingConditionGood:
            return LGLocalizedString.directAnswerGoodCondition
        case .listingConditionDescribe:
            return LGLocalizedString.directAnswerDescribeCondition
        case .meetUpWhereYouWant:
            return LGLocalizedString.directAnswerWhereMeetUp
        case .meetUpLocated:
            return LGLocalizedString.directAnswerWhereLocated
        case .meetingAssistant:
            return "_Let's meet"
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
        case .listingCondition:
            return .listingCondition
        case .listingStillForSale:
            return .listingStillForSale
        case .listingSold:
            return .listingSold
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
            return QuickAnswerType.price.name
        case .listingCondition:
            return QuickAnswerType.condition.name
        case .listingStillForSale:
            return QuickAnswerType.availability.name
        case .listingSold:
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
        case .listingConditionGood:
            return QuickAnswerType.condition.name
        case .listingConditionDescribe:
            return QuickAnswerType.condition.name
        case .meetUpWhereYouWant:
            return QuickAnswerType.meetUp.name
        case .meetUpLocated:
            return QuickAnswerType.meetUp.name
        case .meetingAssistant:
            return QuickAnswerType.meetingAssistant.name
        default:
            return nil
        }
    }

    // Hackaton

    var isMeetingAssistant: Bool {
        switch self {
        case .meetingAssistant:
            return true
        default:
            return false
        }
    }

    var icon: UIImage? {
        switch self {
        case .meetingAssistant:
            return #imageLiteral(resourceName: "ic_calendar").withRenderingMode(.alwaysTemplate)
        default:
            return nil
        }
    }

    var textColor: UIColor {
        switch self {
        case .meetingAssistant(let chatNorrisABtestVersion):
            switch chatNorrisABtestVersion {
            case .baseline, .control, .greenButton, .redButton:
                return UIColor.white
            case .whiteButton:
                return UIColor.primaryColor
            }
        default:
            return UIColor.white
        }
    }

    var iconTintColor: UIColor {
        switch self {
        case .meetingAssistant(let chatNorrisABtestVersion):
            switch chatNorrisABtestVersion {
            case .baseline, .control, .greenButton, .redButton:
                return UIColor.white
            case .whiteButton:
                return UIColor.primaryColor
            }
        default:
            return UIColor.white
        }
    }

    var bgColor: UIColor {
        switch self {
        case .meetingAssistant(let chatNorrisABtestVersion):
            switch chatNorrisABtestVersion {
            case .baseline, .control, .redButton:
                return UIColor.primaryColor
            case  .greenButton:
                return UIColor.terciaryColor
            case .whiteButton:
                return UIColor.white
            }
        default:
            return UIColor.primaryColor
        }
    }

    static func quickAnswersForChatWith(buyer: Bool, isFree: Bool, isDynamic: Bool, isNegotiable: Bool,
                                        chatNorrisABtestVersion: ChatNorris) -> [[QuickAnswer]] {
        var result = [[QuickAnswer]]()
        if chatNorrisABtestVersion.isActive {
            result.append(meetingAssistantQuickAnswer(chatNorrisABtestVersion: chatNorrisABtestVersion))
        }
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
                    result.append([.listingSold])
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
                    result.append([.listingStillForSale])
                    result.append([.whatsOffer])
                    result.append([.negotiableYes])
                    result.append([.negotiableNo])
                    result.append([.notInterested])
                    result.append([.listingSold])
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
                result.append([.listingCondition])
            } else {
                result.append([.stillAvailable])
                result.append([.isNegotiable])
                result.append([.listingCondition])
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
        return [.listingCondition, .listingConditionGood, .listingConditionDescribe]
    }
    
    static func meetUpQuickAnswers() -> [QuickAnswer] {
        return [.meetUp, .meetUpLocated, .meetUpWhereYouWant]
    }
    
    static func negotiablePriceSellerQuickAnswers() -> [QuickAnswer] {
        return [.negotiableYes, .whatsOffer]
    }

    static func meetingAssistantQuickAnswer(chatNorrisABtestVersion: ChatNorris) -> [QuickAnswer] {
        return [.meetingAssistant(chatNorrisABtestVersion: chatNorrisABtestVersion)]
    }
}
