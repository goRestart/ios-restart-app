//
//  MockProductListRequester.swift
//  LetGo
//
//  Created by Dídac on 12/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
@testable import LetGoGodMode
import LGCoreKit
import Result

class MockProductListRequester: ProductListRequester {
    var itemsPerPage: Int
    var offset: Int
    var canRetrieveItems: Bool
    var requesterResult: ListingsResult?
    var items: [Product] = []

    init(canRetrieve: Bool, offset: Int, pageSize: Int) {
        self.canRetrieveItems = canRetrieve
        self.offset = offset
        self.itemsPerPage = pageSize
    }

    func generateItems(_ numItems: Int) {
        for _ in 0..<numItems {
            items.append(MockProduct.makeMock())
        }
    }

    func canRetrieve() -> Bool {
        return canRetrieveItems
    }

    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        var firstPageItems: [Listing] = []
        for i in offset..<offset+itemsPerPage {
            if i < items.count {
                firstPageItems.append(.product(items[i]))
            }
        }
        offset = offset + itemsPerPage
        requesterResult = ListingsResult(value: firstPageItems)
        performAfterDelayWithCompletion(completion)
    }

    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        var nextPageItems: [Listing] = []
        for i in offset..<offset+itemsPerPage {
            if i < items.count {
                nextPageItems.append(.product(items[i]))
            }
        }
        offset = offset + itemsPerPage
        requesterResult = ListingsResult(value: nextPageItems)
        performAfterDelayWithCompletion(completion)
    }

    func isLastPage(_ resultCount: Int) -> Bool {
        return resultCount < itemsPerPage
    }

    func updateInitialOffset(_ newOffset: Int) {
        offset = newOffset
    }

    func duplicate() -> ProductListRequester {
        return self
    }
    func isEqual(toRequester requester: ProductListRequester) -> Bool {
        guard requester is MockProductListRequester else { return false }
        return true
    }
    func distanceFromProductCoordinates(_ productCoords: LGLocationCoordinates2D) -> Double? {
        return nil
    }
    var countryCode: String? {
        return nil
    }

    fileprivate func performAfterDelayWithCompletion(_ completion: ListingsRequesterCompletion?) {
        let delay = DispatchTime.now() + Double(Int64(0.05 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: delay) {
            completion?(ListingsRequesterResult(listingsResult: self.requesterResult!, context: nil))
        }
    }
}
