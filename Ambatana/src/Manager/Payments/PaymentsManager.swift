import Foundation
import LGCoreKit
import LGComponents
import Stripe
import PassKit
import Result


protocol PaymentsManager {
    func canMakePayments() -> PaymentCapabilities
    func openPaymentSetup()
    func createPaymentRequestController(_ request: PaymentRequest, completion: @escaping ResultCompletion<String, PaymentRequestError>) -> UIViewController?
}

// MARK: - Types

enum PaymentCapabilities {
    case unavailable
    case notConfigured
    case readyToPay
}

struct PaymentRequest {
    let listingId: String
    let buyerId: String
    let sellerId: String
    let sellerAmount: NSDecimalNumber
    let feeAmount: NSDecimalNumber
    let totalAmount: NSDecimalNumber
    let currency: Currency
    let countryCode: String
}

enum PaymentRequestError: Error {
    case systemCanceled
    case stripeTokenCreationFailed
    case p2pPaymentOfferCreationFailed
}

// MARK: - LGPaymentsManager

final class LGPaymentsManager: PaymentsManager {
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private var paymentRequestListener: PaymentRequestListener?

    convenience init() {
        self.init(p2pPaymentsRepository: Core.p2pPaymentsRepository, config: .defaultConfig)
    }

    init(p2pPaymentsRepository: P2PPaymentsRepository, config: Config) {
        LGPaymentsManager.setup(config: config)
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

    func openPaymentSetup() {
        PKPassLibrary().openPaymentSetup()
    }

    func createPaymentRequestController(_ request: PaymentRequest, completion: @escaping ResultCompletion<String, PaymentRequestError>) -> UIViewController? {
        guard let merchantId = STPPaymentConfiguration.shared().appleMerchantIdentifier else { return nil }
        let paymentRequest = Stripe.paymentRequest(withMerchantIdentifier: merchantId,
                                                   country: request.countryCode,
                                                   currency: request.currency.code)
        paymentRequest.paymentSummaryItems = [
            PKPaymentSummaryItem(label: R.Strings.paymentsPaymentRequestSellerAmountLabel, amount: request.sellerAmount),
            PKPaymentSummaryItem(label: R.Strings.paymentsPaymentRequestFeeLabel, amount: request.feeAmount),
            PKPaymentSummaryItem(label: R.Strings.paymentsPaymentRequestTotalAmountLabel, amount: request.totalAmount),
        ]
        guard let authViewController = createAuthViewController(with: paymentRequest) else { return nil }
        let listener = PaymentRequestListener(paymentRequest: request, p2pPaymentsRepository: p2pPaymentsRepository) { [weak self] result in
            completion(result)
            self?.paymentRequestListener = nil
        }
        authViewController.delegate = listener
        paymentRequestListener = listener
        return authViewController
    }

    private func createAuthViewController(with paymentRequest: PKPaymentRequest) -> PKPaymentAuthorizationViewController? {
        guard Stripe.canSubmitPaymentRequest(paymentRequest) else { return nil }
        guard let authViewController = PKPaymentAuthorizationViewController(paymentRequest: paymentRequest) else { return nil }
        return authViewController
    }
}

// MARK: - Config

extension LGPaymentsManager {
    struct Config {
        let apiKey: String
        let appleMerchantId: String

        static let defaultConfig = Config(apiKey: EnvironmentProxy.sharedInstance.stripeAPIKey,
                                          appleMerchantId: EnvironmentProxy.sharedInstance.appleMerchantId)
    }

    static func setup(config: Config) {
        STPPaymentConfiguration.shared().appleMerchantIdentifier = config.appleMerchantId
        STPPaymentConfiguration.shared().publishableKey = config.apiKey
    }
}
