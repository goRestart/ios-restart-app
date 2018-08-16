import Foundation
import LGComponents

enum ReportOptionType: String {

    // Report Product

    // Step 1
    case itShouldntBeOnLetgo = "inappropriate"
    case iThinkItsAScam = "scam"
    case iTsADuplicateListing = "duplicate"
    case itsInTheWrongCategory = "wrong_category"

    // Step 2 (from itShouldntBeOnLetgo)
    case sexualContent = "inappropriate_obscene"
    case drugsAlcoholOrTobacco = "inappropriate_drugs"
    case weaponsOrViolentContent = "inappropriate_violent"
    case otherReasonItShouldntBeOnLetgo = "inappropriate_other"

    // Report User

    // Step 1
    case sellingSomethingInappropriate = "inappropriate_sell"
    case suspiciousBehaviour = "behaviour"
    case inappropriateProfilePhotoOrBio = "profile"
    case problemDuringMeetup = "meetup"
    case inappropriateChatMessages = "chat"
    case unrealisticPriceOrOffers = "unrealistic_offer"

    // Step 2A (from suspiciousBehaviour)
    case notRespondingToMessages = "behaviour_unresponding"
    case offeringToTradeInsteadOfPayingInCash = "behaviour_trading"
    case offeringToPayWithWesternUnionOrPaypal = "behaviour_payment"
    case spamAccount = "behaviour_spam"
    case otherSuspiciousBehaviour = "behaviour_other"

    // Step 2B (from inappropriateProfilePhotoOrBio)
    case inappropriateProfilePhoto = "profile_photo"
    case inappropriateBio = "profile_bio"

    // Step 2C (from problemDuringMeetup)
    case robberyOrViolentIncident = "meetup_violent"
    case paidWithCounterfeitMoney = "meetup_false_money"
    case didntShowUp = "meetup_did_not_show"
    case itemDefectiveOrNotAsDescribed = "meetup_faulty_item"
    case otherProblemDuringMeetup = "meetup_other"

    // Step 2D (from inappropriateChatmessages)
    case threateningViolence = "chat_violence"
    case rudeOrOffensiveLanguage = "chat_offensive"
    case suspiciousOrScammyBehavior = "chat_scam"
    case sexualOrObsceneLanguage = "chat_obscene"
    case otherReasonInnappropriateChatMessages = "chat_other"


    var text: String {
        switch self {
        case .itShouldntBeOnLetgo: return R.Strings.reportingReasonShouldNotBeOnLetgo
        case .iThinkItsAScam: return R.Strings.reportingReasonItsScam
        case .iTsADuplicateListing: return R.Strings.reportingReasonDuplicateListing
        case .itsInTheWrongCategory: return R.Strings.reportingReasonWrongCategory
        case .sexualContent: return R.Strings.reportingReasonSexualContent
        case .drugsAlcoholOrTobacco: return R.Strings.reportingReasonDrugs
        case .weaponsOrViolentContent: return R.Strings.reportingReasonWeapons
        case .otherReasonItShouldntBeOnLetgo: return R.Strings.reportingReasonOther
        case .sellingSomethingInappropriate: return R.Strings.reportingReasonSellingInappropiate
        case .suspiciousBehaviour: return R.Strings.reportingReasonSuspiciousBehavior
        case .inappropriateProfilePhotoOrBio: return R.Strings.reportingReasonInappropiatePhotoOrBio
        case .problemDuringMeetup: return R.Strings.reportingReasonProblemMeetup
        case .inappropriateChatMessages: return R.Strings.reportingReasonInappropiateChatMessages
        case .unrealisticPriceOrOffers: return R.Strings.reportingReasonUnrealisticPrice
        case .notRespondingToMessages: return R.Strings.reportingReasonNotResponding
        case .offeringToTradeInsteadOfPayingInCash: return R.Strings.reportingReasonOfferedTrade
        case .offeringToPayWithWesternUnionOrPaypal: return R.Strings.reportingReasonOfferedWesternUnionOrPaypañ
        case .spamAccount: return R.Strings.reportingReasonSpamAccount
        case .otherSuspiciousBehaviour: return R.Strings.reportingReasonOther
        case .inappropriateProfilePhoto: return R.Strings.reportingReasonProfilePhoto
        case .inappropriateBio: return R.Strings.reportingReasonBio
        case .robberyOrViolentIncident: return R.Strings.reportingReasonRobbery
        case .paidWithCounterfeitMoney: return R.Strings.reportingReasonCounterfeitMoney
        case .didntShowUp: return R.Strings.reportingReasonDidnTShowUp
        case .itemDefectiveOrNotAsDescribed: return R.Strings.reportingReasonItemDefective
        case .otherProblemDuringMeetup: return R.Strings.reportingReasonOther
        case .threateningViolence: return R.Strings.reportingReasonThreatingViolence
        case .rudeOrOffensiveLanguage: return R.Strings.reportingReasonRudeOffensiveLanguage
        case .suspiciousOrScammyBehavior: return R.Strings.reportingReasonSuspiciousBehavior
        case .sexualOrObsceneLanguage: return R.Strings.reportingReasonSexualLanguage
        case .otherReasonInnappropriateChatMessages: return R.Strings.reportingReasonOther
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
            case .offeringToPayWithWesternUnionOrPaypal: return R.Asset.Reporting.onlinePayment.image
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
             .offeringToTradeInsteadOfPayingInCash, .offeringToPayWithWesternUnionOrPaypal, .robberyOrViolentIncident,
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
             .inappropriateChatMessages:
            return nil
        case .iThinkItsAScam, .iTsADuplicateListing, .itsInTheWrongCategory, .sexualContent,
             .drugsAlcoholOrTobacco, .weaponsOrViolentContent, .otherReasonItShouldntBeOnLetgo:
            return .productBasic
        case .sellingSomethingInappropriate:
            return ReportSentType.userBasic
        case .notRespondingToMessages, .offeringToTradeInsteadOfPayingInCash, .didntShowUp:
            return .userBlockA
        case .offeringToPayWithWesternUnionOrPaypal, .spamAccount, .otherSuspiciousBehaviour, .inappropriateProfilePhoto,
             .inappropriateBio, .rudeOrOffensiveLanguage, .suspiciousOrScammyBehavior,
             .sexualOrObsceneLanguage, .otherReasonInnappropriateChatMessages, .unrealisticPriceOrOffers:
            return .userBlockB
        case .itemDefectiveOrNotAsDescribed:
            return .userBlockAndReviewA
        case .otherProblemDuringMeetup:
            return .userBlockAndReviewB
        case .robberyOrViolentIncident, .paidWithCounterfeitMoney:
            return .userLawEnforcement
        case .threateningViolence:
            return .userLawEnforcementBlock
        }
    }
}
