
struct LGFeedItemPrice: Decodable {
    
    enum PriceFlag: String, Decodable {
        case normal, free, negotiable
    }
    
    let amount: Double
    let currency: String
    let flag: PriceFlag
}

extension LGFeedItemPrice {
    
    static func toListingPrice(price: LGFeedItemPrice) -> ListingPrice {
        let priceValue = price.amount
        switch price.flag {
        case .normal, .negotiable:
            return ListingPrice.normal(priceValue)
        case .free:
            return ListingPrice.free
        }
    }
}
