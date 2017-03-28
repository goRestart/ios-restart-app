//
//  MonetizationRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result

public typealias BumpeableListingResult = Result<BumpeableListing, RepositoryError>
public typealias BumpeableListingCompletion = (BumpeableListingResult) -> Void

public typealias BumpResult = Result<Void, RepositoryError>
public typealias BumpCompletion = (BumpResult) -> Void

public protocol MonetizationRepository {
    func retrieveBumpeableProductInfo(productId: String, completion: BumpeableListingCompletion?)
    func freeBump(forProduct productId: String, itemId: String, completion: BumpCompletion?)
    func pricedBump(forProduct productId: String, receiptData: String, itemId: String, itemPrice: String, itemCurrency: String,
                    completion: BumpCompletion?)
}
