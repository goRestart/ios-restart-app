import Foundation
import LGCoreKit
import Stripe
import PassKit

enum PaymentCapabilities {
    case unavailable
    case notConfigured
    case readyToPay
}

protocol PaymentsManager {
    func canMakePayments() -> PaymentCapabilities
}

final class LGPaymentsManager: PaymentsManager {
    private let p2pPaymentsRepository: P2PPaymentsRepository

    convenience init() {
        self.init(p2pPaymentsRepository: Core.p2pPaymentsRepository)
    }

    init(p2pPaymentsRepository: P2PPaymentsRepository) {
        self.p2pPaymentsRepository = p2pPaymentsRepository
    }

    func canMakePayments() -> PaymentCapabilities {
        let canMakePayments = PKPaymentAuthorizationViewController.canMakePayments()
        let paymentsAreConfigured = Stripe.deviceSupportsApplePay()
        switch (canMakePayments, paymentsAreConfigured) {
        case (false, _):
            return .unavailable
        case (true, false):
            return .notConfigured
        case (true, true):
            return .readyToPay
        }
    }
}

// MARK: - Config

extension LGPaymentsManager {
    struct Config {
        let apiKey: String
        let appleMerchantId: String
    }

    static func setup(config: Config) {
        STPPaymentConfiguration.shared().appleMerchantIdentifier = config.appleMerchantId
        STPPaymentConfiguration.shared().publishableKey = config.apiKey
    }
}
