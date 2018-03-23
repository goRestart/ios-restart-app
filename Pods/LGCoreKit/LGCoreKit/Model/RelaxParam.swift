//
//  RelaxParam.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 15/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

public struct RelaxParam {
    public let numberOfRelaxedQueries: Int
    public let generateRelaxedQuery: Bool
    public let includeOrInOriginalQuery: Bool
    
    public init(numberOfRelaxedQueries: Int, generateRelaxedQuery: Bool, includeOrInOriginalQuery: Bool) {
        self.numberOfRelaxedQueries = numberOfRelaxedQueries
        self.generateRelaxedQuery = generateRelaxedQuery
        self.includeOrInOriginalQuery = includeOrInOriginalQuery
    }
    
    var apiParams: [String : Any] {
        return ["k" : numberOfRelaxedQueries,
                "generateRelaxedQuery" : generateRelaxedQuery,
                "includeOrInOriginalQuery" : includeOrInOriginalQuery]
    }
}
