//
//  LGMonetizationRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result

class LGMonetizationRepository : MonetizationRepository {

    let dataSource: MonetizationDataSource


    // MARK: - Lifecycle

    init(dataSource: MonetizationDataSource) {
        self.dataSource = dataSource
    }


    // MARK: - PUblic methods

    func retrieveBumpeableProductInfo(productId: String, completion: BumpeableProductCompletion?) {
        dataSource.retrieveBumpeableProductInfo(productId: productId) { result in
            if let value = result.value {
                completion?(BumpeableProductResult(value: value))
            } else if let error = result.error {
                completion?(BumpeableProductResult(error: RepositoryError(apiError: error)))
            }
        }
    }
}
