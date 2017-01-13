//
//  Paginable.swift
//  LetGo
//
//  Created by Isaac Roldan on 28/1/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol Paginable {
    var firstPage: Int { get }
    var resultsPerPage: Int { get }
    var nextPage: Int { get }
    var isLastPage: Bool { get }
    var isLoading: Bool { get }
    var thresholdPercentage: Float { get }
    var objectCount: Int { get }

    func retrieveFirstPage()
    func retrieveNextPage()
    func retrievePage(_ page: Int)
    func setCurrentIndex(_ index: Int)
}

extension Paginable {
    
    var resultsPerPage: Int {
        return 20
    }
    
    var thresholdPercentage: Float {
        return 0.7
    }
    
    var canRetrieve: Bool {
        return !isLoading
    }
    
    var canRetrieveNextPage: Bool {
        return !isLastPage && !isLoading
    }
    
    func retrieveFirstPage() {
        if canRetrieve {
            retrievePage(firstPage)
        }
    }
    
    func retrieveNextPage() {
        if canRetrieveNextPage {
            retrievePage(nextPage)
        }
    }
    
    func setCurrentIndex(_ index: Int) {
        let threshold = Int(Float(objectCount) * thresholdPercentage)
        let shouldRetrieveNextPage = index >= threshold
        if shouldRetrieveNextPage {
            retrieveNextPage()
        }
    }
}
