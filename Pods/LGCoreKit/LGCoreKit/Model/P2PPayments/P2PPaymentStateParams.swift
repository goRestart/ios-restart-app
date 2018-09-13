import Foundation

public struct P2PPaymentStateParams {
    public let buyerId: String
    public let sellerId: String
    public let listingId: String
    
    public init(buyerId: String, sellerId: String, listingId: String) {
        self.buyerId = buyerId
        self.sellerId = sellerId
        self.listingId = listingId
    }
}
