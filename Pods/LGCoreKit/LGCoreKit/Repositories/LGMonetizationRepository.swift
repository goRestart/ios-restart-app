//
//  LGMonetizationRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Foundation
import Result
import RxSwift
import RxSwiftExt

class LGMonetizationRepository : MonetizationRepository {

    var events: Observable<MonetizationEvent> {
        return eventBus.asObservable()
    }
    
    private let eventBus = PublishSubject<MonetizationEvent>()
    
    let dataSource: MonetizationDataSource
    let listingsLimboDAO: ListingsLimboDAO

    // MARK: - Lifecycle

    init(dataSource: MonetizationDataSource, listingsLimboDAO: ListingsLimboDAO) {
        self.dataSource = dataSource
        self.listingsLimboDAO = listingsLimboDAO
    }


    // MARK: - Public methods

    func retrieveBumpeableProductInfo(productId: String, completion: BumpeableListingCompletion?) {
        dataSource.retrieveBumpeableProductInfo(productId: productId) { result in
            handleApiResult(result, completion: completion)
        }
    }

    func freeBump(forListingId listingId: String, itemId: String, completion: BumpCompletion?) {
        let paymentId = LGUUID().UUIDString
        dataSource.freeBump(forListingId: listingId, itemId: itemId, paymentId: paymentId) { [weak self] result in
            if let _ = result.value {
                self?.listingsLimboDAO.save(listingId)
                self?.eventBus.onNext(.freeBump(listingId: listingId))
                completion?(BumpResult(value: Void()))
            } else if let error = result.error {
                completion?(BumpResult(error: RepositoryError(apiError: error)))
            }
        }
    }

    func pricedBump(forListingId listingId: String, receiptData: String, itemId: String, itemPrice: String, itemCurrency: String,
                    amplitudeId: String?, appsflyerId: String?, idfa: String?, bundleId: String?,
                    completion: BumpCompletion?) {
        let paymentId = LGUUID().UUIDString
        dataSource.pricedBump(forListingId: listingId, receiptData: receiptData, itemId: itemId, itemPrice: itemPrice,
                              itemCurrency: itemCurrency, paymentId: paymentId, amplitudeId: amplitudeId, appsflyerId: appsflyerId,
                              idfa: idfa, bundleId: bundleId) { [weak self] result in
            if let _ = result.value {
                self?.listingsLimboDAO.save(listingId)
                self?.eventBus.onNext(.pricedBump(listingId: listingId))
                completion?(BumpResult(value: Void()))
            } else if let error = result.error {
                completion?(BumpResult(error: RepositoryError(apiError: error)))
            }
        }
    }
}
