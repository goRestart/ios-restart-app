enum P2PPaymentsRouter: URLRequestAuthenticable {

    static let offersUrl = "/api/offers"
    static let offerFeesUrl = "/api/offer-price-breakdown"

    case showOffer(id: String)
    case createOffer(params: P2PPaymentCreateOfferParams)
    case calculateOfferFees(params: P2PPaymentCalculateOfferFeesParams)
    case changeOfferStatus(id: String, status: LGP2PPaymentOffer.Status)

    var endpoint: String {
        switch self {
        case .showOffer, .createOffer, .changeOfferStatus:
            return P2PPaymentsRouter.offersUrl
        case .calculateOfferFees(params: _):
            return P2PPaymentsRouter.offerFeesUrl
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
        }
    }
}
