//
//  ProductListMultiRequester.swift
//  LetGo
//
//  Created by Dídac on 07/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class ProductListMultiRequester {

    private var requestersArray: [ProductListRequester]
    private var activeRequester: ProductListRequester?
    var currentIndex: Int // not private for testing reasons
    private var currentCompletion: ProductsCompletion?

    // MARK: - Lifecycle

    convenience init() {
        self.init(requesters: [])
    }

    init(requesters: [ProductListRequester]) {
        self.requestersArray = requesters
        self.currentIndex = 0
        self.activeRequester = requesters[0]
    }
}

extension ProductListMultiRequester: ProductListRequester {
    func canRetrieve() -> Bool {
        guard let activeRequester = activeRequester else { return false }
        return activeRequester.canRetrieve()
    }

    func retrieveFirstPage(completion: ProductsCompletion?) {
        currentCompletion = completion
        activeRequester?.retrieveFirstPage(completion)
    }

    func retrieveNextPage(completion: ProductsCompletion?) {
        currentCompletion = completion
        activeRequester?.retrieveNextPage(completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        // no requesters mean last page
        guard requestersArray.count > 0 else { return true }
        // if we don't have an active requester, is last page
        guard let activeRequester = activeRequester else { return true }

        guard activeRequester.isLastPage(resultCount) else { return false }

        currentIndex = currentIndex + 1
        guard currentIndex < requestersArray.count else { return true }

        self.activeRequester = requestersArray[currentIndex]

        self.activeRequester?.retrieveFirstPage(currentCompletion)
        return false
    }

    func updateInitialOffset(newOffset: Int) { }

    func duplicate() -> ProductListRequester {
        let newArray = requestersArray.map { $0.duplicate() }
        return ProductListMultiRequester(requesters: newArray)
    }
}
