import Foundation

enum ButtonActionEvent {
    case makeOffer
    case viewOffer(offerId: String)
    case viewPayCode(offerId: String)
    case exchangeCode(offerId: String)
    case payout(offerId: String)
    case none
}
