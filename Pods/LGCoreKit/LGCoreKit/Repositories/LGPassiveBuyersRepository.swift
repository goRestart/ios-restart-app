//
//  LGPassiveBuyersRepository.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 21/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result


final class LGPassiveBuyersRepository: PassiveBuyersRepository {
    let dataSource: PassiveBuyersDataSource

    // MARK: - Lifecycle

    init(dataSource: PassiveBuyersDataSource) {
        self.dataSource = dataSource
    }

    // MARK: - PassiveBuyersRepository

    func show(productId productId: String, completion: PassiveBuyersCompletion?) {
        dataSource.show(productId: productId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func contactAllBuyers(passiveBuyersInfo passiveBuyersInfo: PassiveBuyersInfo, completion: PassiveBuyersEmptyCompletion?) {
        guard let productId = passiveBuyersInfo.objectId else {
            completion?(PassiveBuyersEmptyResult(error: .Internal(message: "Missing objectId in passiveBuyersInfo")))
            return
        }
        let buyerIds = passiveBuyersInfo.passiveBuyers.flatMap { $0.objectId }
        guard !buyerIds.isEmpty else {
            completion?(PassiveBuyersEmptyResult(error: .Internal(message: "Empty buyerIds in passiveBuyersInfo")))
            return
        }

        dataSource.contact(productId: productId, buyerIds: buyerIds) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
