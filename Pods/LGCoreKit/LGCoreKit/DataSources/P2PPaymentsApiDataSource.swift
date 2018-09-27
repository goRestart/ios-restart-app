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

    func getPayCode(offerId: String, completion: P2PPaymentsDataSourcePayCodeCompletion?) {
        let request = P2PPaymentsRouter.getPayCode(offerId: offerId)
        apiClient.request(request, decoder: P2PPaymentsApiDataSource.payCodeDecoder, completion: completion)
    }

    func usePayCode(payCode: String, offerId: String, completion: P2PPaymentsDataSourceEmptyCompletion?) {
        let request = P2PPaymentsRouter.usePayCode(payCode: payCode, offerId: offerId)
        apiClient.request(request, completion: completion)
    }

    func showSeller(id: String, completion: P2PPaymentsDataSourceShowSellerCompletion?) {
        let request = P2PPaymentsRouter.showSeller(id: id)
        apiClient.request(request, decoder: P2PPaymentsApiDataSource.decoder, completion: completion)
    }

    func updateSeller(params: P2PPaymentCreateSellerParams, completion: P2PPaymentsDataSourceEmptyCompletion?) {
        let request = P2PPaymentsRouter.updateSeller(params: params)
        apiClient.request(request, completion: completion)
    }

    func calculatePayoutPriceBreakdown(amount: Decimal, currency: Currency, completion: P2PPaymentsDataSourcePayoutPriceBreakdownCompletion?) {
        let request = P2PPaymentsRouter.calculatePayoutPriceBreakdown(amount: amount, currency: currency)
        apiClient.request(request, decoder: P2PPaymentsApiDataSource.decoder, completion: completion)
    }

    func requestPayout(params: P2PPaymentRequestPayoutParams, completion: P2PPaymentsDataSourceRequestPayoutCompletion?) {
        let request = P2PPaymentsRouter.requestPayout(params: params)
        apiClient.request(request, decoder: P2PPaymentsApiDataSource.payoutDecoder, completion: completion)
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
            let response = try? JSONDecoder().decode(P2PPaymentGetStateResponse.self, from: data) else {
                logAndReportParseError(object: object, entity: .p2pPaymentOfferState, comment: "could not parse P2P payment app state")
                return nil
        }
        return response.asPaymentState()
    }

    fileprivate static func payCodeDecoder(_ object: Any) -> String? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let paymentPayCode = try? JSONDecoder().decode(LGP2PPaymentPayCode.self, from: data) else {
                logAndReportParseError(object: object, entity: .p2pPaymentOfferId, comment: "could not parse P2P payment pay code")
                return nil
        }
        return paymentPayCode.payCode
    }

    fileprivate static func decoder(_ object: Any) -> P2PPaymentSeller? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let paymentSeller = try? JSONDecoder().decode(P2PPaymentSeller.self, from: data) else {
                logAndReportParseError(object: object, entity: .p2pPaymentSeller, comment: "could not parse P2P seller")
                return nil
        }
        return paymentSeller
    }

    fileprivate static func decoder(_ object: Any) -> P2PPaymentPayoutPriceBreakdown? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let priceBreakdown = try? JSONDecoder().decode(P2PPaymentPayoutPriceBreakdown.self, from: data) else {
                logAndReportParseError(object: object, entity: .p2pPaymentPayoutPriceBreakdown, comment: "could not parse P2P payout price breakdown")
                return nil
        }
        return priceBreakdown
    }

    fileprivate static func payoutDecoder(_ object: Any) -> String? {
        guard
            let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted),
            let response = try? JSONDecoder().decode(LGP2PPaymentCreatePayoutResponse.self, from: data),
            response.dataType == .payouts else {
                logAndReportParseError(object: object, entity: .p2pPaymentPayout, comment: "could not parse P2P payment payout")
                return nil
        }
        return response.id
    }
}
