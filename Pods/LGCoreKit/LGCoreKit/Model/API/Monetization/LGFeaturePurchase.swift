
public enum FeaturePurchaseType: Int {
    case bump = 1
    case boost = 2
    case threeDays = 4
    case sevenDays = 5

    public static let allValues: [FeaturePurchaseType] = [.bump, .boost, .threeDays, .sevenDays]
}

public protocol FeaturePurchase {
    var purchaseType: FeaturePurchaseType? { get }
    var featureDuration: TimeInterval { get }
    var provider: PaymentProvider { get }
    var letgoItemId: String { get }
    var providerItemId: String { get }
}

public struct LGFeaturePurchase: FeaturePurchase, Decodable {
    public let purchaseType: FeaturePurchaseType?
    public let featureDuration: TimeInterval
    public let provider: PaymentProvider
    public let letgoItemId: String
    public let providerItemId: String

    public init(purchaseType: FeaturePurchaseType?,
                featureDuration: TimeInterval,
                provider: PaymentProvider,
                letgoItemId: String,
                providerItemId: String) {
        self.purchaseType = purchaseType
        self.featureDuration = featureDuration
        self.provider = provider
        self.letgoItemId = letgoItemId
        self.providerItemId = providerItemId
    }

    // MARK: Decode

    /*
     {
        "type": integer (1,2,4,5) [bump, boost, 3x, 7x]
        "feature_duration": integer (in seconds)
        "provider": string (google|apple|letgo)
        "letgo_item_id": uuid
        "provider_item_id": string (selected tier, ex: google::::com.abtnprojects.ambatana.bumpup.tier2.us)
     }
     */

    public init(from decoder: Decoder) throws {
        let keyedContainer = try decoder.container(keyedBy: CodingKeys.self)
        let purchaseTypeValue = try keyedContainer.decode(Int.self, forKey: .type)
        purchaseType = FeaturePurchaseType(rawValue: purchaseTypeValue)

        let featureDurationValue = try keyedContainer.decode(Int64.self, forKey: .featureDuration)
        featureDuration = TimeInterval(featureDurationValue)

        let providerString = try keyedContainer.decode(String.self, forKey: .provider)
        guard let providerValue = PaymentProvider(rawValue: providerString) else {
            throw DecodingError.valueNotFound(PaymentProvider.self,
                                              DecodingError.Context(codingPath: [],
                                                                    debugDescription: "\(providerString)"))
        }
        provider = providerValue
        letgoItemId = try keyedContainer.decode(String.self, forKey: .letgoItemId)
        providerItemId = try keyedContainer.decode(String.self, forKey: .providerItemId)
    }

    enum CodingKeys: String, CodingKey {
        case type
        case featureDuration = "feature_duration"
        case provider = "provider"
        case letgoItemId = "letgo_item_id"
        case providerItemId = "provider_item_id"
    }
}
