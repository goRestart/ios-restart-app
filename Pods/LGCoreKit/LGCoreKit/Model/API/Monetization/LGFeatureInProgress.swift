public protocol FeatureInProgress {
    var purchaseType: FeaturePurchaseType? { get }
    var secondsSinceLastFeature: TimeInterval { get }
    var featureDuration: TimeInterval { get }
}

struct LGFeatureInProgress: FeatureInProgress, Decodable {
    public let purchaseType: FeaturePurchaseType?
    public let secondsSinceLastFeature: TimeInterval
    public let featureDuration: TimeInterval


    // MARK: Decode

    /*
     {
        "type": integer (1,2,4,5) [bump, boost, 3x, 7x]
        "seconds_since_last_feature": integer (in seconds)
        "feature_duration": integer (in seconds)
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let purchaseTypeValue = try keyedContainer.decode(Int.self, forKey: .type)
        purchaseType = FeaturePurchaseType(rawValue: purchaseTypeValue)
        let secondsSinceLastFeatureValue = try keyedContainer.decode(Int64.self, forKey: .secondsSinceLastFeature)
        secondsSinceLastFeature = TimeInterval(secondsSinceLastFeatureValue)
        let featureDurationValue = try keyedContainer.decode(Int64.self, forKey: .featureDuration)
        featureDuration = TimeInterval(featureDurationValue)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case secondsSinceLastFeature = "seconds_since_last_feature"
        case featureDuration = "feature_duration"
    }
}
