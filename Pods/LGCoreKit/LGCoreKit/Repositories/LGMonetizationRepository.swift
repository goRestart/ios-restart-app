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
    let listingsLimboDAO: ListingsLimboDAO

    // MARK: - Lifecycle

    init(dataSource: MonetizationDataSource, listingsLimboDAO: ListingsLimboDAO) {
        self.dataSource = dataSource
        self.listingsLimboDAO = listingsLimboDAO
    }


    // MARK: - PUblic methods

    func retrieveBumpeableProductInfo(productId: String, completion: BumpeableListingCompletion?) {
        dataSource.retrieveBumpeableProductInfo(productId: productId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func freeBump(forProduct productId: String, itemId: String, completion: BumpCompletion?) {
        let paymentId = LGUUID().UUIDString
        dataSource.freeBump(forProduct: productId, itemId: itemId, paymentId: paymentId) { [weak self] result in
            if let _ = result.value {
                self?.listingsLimboDAO.save(productId)
                completion?(BumpResult(value: Void()))
            } else if let error = result.error {
                completion?(BumpResult(error: RepositoryError(apiError: error)))
            }
        }
    }

    func pricedBump(forProduct productId: String, receiptData: String, itemId: String, itemPrice: String, itemCurrency: String,
                    amplitudeId: String?, appsflyerId: String?, idfa: String?, bundleId: String?,
                    completion: BumpCompletion?) {
        let paymentId = LGUUID().UUIDString
        dataSource.pricedBump(forProduct: productId, receiptData: receiptData, itemId: itemId, itemPrice: itemPrice,
                              itemCurrency: itemCurrency, paymentId: paymentId, amplitudeId: amplitudeId, appsflyerId: appsflyerId,
                              idfa: idfa, bundleId: bundleId) { [weak self] result in
            if let _ = result.value {
                self?.listingsLimboDAO.save(productId)
                completion?(BumpResult(value: Void()))
            } else if let error = result.error {
                completion?(BumpResult(error: RepositoryError(apiError: error)))
            }
        }
    }
}
