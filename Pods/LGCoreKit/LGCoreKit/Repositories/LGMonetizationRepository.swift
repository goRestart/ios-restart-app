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
    let productsLimboDAO: ProductsLimboDAO

    // MARK: - Lifecycle

    init(dataSource: MonetizationDataSource, productsLimboDAO: ProductsLimboDAO) {
        self.dataSource = dataSource
        self.productsLimboDAO = productsLimboDAO
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

    func freeBump(forProduct productId: String, itemId: String, completion: BumpCompletion?) {
        let paymentId = LGUUID().UUIDString
        dataSource.freeBump(forProduct: productId, itemId: itemId, paymentId: paymentId) { [weak self] result in
            if let _ = result.value {
                self?.productsLimboDAO.save(productId)
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
                self?.productsLimboDAO.save(productId)
                completion?(BumpResult(value: Void()))
            } else if let error = result.error {
                completion?(BumpResult(error: RepositoryError(apiError: error)))
            }
        }
    }
}
