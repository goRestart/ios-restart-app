import Foundation
import Result

final class P2PPaymentsApiDataSource: P2PPaymentsDataSource {
    private let apiClient: ApiClient

    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }

    // MARK: - Actions

    func showOffer(id: String, completion: P2PPaymentsDataSourceOfferCompletion?) {
        let request = P2PPaymentsRouter.showOffer(id: id)
        apiClient.request(request, decoder: P2PPaymentsApiDataSource.decoder, completion: completion)
    }

    func createOffer(params: P2PPaymentCreateOfferParams, completion: P2PPaymentsDataSourceCreateOfferCompletion?) {
        let request = P2PPaymentsRouter.createOffer(params: params)
        apiClient.request(request, decoder: P2PPaymentsApiDataSource.decoder, completion: completion)
    }

    func calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams, completion: P2PPaymentsDataSourceCalculateOfferFeesCompletion?) {
        let request = P2PPaymentsRouter.calculateOfferFees(params: params)
        apiClient.request(request, decoder: P2PPaymentsApiDataSource.decoder, completion: completion)
    }

    func changeOfferStatus(offerId: String, status: P2PPaymentOfferStatus, completion: P2PPaymentsDataSourceEmptyCompletion?) {
        let request = P2PPaymentsRouter.changeOfferStatus(id: offerId, status: LGP2PPaymentOffer.Status(from: status))
        apiClient.request(request, completion: completion)
    }
    
    func getPaymentState(params: P2PPaymentStateParams, completion: P2PPaymentsDataSourcePaymentStateCompletion?) {
        let request = P2PPaymentsRouter.showAppState(params: params)
        apiClient.request(request, decoder: P2PPaymentsApiDataSource.decoder, completion: completion)
    }
}

extension P2PPaymentsApiDataSource {
    fileprivate static func decoder(_ object: Any) -> String? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let container = try? JSONDecoder().decode(P2PPaymentCreateOfferResponse.Container.self, from: data),
            container.response.type == .offers else {
                logAndReportParseError(object: object, entity: .p2pPaymentOfferId, comment: "could not parse P2P payment offer id")
                return nil
        }
        return container.response.id
    }

    fileprivate static func decoder(_ object: Any) -> P2PPaymentOffer? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let paymentOffer = try? JSONDecoder().decode(LGP2PPaymentOffer.self, from: data) else {
                logAndReportParseError(object: object, entity: .p2pPaymentOfferFees, comment: "could not parse P2P payment offer")
                return nil
        }
        return paymentOffer
    }

    fileprivate static func decoder(_ object: Any) -> P2PPaymentOfferFees? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let container = try? JSONDecoder().decode(LGP2PPaymentOfferFees.Container.self, from: data) else {
                logAndReportParseError(object: object, entity: .p2pPaymentOfferFees, comment: "could not parse P2P payment offer fees")
                return nil
        }
        return container.paymentOfferFees
    }
    
    fileprivate static func decoder(_ object: Any) -> P2PPaymentState? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let container = try? JSONDecoder().decode(P2PPaymentGetStateResponse.Container.self, from: data) else {
                logAndReportParseError(object: object, entity: .p2pPaymentOfferState, comment: "could not parse P2P payment app state")
                return nil
        }
        return container.response.id
    }
}
