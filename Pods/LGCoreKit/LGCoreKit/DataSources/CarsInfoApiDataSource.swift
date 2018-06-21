final class CarsInfoApiDataSource: CarsInfoDataSource {

    let apiClient: ApiClient


    // MARK: - Lifecycle

    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }


    // MARK: - Public Methods
    
    func index(countryCode: String?, completion: CarsInfoDataSourceCompletion?) {
        var params: [String : Any] = [:]
        if let countryCode = countryCode {
            params["countryCode"] = countryCode
        }
        let request = CarsInfoRouter.index(params: params)
        apiClient.request(request, decoder: decoder, completion: completion)
    }


    // MARK: - Decoder

    private func decoder(_ object: Any) -> [CarsMakeWithModels]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        // Ignore cars makes with model that can't be decoded
        do {
            let apiCarsMake = try JSONDecoder().decode(FailableDecodableArray<ApiCarsMake>.self, from: data)
            return apiCarsMake.validElements
        } catch {
            logAndReportParseError(object: object, entity: .carMakes,
                                   comment: "\(error.localizedDescription)")
        }
        return nil
    }
}
