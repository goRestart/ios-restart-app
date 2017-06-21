//
//  MonetizationRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 27/12/16.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

public typealias BumpeableListingResult = Result<BumpeableListing, RepositoryError>
public typealias BumpeableListingCompletion = (BumpeableListingResult) -> Void

public typealias BumpResult = Result<Void, RepositoryError>
public typealias BumpCompletion = (BumpResult) -> Void

public enum MonetizationEvent: Equatable {
    case freeBump(listingId: String)
    case pricedBump(listingId: String)
}

public func ==(lhs: MonetizationEvent, rhs: MonetizationEvent) -> Bool {
    switch (lhs, rhs) {
    case (.freeBump(let listingIdA), .freeBump(let listingIdB)) where listingIdA == listingIdB: return true
    case (.pricedBump(let listingIdA), .pricedBump(let listingIdB)) where listingIdA == listingIdB: return true
    default: return false
    }
}

public protocol MonetizationRepository {
    
    var events: Observable<MonetizationEvent> { get }
    
    func retrieveBumpeableProductInfo(productId: String, completion: BumpeableListingCompletion?)
    func freeBump(forListingId listingId: String, itemId: String, completion: BumpCompletion?)
    func pricedBump(forListingId listingId: String, receiptData: String, itemId: String, itemPrice: String,
                    itemCurrency: String, amplitudeId: String?, appsflyerId: String?, idfa: String?, bundleId: String?,
                    completion: BumpCompletion?)
}
