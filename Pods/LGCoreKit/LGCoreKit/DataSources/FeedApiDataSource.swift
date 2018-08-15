
final class FeedApiDataSource: FeedDataSource {
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func index(parameters: FeedIndexParameters, completion: FeedDataSourceCompletion?) {
        let request = FeedRouter.index(countryCode: parameters.countryCode,
                                       locale: parameters.locale,
                                       location: parameters.location,
                                       page: parameters.page,
                                       pageSize: parameters.pageSize,
                                       variant: parameters.variant)
        apiClient.request(request, decoder: FeedApiDataSource.decoder, completion: completion)
    }
    
    func index(page: URL, completion: FeedDataSourceCompletion?) {
        guard let host = page.host, let baseUrlHost = URL(string: FeedBaseURL.baseURL)?.host, host == baseUrlHost
            else {
                let invalidHost = page.host ?? ""
                let description = "\(FeedApiDataSource.self) \(#function): invalid host - \(invalidHost)"
                let result = FeedDataSourceResult(error: ApiError.internalError(description: description))
                completion?(result)
                return
        }
        let request = AbsoluteUrlRequest<FeedBaseURL>(url: page, authLevel: .nonexistent)
        apiClient.request(request, decoder: FeedApiDataSource.decoder, completion: completion)
    }
}

// MARK: - Decoders
extension FeedApiDataSource {
    
    private static func decoder(_ object: Any) -> Feed? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else {
            logAndReportParseError(object: [], entity: .feed, comment: "Could not parse Feed, invalid json.")
            return nil
        }
        do {
            return try JSONDecoder().decode(LGFeed.self, from: data)
        }
        catch let exception {
            guard let error = exception as? DecodingError else { return nil }
            logAndReportParseError(object: [], entity: .feed, comment: "\(error.localizedDescription): \(error)")
            return nil
        }
    }
}
