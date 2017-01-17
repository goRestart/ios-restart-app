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

protocol MonetizationDataSource {
    func retrieveBumpeableProductInfo(productId: String, completion: MonetizationDataSourceBumpeableProductCompletion?)
}
