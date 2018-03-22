//
//  MockRelaxParam.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 16/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension RelaxParam: MockFactory {
    public static func makeMock() -> RelaxParam {
        return RelaxParam(numberOfRelaxedQueries: Int.makeRandom(),
                generateRelaxedQuery: Bool.makeRandom(),
                includeOrInOriginalQuery: Bool.makeRandom())
    }
}
