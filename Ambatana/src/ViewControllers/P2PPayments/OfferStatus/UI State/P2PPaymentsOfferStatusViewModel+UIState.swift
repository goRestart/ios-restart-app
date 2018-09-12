import Foundation
import LGCoreKit
import LGComponents

extension P2PPaymentsOfferStatusViewModel {
    enum UIState {
        case loading
        case buyerInfoLoaded(offer: P2PPaymentOffer, listing: Listing)
        case sellerInfoLoaded

        var showLoadingIndicator: Bool {
            switch self {
            case .loading: return true
            default: return false
            }
        }

        var showBuyerInfo: Bool {
            switch self {
            case .buyerInfoLoaded: return true
            default: return false
            }
        }

        var showSellerInfo: Bool {
            switch self {
            case .sellerInfoLoaded: return true
            default: return false
            }
        }

        var offer: P2PPaymentOffer? {
            guard case let .buyerInfoLoaded(offer: offer, listing: _) = self else { return nil }
            return offer
        }

        var listing: Listing? {
            guard case let .buyerInfoLoaded(offer: _, listing: listing) = self else { return nil }
            return listing
        }

        var listingTitle: String? {
            return listing?.title
        }

        var listingImageURL: URL? {
            return listing?.thumbnail?.fileURL
        }

        var actionButtonTitle: String? {
            guard let offer = offer else { return nil }
            switch offer.status {
            case .accepted:
                return "View payment code"
            case .pending, .declined, .canceled, .error, .expired:
                return "Chat with Seller"
            case .completed:
                return nil
            }
        }

        func stepList(actionHandler: ActionHandler?) -> P2PPaymentsOfferStatusStepListState? {
            guard case let .buyerInfoLoaded(offer: offer, listing: listing) = self else { return nil }
            let price = (offer.fees.total as NSDecimalNumber).doubleValue
            return P2PPaymentsOfferStatusStepListState.buyerStepList(status: offer.status,
                                                                     listingPrice: price,
                                                                     currency: listing.currency,
                                                                     withdrawnButtonTapHandler: actionHandler)
        }
    }
}
