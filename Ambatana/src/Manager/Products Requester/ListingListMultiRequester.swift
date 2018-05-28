//
//  ListingListMultiRequester.swift
//  LetGo
//
//  Created by Dídac on 07/09/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift

class ListingListMultiRequester {

    fileprivate var requestersArray: [ListingListRequester]
    fileprivate var activeRequester: ListingListRequester?
    var currentIndex: Int // not private for testing reasons
    fileprivate var hasChangedRequester: Bool // use it to ask for 1st page of next requester
    var multiIsFirstPage: Bool
    var multiIsLastPage: Bool

    var itemsPerPage: Int {
        return activeRequester?.itemsPerPage ?? 0
    }

    var isUsingLastRequester: Bool {
        return currentIndex == requestersArray.count-1
    }
    
    var isFirstPageInLastRequester: Bool {
        let currentRequester = requestersArray[safeAt: currentIndex]
        let isFirstPage = currentRequester?.isFirstPage ?? false
        return isFirstPage && isUsingLastRequester
    }

    // MARK: - Lifecycle

    convenience init() {
        self.init(requesters: [])
    }

    init(requesters: [ListingListRequester]) {
        self.requestersArray = requesters
        self.currentIndex = 0
        if !requesters.isEmpty {
            self.activeRequester = requesters[0]
        }
        self.hasChangedRequester = false
        self.multiIsLastPage = false
        self.multiIsFirstPage = true
    }
}

extension ListingListMultiRequester: ListingListRequester {

    var isFirstPage: Bool {
        return multiIsFirstPage
    }
    
    func canRetrieve() -> Bool {
        guard let activeRequester = activeRequester else { return false }
        return activeRequester.canRetrieve()
    }

    func retrieveFirstPage(_ completion: ListingsRequesterCompletion?) {
        resetInitialData()
        activeRequester?.retrieveFirstPage { [weak self] result in
            self?.updateLastPage(result)
            completion?(result)
            self?.multiIsFirstPage = false
        }
    }

    func retrieveNextPage(_ completion: ListingsRequesterCompletion?) {
        let completionBlock: ListingsRequesterCompletion = { [weak self] result in

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

    func duplicate() -> ListingListRequester {
        let newArray = requestersArray.map { $0.duplicate() }
        return ListingListMultiRequester(requesters: newArray)
    }

    func isEqual(toRequester requester: ListingListRequester) -> Bool {
        guard let requester = requester as? ListingListMultiRequester else { return false }
        guard requestersArray.count == requester.requestersArray.count else { return false }
        for (index, req) in requester.requestersArray.enumerated() {
            guard requestersArray[index].isEqual(toRequester: req) else { return false }
        }
        return true
    }

    func distanceFromListingCoordinates(_ listingCoords: LGLocationCoordinates2D) -> Double? {
        return activeRequester?.distanceFromListingCoordinates(listingCoords)
    }

    var countryCode: String? {
        return activeRequester?.countryCode
    }
    

    // MARK: private methods

    private func resetInitialData() {
        currentIndex = 0
        activeRequester = requestersArray[0]
        hasChangedRequester = false
        multiIsLastPage = false
        multiIsFirstPage = true
    }

    private func updateLastPage(_ result: ListingsRequesterResult) {
        guard let activeRequester = activeRequester else {
            // if we don't have an active requester, is last page
            multiIsLastPage = true
            return
        }
        guard let resultCount = result.listingsResult.value?.count else { return }
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

