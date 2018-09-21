import LGCoreKit

struct P2PPaymentsTrackingInfo {
    let buyerId: String?
    let listingId: String?
    let sellerId: String?
    let conversationId: String?
    let listingPrice: ListingPrice?
    let listingCurrency: Currency?
    let listingCategory: ListingCategory?
    let offerId: String?
    let offerPrice: Double?
    let offerFee: Double?
    let offerCurrency: Currency?

    var eventParameters: EventParameters {
        var eventParameters = EventParameters()
        eventParameters[.buyerId] = buyerId
        eventParameters[.listingId] = listingId
        eventParameters[.sellerId] = sellerId
        eventParameters[.conversationId] = conversationId
        eventParameters[.listingPrice] = listingPrice?.value
        eventParameters[.listingCurrency] = listingCurrency?.code
        eventParameters[.categoryId] = listingCategory?.rawValue
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
                  listingCategory: nil,
                  offerId: nil,
                  offerPrice: nil,
                  offerFee: nil,
                  offerCurrency: nil)
    }

    init(userId: String, chatConversation: ChatConversation, offerFees: P2PPaymentOfferFees) {
        let otherUserId = chatConversation.interlocutor?.objectId
        let buyerId = chatConversation.amISelling ? otherUserId : userId
        let sellerId = chatConversation.amISelling ? userId : otherUserId
        self.init(buyerId: buyerId,
                  listingId: chatConversation.listing?.objectId,
                  sellerId: sellerId,
                  conversationId: chatConversation.objectId,
                  listingPrice: chatConversation.listing?.price,
                  listingCurrency: chatConversation.listing?.currency,
                  listingCategory: nil,
                  offerId: nil,
                  offerPrice: (offerFees.amount as NSDecimalNumber).doubleValue,
                  offerFee: (offerFees.serviceFee as NSDecimalNumber).doubleValue,
                  offerCurrency: offerFees.currency)
    }

    init(offer: P2PPaymentOffer, listing: Listing) {
        self.init(buyerId: offer.buyerId,
                  listingId: offer.listingId,
                  sellerId: offer.sellerId,
                  conversationId: nil,
                  listingPrice: listing.price,
                  listingCurrency: listing.currency,
                  listingCategory: listing.category,
                  offerId: offer.objectId,
                  offerPrice: (offer.fees.amount as NSDecimalNumber).doubleValue,
                  offerFee: (offer.fees.serviceFee as NSDecimalNumber).doubleValue,
                  offerCurrency: offer.fees.currency)
    }
}
