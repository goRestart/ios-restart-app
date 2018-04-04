//
//  SpellCorrectorRepository.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 14/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Result

typealias RelaxResult = Result<RelaxQuery, ApiError>
typealias RelaxCompletion = (RelaxResult) -> Void

protocol SpellCorrectorRepository {
    func retrieveRelaxQuery(query: String,
                            relaxParam: RelaxParam,
                            completion: RelaxCompletion?)
}
