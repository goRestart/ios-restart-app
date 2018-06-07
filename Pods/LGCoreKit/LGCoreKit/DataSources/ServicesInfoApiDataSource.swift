import Result

final class ServicesInfoApiDataSource: ServicesInfoDataSource {
    
    let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    
    // MARK: - Public Methods
    
    func index(locale: String?,
               completion: ServicesInfoDataSourceCompletion?) {
        var params: [String: Any] = [:]
        
        if let locale = locale {
            params[ServicesInfoRouter.localeParamKey] = locale
        }
        let request = ServicesInfoRouter.index(params: params)
        apiClient.request(request,
                          decoder: decoder,
                          completion: completion)
    }
    
    
    // MARK: - Decoder
    
    private func decoder(_ object: Any) -> [ServiceType]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        
        do {
            let serviceTypes = try JSONDecoder().decode(FailableDecodableArray<LGServiceType>.self, from: data)
            return serviceTypes.validElements
        } catch {
            logAndReportParseError(object: object,
                                   entity: .serviceType,
                                   comment: "\(error.localizedDescription)")
            return nil
        }
    }
}