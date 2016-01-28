//
//  Paginable.swift
//  LetGo
//
//  Created by Isaac Roldan on 28/1/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import Foundation

protocol Paginable {
    var nextPage: Int { get }
    var isLastPage: Bool { get }
    var isLoading: Bool { get }
    var thresholdPercentage: Float { get }
    var objectCount: Int { get }
    
    func retrieveFirstPage()
    func retrieveNextPage()
    func retrievePage(page: Int)
    func setCurrentIndex(index: Int)
}

extension Paginable {
    var canRetrieve: Bool {
        return !isLoading
    }
    
    var canRetrieveNextPage: Bool {
        return !isLastPage && !isLoading
    }
    
    func retrieveFirstPage() {
        if canRetrieve {
            retrievePage(1)
        }
    }
    
    func retrieveNextPage() {
        if canRetrieveNextPage {
            retrievePage(nextPage)
        }
    }
    
    func setCurrentIndex(index: Int) {
        let threshold = Int(Float(objectCount) * thresholdPercentage)
        let shouldRetrieveNextPage = index >= threshold
        if shouldRetrieveNextPage {
            retrieveNextPage()
        }
    }
}
