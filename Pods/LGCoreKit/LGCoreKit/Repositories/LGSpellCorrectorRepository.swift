//
//  LGSpellCorrectorRepository.swift
//  LGCoreKit
//
//  Created by Tomas Cobo on 14/03/2018.
//  Copyright © 2018 Ambatana Inc. All rights reserved.
//

import Foundation

final class LGSpellCorrectorRepository: SpellCorrectorRepository {
    
    private let dataSource: SpellCorrectorDataSource
    
    // MARK: - Lifecycle
    
    init(dataSource: SpellCorrectorDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - Public methods
    
    func retrieveRelaxQuery(query: String,
                            relaxParam: RelaxParam,
                            completion: RelaxCompletion?) {
        dataSource.retrieveRelaxQuery(query: query,
                                      relaxParam: relaxParam,
                                      completion: completion)
    }
    
    func retrieveSimilarQuery(query: String,
                              similarParam: SimilarParam,
                              completion: SimilarQueryCompletion?) {
        dataSource.retrieveSimilarQuery(query: query,
                                        similarParam: similarParam,
                                        completion: completion)
    }
}

