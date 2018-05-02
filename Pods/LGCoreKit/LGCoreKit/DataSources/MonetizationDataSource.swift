//
//  MonetizationDataSource.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

typealias MonetizationDataSourceBumpeableListingResult = Result<BumpeableListing, ApiError>
typealias MonetizationDataSourceBumpeableListingCompletion = (MonetizationDataSourceBumpeableListingResult) -> Void

typealias MonetizationDataSourceBumpResult = Result<Void, ApiError>
typealias MonetizationDataSourceBumpCompletion = (MonetizationDataSourceBumpResult) -> Void

protocol MonetizationDataSource {

    func retrieveBumpeableListingInfo(listingId: String,
                                      completion: MonetizationDataSourceBumpeableListingCompletion?)
    func freeBump(forListingId listingId: String, itemId: String, paymentId: String,
                  completion: MonetizationDataSourceBumpCompletion?)
    func pricedBump(forListingId listingId: String, receiptData: String, itemId: String, itemPrice: String,
                    itemCurrency: String, paymentId: String, letgoItemId: String, amplitudeId: String?,
                    appsflyerId: String?, idfa: String?, bundleId: String?, completion: MonetizationDataSourceBumpCompletion?)
}
