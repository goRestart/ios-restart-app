//
//  SpellCorrectorDataSource.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 14/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Result

typealias RelaxDataSourceResult = Result<RelaxQuery, ApiError>
typealias RelaxDataSourceCompletion = (RelaxResult) -> Void

protocol SpellCorrectorDataSource {
    func retrieveRelaxQuery(query: String,
                            relaxParam: RelaxParam,
                            completion: RelaxDataSourceCompletion?)
}
