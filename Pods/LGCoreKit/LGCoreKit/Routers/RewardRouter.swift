import Foundation

enum RewardRouter: URLRequestAuthenticable {
    
    private static let rewardPointsBasePath = "points"
    private static let rewardsBasePath = "store"
    private static let buyVoucherBasePath = "buy"
    private static let voucherBasePath = "vouchers"
    
    case retrievePoints
    case indexRewards(countryCode: String)
    case createVoucher(params: [String : Any])
    case resendVoucher(voucherId: String)
    case indexVouchers
    
    var endpoint: String {
        switch self  {
        case .retrievePoints:
            return RewardRouter.rewardPointsBasePath
        case .indexRewards(let countryCode):
            return RewardRouter.rewardsBasePath + "/" + countryCode
        case .createVoucher:
            return RewardRouter.buyVoucherBasePath
        case .resendVoucher:
            return RewardRouter.voucherBasePath
        case .indexVouchers:
            return RewardRouter.voucherBasePath
        }
    }
    
    var requiredAuthLevel: AuthLevel {
        switch self {
        case .retrievePoints, .indexRewards, .createVoucher, .resendVoucher, .indexVouchers:
            return .user
        }
    }
    
    var reportingBlacklistedApiError: Array<ApiError> { return [.scammer] }
    
    func asURLRequest() throws -> URLRequest {
        switch self {
        case .retrievePoints:
            return try Router<RewardBaseURL>.read(endpoint: endpoint, params: [:]).asURLRequest()
        case .indexRewards:
            return try Router<RewardBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        case .createVoucher(let params):
            return try Router<RewardBaseURL>.create(endpoint: endpoint, params: params, encoding: nil).asURLRequest()
        case .resendVoucher(let voucherId):
            return try Router<RewardBaseURL>.patch(endpoint: endpoint, objectId: voucherId, params: [:], encoding: nil).asURLRequest()
        case .indexVouchers:
            return try Router<RewardBaseURL>.index(endpoint: endpoint, params: [:]).asURLRequest()
        }
    }
}
