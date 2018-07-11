import Foundation
import LGComponents

enum ReportOptionType {

    // Report Product

    // Step 1
    case itShouldntBeOnLetgo
    case iThinkItsAScam
    case iTsADuplicateListing
    case itsInTheWrongCategory

    // Step 2 (from itShouldntBeOnLetgo)
    case sexualContent
    case drugsAlcoholOrTobacco
    case weaponsOrViolentContent
    case otherReasonItShouldntBeOnLetgo

    // Report User

    // Step 1
    case sellingSomethingInappropriate
    case suspiciousBehaviour
    case inappropriateProfilePhotoOrBio
    case problemDuringMeetup
    case inappropriateChatMessages
    case unrealisticPriceOrOffers

    // Step 2A (from suspiciousBehaviour)
    case notRespondingToMessages
    case offeringToTradeInsteadOfPayingInCash
    case offeringRoPayWithWesternUnionOrPaypal
    case spamAccount
    case otherSuspiciousBehaviour

    // Step 2B (from inappropriateProfilePhotoOrBio)
    case inappropriateProfilePhoto
    case inappropriateBio

    // Step 2C (from problemDuringMeetup)
    case robberyOrViolentIncident
    case paidWithCounterfeitMoney
    case didntShowUp
    case itemDefectiveOrNotAsDescribed
    case otherProblemDuringMeetup

    // Step 2D (from inappropriateChatmessages)
    case threateningViolence
    case rudeOrOffensiveLanguage
    case suspiciousOrScammyBehavior
    case sexualOrObsceneLanguage
    case otherReasonInnappropriateChatMessages


    var text: String {
        switch self {
            case .itShouldntBeOnLetgo: return "Test Option"
            case .iThinkItsAScam: return "Test Option"
            case .iTsADuplicateListing: return "Test Option"
            case .itsInTheWrongCategory: return "Test Option"
            case .sexualContent: return "Test Option"
            case .drugsAlcoholOrTobacco: return "Test Option"
            case .weaponsOrViolentContent: return "Test Option"
            case .otherReasonItShouldntBeOnLetgo: return "Test Option"
            case .sellingSomethingInappropriate: return "Test Option"
            case .suspiciousBehaviour: return "Test Option"
            case .inappropriateProfilePhotoOrBio: return "Test Option"
            case .problemDuringMeetup: return "Test Option"
            case .inappropriateChatMessages: return "Test Option"
            case .unrealisticPriceOrOffers: return "Test Option"
            case .notRespondingToMessages: return "Test Option"
            case .offeringToTradeInsteadOfPayingInCash: return "Test Option"
            case .offeringRoPayWithWesternUnionOrPaypal: return "Test Option"
            case .spamAccount: return "Test Option"
            case .otherSuspiciousBehaviour: return "Test Option"
            case .inappropriateProfilePhoto: return "Test Option"
            case .inappropriateBio: return "Test Option"
            case .robberyOrViolentIncident: return "Test Option"
            case .paidWithCounterfeitMoney: return "Test Option"
            case .didntShowUp: return "Test Option"
            case .itemDefectiveOrNotAsDescribed: return "Test Option"
            case .otherProblemDuringMeetup: return "Test Option"
            case .threateningViolence: return "Test Option"
            case .rudeOrOffensiveLanguage: return "Test Option"
            case .suspiciousOrScammyBehavior: return "Test Option"
            case .sexualOrObsceneLanguage: return "Test Option"
            case .otherReasonInnappropriateChatMessages: return "Test Option"
        }
    }

