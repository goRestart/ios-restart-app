import LGCoreKit

struct P2PPaymentsTrackingInfo {
    let buyerId: String?
    let listingId: String?
    let sellerId: String?
    let conversationId: String?
    let listingPrice: ListingPrice?
    let listingCurrency: Currency?
    let listingCategoryId: String?
    let offerId: String?
    let offerPrice: Double?
    let offerFee: Double?
    let offerCurrency: Currency?

    var eventParameters: EventParameters {
        var eventParameters = EventParameters()
        eventParameters[.buyerId] = buyerId
        eventParameters[.listingId] = productId
        eventParameters[.sellerId] = sellerId
        eventParameters[.conversationId] = conversationId
        eventParameters[.listingPrice] = listingPrice?.value
        eventParameters[.listingCurrency] = listingCurrency?.code
        eventParameters[.categoryId] = listingCategoryId
        eventParameters[.offerId] = offerId
        eventParameters[.offerPrice] = offerPrice
        eventParameters[.offerFee] = offerFee
        eventParameters[.offerCurrency] = offerCurrency?.code
        return eventParameters
    }
}

extension P2PPaymentsTrackingInfo {
    init(userId: String, chatConversation: ChatConversation) {
        let otherUserId = chatConversation.interlocutor?.objectId
        let buyerId = chatConversation.amISelling ? otherUserId : userId
        let sellerId = chatConversation.amISelling ? userId : otherUserId
        self.init(buyerId: buyerId,
                  listingId: chatConversation.listing?.objectId,
                  sellerId: sellerId,
                  conversationId: chatConversation.objectId,
                  listingPrice: chatConversation.listing?.price,
                  listingCurrency: chatConversation.listing?.currency,
                  listingCategoryId: nil,
                  offerId: nil,
                  offerPrice: nil,
                  offerFee: nil,
                  offerCurrency: nil)
    }
}
