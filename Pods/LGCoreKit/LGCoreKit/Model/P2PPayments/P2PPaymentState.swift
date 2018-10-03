import Foundation

public enum P2PPaymentState {
    // Buyer
    case makeOffer
    case viewPayCode(offerId: String)
    case offersUnavailable

    // Seller
    case viewOffer(offerId: String)
    case exchangeCode(offerId: String)
    case payout(offerId: String)
}
