public struct SimilarParam {
    
    public let numberOfSimilarContexts: Int

    public init(numberOfSimilarContexts: Int) {
        self.numberOfSimilarContexts = numberOfSimilarContexts
    }
    
    var apiParams: [String : Any] {
        return ["k" : numberOfSimilarContexts]
    }
}
