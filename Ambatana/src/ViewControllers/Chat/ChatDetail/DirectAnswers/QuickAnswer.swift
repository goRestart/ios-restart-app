//
//  QuickAnswer.swift
//  LetGo
//
//  Created by Eli Kohen on 16/02/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

enum QuickAnswer: Equatable {

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

    case meetingAssistant(chatNorrisABtestVersion: ChatNorris)

    static public func ==(lhs: QuickAnswer, rhs: QuickAnswer) -> Bool {
        switch (lhs, rhs) {
        case (.interested, .interested):
            return true
        case (.notInterested, .notInterested):
            return true
        case (.meetUp, .meetUp):
            return true
        case (.stillAvailable, .stillAvailable):
            return true
        case (.isNegotiable, .isNegotiable):
            return true
        case (.likeToBuy, .likeToBuy):
            return true
        case (.listingCondition, .listingCondition):
            return true
        case (.listingStillForSale, .listingStillForSale):
            return true
        case (.listingSold, .listingSold):
            return true
        case (.whatsOffer, .whatsOffer):
            return true
        case (.negotiableYes, .negotiableYes):
            return true
        case (.negotiableNo, .negotiableNo):
            return true
        case (.freeStillHave, .freeStillHave):
            return true
        case (.freeYours, .freeYours):
            return true
        case (.freeAvailable, .freeAvailable):
            return true
        case (.freeNotAvailable, .freeNotAvailable):
            return true
        case (.meetingAssistant(let lTestVar), .meetingAssistant(let rTestVar)):
            return lTestVar == rTestVar
        default:
            return false
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
        case .meetingAssistant:
            return LGLocalizedString.directAnswerLetsMeet
        }
    }

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
        case .meetingAssistant:
            return nil
        }
    }

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



    static func quickAnswersForChatWith(buyer: Bool, isFree: Bool, chatNorrisABtestVersion: ChatNorris) -> [QuickAnswer] {
        var result = [QuickAnswer]()
        if chatNorrisABtestVersion.isActive {
            result.append(.meetingAssistant(chatNorrisABtestVersion: chatNorrisABtestVersion))
        }
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
                result.append(.listingStillForSale)
                result.append(.whatsOffer)
                result.append(.negotiableYes)
                result.append(.negotiableNo)
                result.append(.notInterested)
                result.append(.listingSold)
            }
        }
        return result
    }

    static func quickAnswersForPeriscope(isFree: Bool) -> [QuickAnswer] {
        var result = [QuickAnswer]()
        if isFree {
            result.append(.interested)
            result.append(.meetUp)
            result.append(.listingCondition)
        } else {
            result.append(.stillAvailable)
            result.append(.isNegotiable)
            result.append(.listingCondition)
        }
        return result
    }
}
