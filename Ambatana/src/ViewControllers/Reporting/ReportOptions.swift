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
        default:
            return "Option Title" // FIXME: add option texts
        }
    }

    var icon: UIImage {
        switch self {
        default:
            return R.Asset.Reporting.meetupProblem.image // FIXME: add option images
        }
    }

    var allowsAdditionalNotes: Bool {
        switch self {
        default:
            return true // FIXME: define this
        }
    }
}
