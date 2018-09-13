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
}
