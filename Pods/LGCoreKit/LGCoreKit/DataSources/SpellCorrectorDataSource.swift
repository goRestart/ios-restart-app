import Result

typealias RelaxDataSourceResult = Result<RelaxQuery, ApiError>
typealias RelaxDataSourceCompletion = (RelaxResult) -> Void

typealias SimilarQueryDataSourceResult = Result<SimilarQuery, ApiError>
typealias SimilarQueryDataSourceCompletion = (SimilarQueryResult) -> Void

protocol SpellCorrectorDataSource: class {
    func retrieveRelaxQuery(query: String,
                            relaxParam: RelaxParam,
                            completion: RelaxDataSourceCompletion?)
    
    func retrieveSimilarQuery(query: String,
                              similarParam: SimilarParam,
                              completion: SimilarQueryDataSourceCompletion?)
}

