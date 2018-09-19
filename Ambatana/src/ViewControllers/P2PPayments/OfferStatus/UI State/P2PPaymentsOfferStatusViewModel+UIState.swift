import Foundation
import LGCoreKit
import LGComponents


extension P2PPaymentsOfferStatusViewModel {
    private static let currencyHelper = Core.currencyHelper
    private static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        return formatter
    }()

    enum UIState {
        case loading
        case buyerInfoLoaded(offer: P2PPaymentOffer, listing: Listing)
        case sellerInfoLoaded(offer: P2PPaymentOffer, listing: Listing, buyer: User)

        var showLoadingIndicator: Bool {
            switch self {
            case .loading: return true
            default: return false
            }
        }

        var hideBuyerInfo: Bool {
            switch self {
            case .buyerInfoLoaded: return false
            default: return true
            }
        }

        var hideSellerInfo: Bool {
            switch self {
            case .sellerInfoLoaded: return false
            default: return true
            }
        }

        var offer: P2PPaymentOffer? {
            switch self {
            case .loading:
                return nil
            case .buyerInfoLoaded(offer: let offer, listing: _):
                return offer
            case .sellerInfoLoaded(offer: let offer, listing: _, buyer: _):
                return offer
            }
        }

        var listing: Listing? {
            switch self {
            case .loading:
                return nil
            case .buyerInfoLoaded(offer: _, listing: let listing):
                return listing
            case .sellerInfoLoaded(offer: _, listing: let listing, buyer: _):
                return listing
            }
        }

        var buyer: User? {
            guard case let .sellerInfoLoaded(offer: _, listing: _, buyer: buyer) = self else { return nil }
            return buyer
        }

        var listingTitle: String? {
            return listing?.title
        }

        var listingImageURL: URL? {
            return listing?.thumbnail?.fileURL
        }

        var sellerHeaderImageURL: URL? {
            return buyer?.avatar?.fileURL
        }

        var sellerHeaderTitle: String? {
            guard let buyer = buyer, let offer = offer, let listing = listing else { return nil }
            let name = buyer.name ?? ""
            let amount = (offer.fees.amount as NSDecimalNumber).doubleValue
            let formattedPrice = currencyHelper.formattedAmountWithCurrencyCode(listing.currency.code, amount: amount)
            let listingName = listing.name ?? listing.nameAuto ?? ""
            return R.Strings.paymentsOfferStatusHeaderLabel(name, formattedPrice, listingName)
        }

        var netAmountText: String? {
            guard let fees = offer?.fees else { return nil }
            let amount = (fees.amount as NSDecimalNumber).doubleValue
            let currency = fees.currency
            return currencyHelper.formattedAmountWithCurrencyCode(currency.code, amount: amount)
        }

        var feeAmountText: String? {
            guard let fees = offer?.fees else { return nil }
            let amount = (fees.serviceFee as NSDecimalNumber).doubleValue
            let currency = fees.currency
            return currencyHelper.formattedAmountWithCurrencyCode(currency.code, amount: amount)
        }

        var grossAmountText: String? {
            guard let fees = offer?.fees else { return nil }
            let amount = (fees.total as NSDecimalNumber).doubleValue
            let currency = fees.currency
            return currencyHelper.formattedAmountWithCurrencyCode(currency.code, amount: amount)
        }

        var feePercentageText: String? {
            guard let fees = offer?.fees else { return nil }
            let percentage = fees.serviceFeePercentage / 100
            return P2PPaymentsOfferStatusViewModel.percentageFormatter.string(from: NSNumber(value: percentage))
        }

        var declineButtonIsHidden: Bool {
            guard case let .sellerInfoLoaded(offer: offer, listing: _, buyer: _) = self else { return true }
            return offer.status != .pending
        }

        var acceptButtonIsHidden: Bool {
            guard case let .sellerInfoLoaded(offer: offer, listing: _, buyer: _) = self else { return true }
            return offer.status != .pending
        }

        var enterCodeButtonIsHidden: Bool {
            guard case let .sellerInfoLoaded(offer: offer, listing: _, buyer: _) = self else { return true }
            return offer.status != .accepted
        }

        var actionButtonTitle: String? {
            guard let offer = offer else { return nil }
            switch offer.status {
            case .accepted:
                return R.Strings.paymentsOfferStatusActionViewCodeButton
            case .pending, .declined, .canceled, .error, .expired:
                return R.Strings.paymentsOfferStatusActionChatButton
            case .completed:
                return nil
            }
        }

        func buyerStepList(actionHandler: ActionHandler?) -> P2PPaymentsOfferStatusStepListState? {
            guard case let .buyerInfoLoaded(offer: offer, listing: listing) = self else { return nil }
            let price = (offer.fees.total as NSDecimalNumber).doubleValue
            return P2PPaymentsOfferStatusStepListState.buyerStepList(status: offer.status,
                                                                     listingPrice: price,
                                                                     currency: listing.currency,
                                                                     withdrawnButtonTapHandler: actionHandler)
        }

        var sellerStepList: P2PPaymentsOfferStatusStepListState? {
            guard case let .sellerInfoLoaded(offer: offer, listing: _, buyer: _) = self else { return nil }
            return P2PPaymentsOfferStatusStepListState.sellerStepList(status: offer.status)
        }
    }
}
