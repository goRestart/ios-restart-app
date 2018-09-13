import LGCoreKit
import LGComponents

extension P2PPaymentState {
    var title: String {
        switch self {
        case .makeOffer:
            return R.Strings.chatPaymentStateMakeOffer
        case .viewOffer:
            return R.Strings.chatPaymentStateViewOffer
        case .viewPayCode:
            return R.Strings.chatPaymentStateViewPaymentCode
        case .exchangeCode:
            return R.Strings.chatPaymentStateExchangeCode
        case .payout:
            return R.Strings.chatPaymentStatePayout
        case .offersUnavailable:
            return ""
        }
    }
    
    var actionTitle: String {
        switch self {
        case .makeOffer:
            return R.Strings.chatPaymentStateMakeOfferButtonTitle
        case .viewOffer:
            return R.Strings.chatPaymentStateViewOfferButtonTitle
        case .viewPayCode:
            return R.Strings.chatPaymentStateViewPaymentCodeButtonTitle
        case .exchangeCode:
            return R.Strings.chatPaymentStateExchangeCodeButtonTitle
        case .payout:
            return R.Strings.chatPaymentStatePayoutButtonTitle
        case .offersUnavailable:
            return ""
        }
    }
}
