import Foundation
import Stripe

final class StripeManager {
    static func setup(config: Config) {
        STPPaymentConfiguration.shared().appleMerchantIdentifier = config.appleMerchantId
        STPPaymentConfiguration.shared().publishableKey = config.apiKey
    }
}

// MARK: - Config

extension StripeManager {
    struct Config {
        let apiKey: String
        let appleMerchantId: String
    }
}
