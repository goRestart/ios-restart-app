//
//  BaseViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

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


public class BaseViewModel {
    
    public var active: Bool = false {
        didSet {
            if oldValue != active {
                didSetActive(active)
            }
        }
    }
    
    // MARK: - Internal methods
    
    internal func didSetActive(active: Bool) {
        
    }
}
