import Result

final class ImageMultiplierApiDataSource: ImageMultiplierDataSource {
    
    private let apiClient: ApiClient
    
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func imageMultiplier(_ parameters: [String : Any], completion: ImageMultiplierDataSourceCompletion?) {
        let request = ImageMultiplierRouter.multipleIds(params: parameters)
        apiClient.request(request, decoder: decoderArray, completion: completion)
    }
    
    private func decoderArray(_ object: Any) -> [String]? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            let imagesIds = try JSONDecoder().decode(FailableDecodableArray<String>.self, from: data)
            return imagesIds.validElements
        } catch {
            logAndReportParseError(object: object, entity: .imagesId, comment: "could not parse [imagesId]")
        }
        return nil
    }
}


