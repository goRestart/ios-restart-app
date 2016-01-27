//
//  BaseViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 12/05/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

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
    
    
    // MARK: Pagination
    public var nextPage = 1
    public var isLastPage: Bool = false
    public var isLoading: Bool = false
    
    var canRetrieve: Bool {
        return !isLoading
    }
    
    var canRetrieveNextPage: Bool {
        return !isLastPage && !isLoading
    }
}
