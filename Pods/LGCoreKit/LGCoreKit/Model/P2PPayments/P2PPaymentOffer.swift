import Foundation

public protocol P2PPaymentOffer: BaseModel {
    var buyerId: String { get }
    var sellerId: String { get }
    var listingId: String { get }
    var status: P2PPaymentOfferStatus { get }
    var fees: P2PPaymentOfferFees { get }
    var fundsAvailableDate: Date? { get }
}
