public protocol ListingAvailablePurchases {
    var listingId: String { get }
    var purchases: AvailableFeaturePurchases { get }
}

struct LGListingAvailablePurchases: ListingAvailablePurchases {
    public let listingId: String
    public let purchases: AvailableFeaturePurchases

    /*
     {
     "uuid (product_id)":
     {
     "available_purchases": [
     {
     "type": integer (1,2,4,5) [bump, boost, 3x, 7x]
     "feature_duration": integer (in seconds)
     "provider": string (google|apple|letgo)
     "letgo_item_id": uuid
     "provider_item_id": string (selected tier, ex: google::::com.abtnprojects.ambatana.bumpup.tier2.us)
     },
     (...)
     ],
     "feature_in_progress": {
     "type": integer (1,2,4,5) [bump, boost, 3x, 7x]
     "seconds_since_last_feature": integer (in seconds)
     "feature_duration": integer (in seconds)
     }
     },
     (...)
     }
     */

    public init(listingId: String, purchases: AvailableFeaturePurchases) {
        self.listingId = listingId
        self.purchases = purchases
    }
}
