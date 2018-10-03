enum P2PPaymentsRouter: URLRequestAuthenticable {

    private static let offersUrl = "/api/offers"
    private static let appStateUrl = "/api/app-state"
    private static let offerFeesUrl = "/api/offer-price-breakdown"
    private static let payCodeUrl = "/api/pay-code/offer"
    private static let sellersUrl = "/api/sellers"
    private static let payoutPriceBreakdownUrl = "/api/payout-stripe-price-breakdown"
    private static let payoutsUrl = "api/payouts"

    case showOffer(id: String)
    case createOffer(params: P2PPaymentCreateOfferParams)
    case calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams)
    case changeOfferStatus(id: String, status: LGP2PPaymentOffer.Status)
    case showAppState(params: P2PPaymentStateParams)
    case getPayCode(offerId: String)
    case usePayCode(payCode: String, offerId: String)
    case showSeller(id: String)
    case updateSeller(params: P2PPaymentCreateSellerParams)
    case calculatePayoutPriceBreakdown(amount: Decimal, currency: Currency)
    case requestPayout(params: P2PPaymentRequestPayoutParams)

    var endpoint: String {
        switch self {
        case .showOffer, .createOffer, .changeOfferStatus:
            return P2PPaymentsRouter.offersUrl
        case .calculateOfferFees(params: _):
            return P2PPaymentsRouter.offerFeesUrl
        case .showAppState(params: _):
          return P2PPaymentsRouter.appStateUrl
        case .getPayCode:
            return P2PPaymentsRouter.payCodeUrl
        case .usePayCode(payCode: _, offerId: let offerId):
            return P2PPaymentsRouter.payCodeUrl + "/\(offerId)/code"
        case .showSeller, .updateSeller:
            return P2PPaymentsRouter.sellersUrl
        case .calculatePayoutPriceBreakdown:
            return P2PPaymentsRouter.payoutPriceBreakdownUrl
        case .requestPayout:
            return P2PPaymentsRouter.payoutsUrl
        }
    }

    var requiredAuthLevel: AuthLevel {
        return .user
    }

    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }

    func asURLRequest() throws -> URLRequest {
        switch self {
        case .showOffer(let id):
            return try Router<P2PPaymentsBaseURL>.show(endpoint: endpoint, objectId: id).asURLRequest()
        case .createOffer(params: let createOfferParams):
            return try Router<P2PPaymentsBaseURL>.create(endpoint: endpoint,
                                                         params: createOfferParams.apiParams,
                                                         encoding: .json).asURLRequest()
        case .calculateOfferFees(let calculateOfferFeesParams):
            return try Router<P2PPaymentsBaseURL>.read(endpoint: endpoint,
                                                       params: calculateOfferFeesParams.apiParams).asURLRequest()
        case .changeOfferStatus(id: let id, status: let status):
            return try Router<P2PPaymentsBaseURL>.patch(endpoint: endpoint,
                                                        objectId: id,
                                                        params: status.apiParams(offerId: id),
                                                        encoding: .json).asURLRequest()
        case .showAppState(let appStateParams):
          return try Router<P2PPaymentsBaseURL>.read(endpoint: endpoint, params: appStateParams.apiParams).asURLRequest()
        case .getPayCode(let offerId):
            return try Router<P2PPaymentsBaseURL>.show(endpoint: endpoint, objectId: offerId).asURLRequest()
        case .usePayCode(payCode: let payCode, offerId: _):
            let params = LGP2PPaymentUsePayCodeParams(payCode: payCode)
            return try Router<P2PPaymentsBaseURL>.patch(endpoint: endpoint,
                                                        objectId: payCode,
                                                        params: params.apiParams,
                                                        encoding: .json).asURLRequest()
        case .showSeller(let id):
            return try Router<P2PPaymentsBaseURL>.show(endpoint: endpoint, objectId: id).asURLRequest()
        case .updateSeller(params: let params):
            return try Router<P2PPaymentsBaseURL>.update(endpoint: endpoint,
                                                         objectId: params.sellerId,
                                                         params: params.apiParams,
                                                         encoding: .json).asURLRequest()
        case .calculatePayoutPriceBreakdown(let amount, let currency):
            let params = LGP2PPaymentCalculatePriceBreakdownParams(amount: amount, currency: currency)
            return try Router<P2PPaymentsBaseURL>.read(endpoint: endpoint,
                                                       params: params.apiParams).asURLRequest()
        case .requestPayout(params: let params):
            return try Router<P2PPaymentsBaseURL>.create(endpoint: endpoint,
                                                         params: params.apiParams,
                                                         encoding: .json).asURLRequest()
        }
    }
}
