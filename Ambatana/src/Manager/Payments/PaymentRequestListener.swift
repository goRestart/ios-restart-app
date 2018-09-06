import Foundation
import LGCoreKit
import Stripe
import PassKit
import Result

final class PaymentRequestListener: NSObject, PKPaymentAuthorizationViewControllerDelegate {
    private typealias StripeTokenCreationCompletion = (Result<STPToken, PaymentRequestError>) -> Void

    private let paymentRequest: PaymentRequest
    private let p2pPaymentsRepository: P2PPaymentsRepository
    private let completion: PaymentRequestCompletion
    private var result: Result<String, PaymentRequestError>?

    init(paymentRequest: PaymentRequest,
         p2pPaymentsRepository: P2PPaymentsRepository,
         completion: @escaping PaymentRequestCompletion) {
        self.paymentRequest = paymentRequest
        self.p2pPaymentsRepository = p2pPaymentsRepository
        self.completion = completion
        super.init()
    }

    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController,
                                            didAuthorizePayment payment: PKPayment,
                                            completion: @escaping (PKPaymentAuthorizationStatus) -> Void) {
        createOffer(with: payment) { [weak self] result in
            self?.result = result
            switch result {
            case .success:
                completion(.success)
            case .failure:
                completion(.failure)
            }
        }
    }

    private func createOffer(with payment: PKPayment, completion: @escaping PaymentRequestCompletion) {
        createStripeToken(with: payment) { [weak self] result in
            switch result {
            case .success(let token):
                self?.createP2PPaymentsOffer(with: token, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func createStripeToken(with payment: PKPayment, completion: @escaping StripeTokenCreationCompletion) {
        STPAPIClient.shared().createToken(with: payment) { token, error in
            guard let token = token, error == nil else {
                completion(.failure(.stripeTokenCreationFailed))
                return
            }
            completion(.success(token))
        }
    }

    private func createP2PPaymentsOffer(with token: STPToken, completion: @escaping PaymentRequestCompletion) {
        let params = P2PPaymentCreateOfferParams(listingId: paymentRequest.listingId,
                                                 buyerId: paymentRequest.buyerId,
                                                 sellerId: paymentRequest.sellerId,
                                                 amount: paymentRequest.totalAmount.doubleValue,
                                                 currency: paymentRequest.currency,
                                                 paymentToken: token.tokenId)
        p2pPaymentsRepository.createOffer(params: params) { result in
            switch result {
            case .success(let offerId):
                completion(.success(offerId))
            case .failure:
                completion(.failure(.p2pPaymentOfferCreationFailed))
            }
        }
    }

    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        controller.dismiss(animated: true) { [weak self] in
            guard let result = self?.result else {
                self?.completion(.failure(.systemCanceled))
                return
            }
            self?.completion(result)
        }
    }
}
