
final class RewardApiDataSource: RewardDatasource {
    
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func retrievePoints(completion: @escaping DataSourceCompletion<RewardPoints>) {
        let request = RewardRouter.retrievePoints
        apiClient.request(request, decoder: RewardApiDataSource.rewardPointsDecoder, completion: completion)
    }
    
    func indexRewards(countryCode: String, completion: @escaping DataSourceCompletion<[Reward]>) {
        let request = RewardRouter.indexRewards(countryCode: countryCode)
        apiClient.request(request, decoder: RewardApiDataSource.rewardsDecoder, completion: completion)
    }

    func createVoucher(parameters: RewardCreateVoucherParams, completion: @escaping DataSourceCompletion<Void>) {
        let request = RewardRouter.createVoucher(params: parameters.apiParams)
        apiClient.request(request, completion: completion)
    }
    
    func resendVoucher(voucherId: String, completion: @escaping DataSourceCompletion<Void>) {
        let request = RewardRouter.resendVoucher(voucherId: voucherId)
        apiClient.request(request, completion: completion)
    }
    
    func indexVouchers(completion: @escaping DataSourceCompletion<[Voucher]>) {
        let request = RewardRouter.indexVouchers
        apiClient.request(request, decoder: RewardApiDataSource.vouchersDecoder, completion: completion)
    }
}

// MARK: - Decoders
extension RewardApiDataSource {
    
    private static func rewardPointsDecoder(_ object: Any) -> RewardPoints? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else {
            logAndReportParseError(object: [], entity: .rewardPoints, comment: "Could not parse Reward Points, invalid json.")
            return nil
        }
        do {
            let jsonObject = try JSONDecoder().decode([String:LGRewardPoints].self, from: data)
            return jsonObject["data"]
        }
        catch let exception {
            guard let error = exception as? DecodingError else { return nil }
            logAndReportParseError(object: [], entity: .rewardPoints, comment: "\(error.localizedDescription): \(error)")
            return nil
        }
    }
    
    private static func rewardsDecoder(_ object: Any) -> [Reward] {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else {
            logAndReportParseError(object: [], entity: .reward, comment: "Could not parse Rewards, invalid json.")
            return []
        }
        do {
            let jsonObject = try JSONDecoder().decode([String:FailableDecodableArray<LGReward>].self, from: data)
            return jsonObject["data"]?.validElements ?? []
        }
        catch let exception {
            guard let error = exception as? DecodingError else { return [] }
            logAndReportParseError(object: [], entity: .reward, comment: "\(error.localizedDescription): \(error)")
            return []
        }
    }
    
    private static func vouchersDecoder(_ object: Any) -> [Voucher] {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else {
            logAndReportParseError(object: [], entity: .voucher, comment: "Could not parse Vouchers, invalid json.")
            return []
        }
        do {
            let jsonObject = try JSONDecoder().decode([String:FailableDecodableArray<LGVoucher>].self, from: data)
            return jsonObject["data"]?.validElements ?? []
        }
        catch let exception {
            guard let error = exception as? DecodingError else { return [] }
            logAndReportParseError(object: [], entity: .voucher, comment: "\(error.localizedDescription): \(error)")
            return []
        }
    }
}
