enum P2PPaymentsRouter: URLRequestAuthenticable {

    private static let offersUrl = "/api/offers"
    private static let appStateUrl = "/api/app-state"
    private static let offerFeesUrl = "/api/offer-price-breakdown"

    case showOffer(id: String)
    case createOffer(params: P2PPaymentCreateOfferParams)
    case calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams)
    case changeOfferStatus(id: String, status: LGP2PPaymentOffer.Status)
    case showAppState(params: P2PPaymentStateParams)
  
    var endpoint: String {
        switch self {
        case .showOffer, .createOffer, .changeOfferStatus:
            return P2PPaymentsRouter.offersUrl
        case .calculateOfferFees(params: _):
            return P2PPaymentsRouter.offerFeesUrl
        case .showAppState(params: _):
          return P2PPaymentsRouter.appStateUrl
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
        }
    }
}
