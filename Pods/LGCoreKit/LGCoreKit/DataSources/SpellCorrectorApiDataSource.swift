import Foundation

final class SpellCorrectorApiDataSource: SpellCorrectorDataSource {
    
    private let apiClient: ApiClient
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    // MARK: - Actions
    
    func retrieveRelaxQuery(query: String,
                            relaxParam: RelaxParam,
                            completion: RelaxDataSourceCompletion?) {
        let request = SpellCorretorRouter.relaxQuery(searchTerm: query, params: relaxParam.apiParams)
        apiClient.request(request, decoder: SpellCorrectorApiDataSource.decoder, completion: completion)
    }
    
    func retrieveSimilarQuery(query: String,
                              similarParam: SimilarParam,
                              completion: SimilarQueryDataSourceCompletion?) {
        let request = SpellCorretorRouter.similarQuery(searchTerm: query,
                                                       params: similarParam.apiParams)
        apiClient.request(request,
                          decoder: SpellCorrectorApiDataSource.decoder,
                          completion: completion)
    }
    
    // MARK: - Decoders
    
    private static func decoder(_ object: Any) -> RelaxQuery? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            return try RelaxQuery.decode(jsonData: data)
        } catch {
            logAndReportParseError(object: object, entity: .relaxQuery, comment: "could not parse String")
        }
        return nil
    }
    
    private static func decoder(_ object: Any) -> SimilarQuery? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else { return nil }
        do {
            return try SimilarQuery.decode(jsonData: data)
        } catch {
            logAndReportParseError(object: object, entity: .similarQuery, comment: "could not parse String")
        }
        return nil
    }
    
    
}
