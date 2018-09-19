
final class ChallengerApiDataSource: ChallengerDataSource {
    
    private let apiClient: ApiClient
    
    init(apiClient: ApiClient) {
        self.apiClient = apiClient
    }
    
    func indexChallenges(completion: @escaping DataSourceCompletion<[Challenge]>){
        let request = ChallengerRouter.indexChallenges
        apiClient.request(request, decoder: ChallengerApiDataSource.challengesDecoder, completion: completion)
    }
}

extension ChallengerApiDataSource {
    
    private static func challengesDecoder(_ object: Any) -> [Challenge] {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted) else {
            logAndReportParseError(object: [], entity: .reward, comment: "Could not parse Challenges, invalid json.")
            return []
        }
        do {
            let jsonObject = try JSONDecoder().decode([String:FailableDecodableArray<Challenge>].self, from: data)
            return jsonObject["data"]?.validElements ?? []
        }
        catch let exception {
            guard let error = exception as? DecodingError else { return [] }
            logAndReportParseError(object: [], entity: .reward, comment: "\(error.localizedDescription): \(error)")
            return []
        }
    }
}
