//
//  MockSpellCorrectorRepository.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 16/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

final class MockSpellCorrectorRepository: SpellCorrectorRepository {

    var relaxResult: RelaxResult = Result<RelaxQuery, ApiError>(value: RelaxQuery.makeMock())
    
    func retrieveRelaxQuery(query: String, relaxParam: RelaxParam, completion: RelaxCompletion?) {
        delay(result: relaxResult, completion: completion)
    }
    
}

