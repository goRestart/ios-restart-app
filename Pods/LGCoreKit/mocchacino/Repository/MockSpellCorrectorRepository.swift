import Result
import RxSwift

final class MockSpellCorrectorRepository: SpellCorrectorRepository {

    var relaxResult: RelaxResult = Result<RelaxQuery, ApiError>(value: RelaxQuery.makeMock())
    var similarResult: SimilarQueryResult = Result<SimilarQuery, ApiError>(value: SimilarQuery.makeMock())
    
    func retrieveRelaxQuery(query: String, relaxParam: RelaxParam, completion: RelaxCompletion?) {
        delay(result: relaxResult, completion: completion)
    }
    
    func retrieveSimilarQuery(query: String, similarParam: SimilarParam, completion: SimilarQueryCompletion?) {
        delay(result: similarResult, completion: completion)
    }
}

