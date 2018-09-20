import Foundation
import Result

final class LGP2PPaymentsRepository: P2PPaymentsRepository {
    private let dataSource: P2PPaymentsDataSource

    // MARK: - Lifecycle

    init(dataSource: P2PPaymentsDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - Public methods

    func createOffer(params: P2PPaymentCreateOfferParams, completion: CreateP2PPaymentOfferCompletion?) {
        dataSource.createOffer(params: params) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams, completion: CalculateP2PPaymentOfferFeesCompletion?) {
        dataSource.calculateOfferFees(params: params) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func showOffer(id: String, completion: ShowP2PPaymentOfferCompletion?) {
        dataSource.showOffer(id: id) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func changeOfferStatus(offerId: String, status: P2PPaymentOfferStatus, completion: ChangeP2PPaymentOfferStatusCompletion?) {
        dataSource.changeOfferStatus(offerId: offerId, status: status) { result in
            handleApiResult(result, completion: completion)
        }
    }
  
    func getPaymentState(params: P2PPaymentStateParams, completion: GetP2PPaymentPaymentStateCompletion?) {
        dataSource.getPaymentState(params: params) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func getPayCode(offerId: String, completion: GetP2PPaymentPayCodeCompletion?) {
        dataSource.getPayCode(offerId: offerId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func usePayCode(payCode: String, offerId: String, completion: UseP2PPaymentPayCodeCompletion?) {
        dataSource.usePayCode(payCode: payCode, offerId: offerId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func showSeller(id: String, completion: ShowP2PPaymentSellerCompletion?) {
        dataSource.showSeller(id: id) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func updateSeller(params: P2PPaymentCreateSellerParams, completion: UpdateP2PPaymentSellerCompletion?) {
        dataSource.updateSeller(params: params) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func calculatePayoutPriceBreakdown(amount: Decimal, currency: Currency, completion: CalculateP2PPaymentPayoutPriceBreakdownCompletion?) {
        dataSource.calculatePayoutPriceBreakdown(amount: amount, currency: currency) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func requestPayout(params: P2PPaymentRequestPayoutParams, completion: RequestP2PPaymentPayoutCompletion?) {
        dataSource.requestPayout(params: params) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
