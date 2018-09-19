
protocol RewardDatasource {
    
    func retrievePoints(completion: @escaping DataSourceCompletion<RewardPoints>)
    
    func indexRewards(countryCode: String, completion: @escaping DataSourceCompletion<[Reward]>)
    
    func createVoucher(parameters: RewardCreateVoucherParams, completion: @escaping DataSourceCompletion<Void>)
    
    func resendVoucher(voucherId: String, completion: @escaping DataSourceCompletion<Void>)
    
    func indexVouchers(completion: @escaping DataSourceCompletion<[Voucher]>)
}