    var icon: UIImage {
        switch self {
            case .itShouldntBeOnLetgo: return R.Asset.Reporting.forbidden.image
            case .iThinkItsAScam: return R.Asset.Reporting.scam.image
            case .iTsADuplicateListing: return R.Asset.Reporting.duplicate.image
            case .itsInTheWrongCategory: return R.Asset.Reporting.wrongCategory.image
            case .sexualContent: return R.Asset.Reporting.sexualContent.image
            case .drugsAlcoholOrTobacco: return R.Asset.Reporting.drugs.image
            case .weaponsOrViolentContent: return R.Asset.Reporting.weapons.image
            case .otherReasonItShouldntBeOnLetgo: return R.Asset.Reporting.other.image
            case .sellingSomethingInappropriate: return R.Asset.Reporting.inappropriateItem.image
            case .suspiciousBehaviour: return R.Asset.Reporting.suspicious.image
            case .inappropriateProfilePhotoOrBio: return R.Asset.Reporting.inappropriateProfile.image
            case .problemDuringMeetup: return R.Asset.Reporting.meetupProblem.image
            case .inappropriateChatMessages: return R.Asset.Reporting.inappropriateChat.image
            case .unrealisticPriceOrOffers: return R.Asset.Reporting.unrealisticPrice.image
            case .notRespondingToMessages: return R.Asset.Reporting.noAnswerChat.image
            case .offeringToTradeInsteadOfPayingInCash: return R.Asset.Reporting.trade.image
            case .offeringRoPayWithWesternUnionOrPaypal: return R.Asset.Reporting.onlinePayment.image
            case .spamAccount: return R.Asset.Reporting.spam.image
            case .otherSuspiciousBehaviour: return R.Asset.Reporting.other.image
            case .inappropriateProfilePhoto: return R.Asset.Reporting.inappropriatePhoto.image
            case .inappropriateBio: return R.Asset.Reporting.inappropriateBio.image
            case .robberyOrViolentIncident: return R.Asset.Reporting.robbery.image
            case .paidWithCounterfeitMoney: return R.Asset.Reporting.counterfeitMoney.image
            case .didntShowUp: return R.Asset.Reporting.noShow.image
            case .itemDefectiveOrNotAsDescribed: return R.Asset.Reporting.itemDefective.image
            case .otherProblemDuringMeetup: return R.Asset.Reporting.other.image
            case .threateningViolence: return R.Asset.Reporting.violence.image
            case .rudeOrOffensiveLanguage: return R.Asset.Reporting.offensiveChat.image
            case .suspiciousOrScammyBehavior: return R.Asset.Reporting.suspicious.image
            case .sexualOrObsceneLanguage: return R.Asset.Reporting.obsceneLanguage.image
            case .otherReasonInnappropriateChatMessages: return R.Asset.Reporting.other.image
        }
    }

    var allowsAdditionalNotes: Bool {
        switch self {
        case .itShouldntBeOnLetgo, .iThinkItsAScam, .iTsADuplicateListing, .itsInTheWrongCategory, .sexualContent,
             .drugsAlcoholOrTobacco, .weaponsOrViolentContent, .otherReasonItShouldntBeOnLetgo,
             .sellingSomethingInappropriate, .suspiciousBehaviour, .inappropriateProfilePhotoOrBio, .problemDuringMeetup,
             .inappropriateChatMessages, .unrealisticPriceOrOffers, .notRespondingToMessages,
             .offeringToTradeInsteadOfPayingInCash, .offeringRoPayWithWesternUnionOrPaypal, .robberyOrViolentIncident,
             .paidWithCounterfeitMoney, .didntShowUp, .itemDefectiveOrNotAsDescribed, .threateningViolence:
            return false
        case .spamAccount, .otherSuspiciousBehaviour, .inappropriateProfilePhoto, .inappropriateBio,
             .otherProblemDuringMeetup, .rudeOrOffensiveLanguage, .suspiciousOrScammyBehavior,
             .sexualOrObsceneLanguage, .otherReasonInnappropriateChatMessages:
            return true
        }
    }

    var reportSentType: ReportSentType? {
        switch self {
        case .itShouldntBeOnLetgo,.suspiciousBehaviour, .inappropriateProfilePhotoOrBio, .problemDuringMeetup,
             .inappropriateChatMessages, .unrealisticPriceOrOffers:
            return nil
        case .iThinkItsAScam, .iTsADuplicateListing, .itsInTheWrongCategory, .sexualContent,
             .drugsAlcoholOrTobacco, .weaponsOrViolentContent, .otherReasonItShouldntBeOnLetgo:
            return ReportSentType.productBasic
        case .sellingSomethingInappropriate:
            return ReportSentType.userBasic
        case .notRespondingToMessages, .offeringToTradeInsteadOfPayingInCash, .didntShowUp, .itemDefectiveOrNotAsDescribed:
            return ReportSentType.userBlockA
        case .offeringRoPayWithWesternUnionOrPaypal, .spamAccount, .otherSuspiciousBehaviour, .inappropriateProfilePhoto,
             .inappropriateBio, .otherProblemDuringMeetup, .rudeOrOffensiveLanguage, .suspiciousOrScammyBehavior,
             .sexualOrObsceneLanguage, .otherReasonInnappropriateChatMessages :
            return ReportSentType.userBlockB
        case .robberyOrViolentIncident, .paidWithCounterfeitMoney:
            return ReportSentType.userLawEnforcement
        case .threateningViolence:
            return ReportSentType.userLawEnforcementBlock
        }
    }
}
