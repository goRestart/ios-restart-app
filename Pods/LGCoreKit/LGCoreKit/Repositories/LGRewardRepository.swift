import Foundation

final class LGRewardRepository: RewardRepository {
    
    private let datasource: RewardDatasource
    
    init(datasource: RewardDatasource) {
        self.datasource = datasource
    }
    
    func retrievePoints(completion:@escaping  RepositoryCompletion<RewardPoints>) {
        datasource.retrievePoints() { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func indexRewards(countryCode: String, completion: @escaping RepositoryCompletion<[Reward]>) {
        datasource.indexRewards(countryCode: countryCode) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func createVoucher(parameters: RewardCreateVoucherParams, completion: @escaping RepositoryCompletion<Void>) {
        datasource.createVoucher(parameters: parameters) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func resendVoucher(voucherId: String, completion: @escaping RepositoryCompletion<Void>) {
        datasource.resendVoucher(voucherId: voucherId) { result in
            handleApiResult(result, completion: completion)
        }
    }
    
    func indexVouchers(completion: @escaping RepositoryCompletion<[Voucher]>) {
        datasource.indexVouchers() { result in
            handleApiResult(result, completion: completion)
        }
    }
}
