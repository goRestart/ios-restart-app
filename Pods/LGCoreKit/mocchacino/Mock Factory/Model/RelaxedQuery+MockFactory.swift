//
//  RelaxQuery+MockFactory.swift
//  LGCoreKitTests
//
//  Created by Tomas Cobo on 14/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

extension RelaxQuery: MockFactory {
    static func makeMock() -> RelaxQuery {
        return RelaxQuery(query: String.makeRandom(),
                          relaxed: [String].makeRandom(),
                          relaxedQuery: String.makeRandom())
    }
}
