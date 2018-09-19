
public protocol ChallengerRepository {
    
    func indexChallenges(completion: @escaping RepositoryCompletion<[Challenge]>)
}
