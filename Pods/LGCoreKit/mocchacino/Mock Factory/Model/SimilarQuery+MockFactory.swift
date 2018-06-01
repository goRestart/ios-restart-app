//
//  SimilarQuery+MockFactory.swift
//  LGCoreKit
//
//  Created by Haiyan Ma on 28/05/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension SimilarQuery: MockFactory {
    static func makeMock() -> SimilarQuery {
        return SimilarQuery(query: String.makeRandom(),
                            contextual: [String].makeRandom(),
                            jaccard: [String].makeRandom())
    }
}
