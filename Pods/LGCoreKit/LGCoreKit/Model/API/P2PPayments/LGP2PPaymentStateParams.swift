import Foundation

extension P2PPaymentStateParams {
  var apiParams: [String: Any] {
    return [
      "buyerId": buyerId,
      "sellerId": sellerId,
      "listingId": listingId
    ]
  }
}
