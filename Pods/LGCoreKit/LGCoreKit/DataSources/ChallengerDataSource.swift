
protocol ChallengerDataSource {
    
    func indexChallenges(completion: @escaping DataSourceCompletion<[Challenge]>)
}
