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
        completion?(Result(value: items))
    }

    func retrieveNextPage(completion: ProductsCompletion?) {
        completion?(Result(value: items))
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
}
