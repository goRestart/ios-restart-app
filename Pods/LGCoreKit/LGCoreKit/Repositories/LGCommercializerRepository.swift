//
//  LGCommercializerRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


final class LGCommercializerRepository: CommercializerRepository {

    let dataSource: CommercializerDataSource

    // MARK: - Lifecycle

    init(dataSource: CommercializerDataSource) {
        self.dataSource = dataSource
    }


    // MARK: - Public methods

    func index(_ productId: String, completion: CommercializersCompletion?) {
        dataSource.index(productId) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
