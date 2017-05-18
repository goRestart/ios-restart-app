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

    fileprivate var requestersArray: [ProductListRequester]
    fileprivate var activeRequester: ProductListRequester?
    var currentIndex: Int // not private for testing reasons
    fileprivate var hasChangedRequester: Bool // use it to ask for 1st page of next requester
    var multiIsLastPage: Bool

    var itemsPerPage: Int {
        return activeRequester?.itemsPerPage ?? 0
    }

    var isUsingLastRequester: Bool {
        return currentIndex == requestersArray.count-1
    }


    // var used for UT
    var numOfRequesters: Int {
        return requestersArray.count
    }


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

    func retrieveFirstPage(_ completion: ListingsCompletion?) {
        resetInitialData()
        activeRequester?.retrieveFirstPage { [weak self] result in
            self?.updateLastPage(result)
            completion?(result)
        }
    }

    func retrieveNextPage(_ completion: ListingsCompletion?) {
        let completionBlock: ListingsCompletion = { [weak self] result in

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

    func isLastPage(_ resultCount: Int) -> Bool {
        return multiIsLastPage
    }

    func updateInitialOffset(_ newOffset: Int) {
        activeRequester?.updateInitialOffset(newOffset)
    }

    func duplicate() -> ProductListRequester {
        let newArray = requestersArray.map { $0.duplicate() }
        return ProductListMultiRequester(requesters: newArray)
    }

    func distanceFromProductCoordinates(_ productCoords: LGLocationCoordinates2D) -> Double? {
        return activeRequester?.distanceFromProductCoordinates(productCoords)
    }

    var countryCode: String? {
        return activeRequester?.countryCode
    }

    var requesterTitle: String? {
        return activeRequester?.requesterTitle
    }


    // MARK: private methods

    private func resetInitialData() {
        currentIndex = 0
        activeRequester = requestersArray[0]
        hasChangedRequester = false
        multiIsLastPage = false
    }

    private func updateLastPage(_ result: ListingsResult) {
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

        let newIndex = currentIndex + 1
        guard newIndex < requestersArray.count else { return true }
        currentIndex = newIndex

        self.activeRequester = requestersArray[currentIndex]
        hasChangedRequester = true

        return false
    }
}
