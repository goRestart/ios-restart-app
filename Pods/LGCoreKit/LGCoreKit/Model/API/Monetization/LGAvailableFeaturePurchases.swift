public protocol AvailableFeaturePurchases {
    var availablePurchases: [FeaturePurchase] { get }
    var featureInProgress: FeatureInProgress? { get }
}

public struct LGAvailableFeaturePurchases: AvailableFeaturePurchases, Decodable {

    public let availablePurchases: [FeaturePurchase]
    public let featureInProgress: FeatureInProgress?

    // MARK: Decode

    /*
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
        }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let availablePurchasesValue = try keyedContainer.decode(FailableDecodableArray<LGFeaturePurchase>.self,
                                                                forKey: .availablePurchases).validElements
        availablePurchases = availablePurchasesValue.filter { $0.purchaseType != nil }
        
        featureInProgress = try keyedContainer.decodeIfPresent(LGFeatureInProgress.self,
                                                               forKey: .featureInProgress)
    }

    enum CodingKeys: String, CodingKey {
        case availablePurchases = "available_purchases"
        case featureInProgress = "feature_in_progress"
    }
}
