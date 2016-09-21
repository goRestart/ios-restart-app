//
//  MockProductListRequester.swift
//  LetGo
//
//  Created by Dídac on 12/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
@testable import LetGo
import LGCoreKit
import Result

class MockProductListRequester: ProductListRequester {

    var offset: Int
    var canRetrieveItems: Bool
    var requesterResult: ProductsResult?
    private var items: [Product] = []
    private var pageSize: Int

    init(canRetrieve: Bool, offset: Int, pageSize: Int) {
        self.canRetrieveItems = canRetrieve
        self.offset = offset
        self.pageSize = pageSize
    }

    func generateItems(numItems: Int) {
        for _ in 0..<numItems {
            items.append(MockProduct())
        }
    }

    func canRetrieve() -> Bool {
        return canRetrieveItems
    }

    func retrieveFirstPage(completion: ProductsCompletion?) {
        var firstPageItems: [Product] = []
        for i in offset..<offset+pageSize {
            if i < items.count {
                firstPageItems.append(items[i])
            }
        }
        offset = offset + pageSize
        requesterResult = Result(value: firstPageItems)
        performAfterDelayWithCompletion(completion)
    }

    func retrieveNextPage(completion: ProductsCompletion?) {
        var nextPageItems: [Product] = []
        for i in offset..<offset+pageSize {
            if i < items.count {
                nextPageItems.append(items[i])
            }
        }
        offset = offset + pageSize
        requesterResult = Result(value: nextPageItems)
        performAfterDelayWithCompletion(completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount < pageSize
    }

    func updateInitialOffset(newOffset: Int) {
        offset = newOffset
    }

    func duplicate() -> ProductListRequester {
        return self
    }

    private func performAfterDelayWithCompletion(completion: ProductsCompletion?) {
        let delay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.05 * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            completion?(self.requesterResult!)
        }
    }
}
