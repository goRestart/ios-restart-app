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
    private var hasChangedRequester: Bool // use it to ask for 1st page of next requester
    private var multiIsLastPage: Bool

    // MARK: - Lifecycle

    convenience init() {
        self.init(requesters: [])
    }

    init(requesters: [ProductListRequester]) {
        self.requestersArray = requesters
        self.currentIndex = 0
        self.activeRequester = requesters[0]
        self.hasChangedRequester = false
        self.multiIsLastPage = false
    }
}

extension ProductListMultiRequester: ProductListRequester {
    func canRetrieve() -> Bool {
        guard let activeRequester = activeRequester else { return false }
        return activeRequester.canRetrieve()
    }

    func retrieveFirstPage(completion: ProductsCompletion?) {
        resetInitialData()
        activeRequester?.retrieveFirstPage { [weak self] result in
            self?.updateLastPage(result)
            completion?(result)
        }
    }

    func retrieveNextPage(completion: ProductsCompletion?) {
        let completionBlock: ProductsCompletion = { [weak self] result in
            self?.updateLastPage(result)
            completion?(result)
        }
        if hasChangedRequester {
            hasChangedRequester = false
            activeRequester?.retrieveFirstPage(completionBlock)
        } else {
            activeRequester?.retrieveNextPage(completionBlock)
        }
    }

    func isLastPage(resultCount: Int) -> Bool {
        return multiIsLastPage
    }

    func updateInitialOffset(newOffset: Int) {
        activeRequester?.updateInitialOffset(newOffset)
    }

    func duplicate() -> ProductListRequester {
        let newArray = requestersArray.map { $0.duplicate() }
        return ProductListMultiRequester(requesters: newArray)
    }


    // MARK: private methods

    private func resetInitialData() {
        currentIndex = 0
        activeRequester = requestersArray[0]
        hasChangedRequester = false
        multiIsLastPage = false
    }

    private func updateLastPage(result: ProductsResult) {
        guard let activeRequester = activeRequester else {
            // if we don't have an active requester, is last page
            multiIsLastPage = true
            return
        }
        guard let resultCount = result.value?.count else { return }
        guard activeRequester.isLastPage(resultCount) else { return }
        multiIsLastPage = switchToNext()
    }

    private func switchToNext() -> Bool {
        // no requesters means last page
        guard requestersArray.count > 0 else { return true }

        currentIndex = currentIndex + 1
        guard currentIndex < requestersArray.count else { return true }

        self.activeRequester = requestersArray[currentIndex]
        hasChangedRequester = true

        return false
    }
}
