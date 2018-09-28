
public protocol RewardRepository {
    
    /// Returns the number of points of a user needed to buy rewards
    func retrievePoints(completion: @escaping RepositoryCompletion<RewardPoints>)
    
    /// Returns the rewards available to redeem in the store
    func indexRewards(countryCode: String, completion: @escaping RepositoryCompletion<[Reward]>)
    
    /// Buys a voucher
    func createVoucher(parameters: RewardCreateVoucherParams, completion: @escaping RepositoryCompletion<Void>)
    
    /// Returns all the vouchers redeemed
    func indexVouchers(completion: @escaping RepositoryCompletion<[Voucher]>)
    
    /// Requests to resend to the user an already redeemed voucher
    func resendVoucher(voucherId: String, completion: @escaping RepositoryCompletion<Void>)
}

public struct RewardCreateVoucherParams {
    public let rewardId: String
    public let countryCode: String
    
    public init(rewardId: String, countryCode: String) {
        self.rewardId = rewardId
        self.countryCode = countryCode
    }
    
    var apiParams: [String : Any] {
        return [
            "item_id" : rewardId,
            "country_code" : countryCode
        ]
    }
}
