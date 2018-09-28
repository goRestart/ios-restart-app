
final class LGChallengerRepository: ChallengerRepository {
    
    private let datasource: ChallengerDataSource
    
    init(datasource: ChallengerDataSource) {
        self.datasource = datasource
    }
    
    func indexChallenges(completion: @escaping RepositoryCompletion<[Challenge]>) {
        datasource.indexChallenges() { result in
            handleApiResult(result, completion: completion)
        }
    }
}
