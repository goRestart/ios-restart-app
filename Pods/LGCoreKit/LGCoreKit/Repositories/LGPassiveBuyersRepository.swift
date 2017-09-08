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

    func show(listingId: String, completion: PassiveBuyersCompletion?) {
        dataSource.show(listingId: listingId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func contactAllBuyers(passiveBuyersInfo: PassiveBuyersInfo, completion: PassiveBuyersEmptyCompletion?) {
        guard let listingId = passiveBuyersInfo.objectId else {
            completion?(PassiveBuyersEmptyResult(error: .internalError(message: "Missing objectId in passiveBuyersInfo")))
            return
        }
        let buyerIds = passiveBuyersInfo.passiveBuyers.flatMap { $0.objectId }
        guard !buyerIds.isEmpty else {
            completion?(PassiveBuyersEmptyResult(error: .internalError(message: "Empty buyerIds in passiveBuyersInfo")))
            return
        }

        dataSource.contact(listingId: listingId, buyerIds: buyerIds) { result in
            handleApiResult(result, completion: completion)
        }
    }
}
