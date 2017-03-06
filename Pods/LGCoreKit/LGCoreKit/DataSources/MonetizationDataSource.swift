//
//  MonetizationDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias MonetizationDataSourceBumpeableProductResult = Result<BumpeableProduct, ApiError>
typealias MonetizationDataSourceBumpeableProductCompletion = (MonetizationDataSourceBumpeableProductResult) -> Void

typealias MonetizationDataSourceBumpResult = Result<Void, ApiError>
typealias MonetizationDataSourceBumpCompletion = (MonetizationDataSourceBumpResult) -> Void

protocol MonetizationDataSource {
    func retrieveBumpeableProductInfo(productId: String, completion: MonetizationDataSourceBumpeableProductCompletion?)
    func freeBump(forProduct productId: String, itemId: String, paymentId: String,
                  completion: MonetizationDataSourceBumpCompletion?)
    func pricedBump(forProduct productId: String, receiptData: String, itemId: String, itemPrice: String, itemCurrency: String,
                    paymentId: String, completion: MonetizationDataSourceBumpCompletion?)
}
