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
    func createBankAccountToken(params: BankAccountParams, completion: @escaping ResultCompletion<String, TokenRequestError>)
    func createCardToken(params: CardParams, completion: @escaping ResultCompletion<String, TokenRequestError>)
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

struct BankAccountParams {
    let routingNumber: String
    let accountNumber: String
    let countryCode: String
    let currency: Currency
}

struct CardParams {
    let name: String
    let number: String
    let expirationMonth: Int
    let expirationYear: Int
    let cvc: String
    let currency: Currency
}

enum TokenRequestError: Error {
    case stripeTokenCreationFailed
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

    func createBankAccountToken(params: BankAccountParams, completion: @escaping ResultCompletion<String, TokenRequestError>) {
        let stripeParams = STPBankAccountParams()
        stripeParams.routingNumber = params.routingNumber
        stripeParams.accountNumber = params.accountNumber
        stripeParams.country = params.countryCode
        stripeParams.currency = params.currency.code
        STPAPIClient.shared().createToken(withBankAccount: stripeParams) { stripeToken, error in
            if error != nil {
                let result = Result<String, TokenRequestError>(error: .stripeTokenCreationFailed)
                completion(result)
            }
            if let stripeToken = stripeToken {
                let result = Result<String, TokenRequestError>(value: stripeToken.tokenId)
                completion(result)
            }
        }
    }

    func createCardToken(params: CardParams, completion: @escaping ResultCompletion<String, TokenRequestError>) {
        let stripeParams = STPCardParams()
        stripeParams.name = params.name
        stripeParams.number = params.number
        stripeParams.expMonth = UInt(params.expirationMonth)
        stripeParams.expYear = UInt(params.expirationYear)
        stripeParams.cvc = params.cvc
        stripeParams.currency = params.currency.code
        STPAPIClient.shared().createToken(withCard: stripeParams) { stripeToken, error in
            if error != nil {
                let result = Result<String, TokenRequestError>(error: .stripeTokenCreationFailed)
                completion(result)
            }
            if let stripeToken = stripeToken {
                let result = Result<String, TokenRequestError>(value: stripeToken.tokenId)
                completion(result)
            }
        }
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
