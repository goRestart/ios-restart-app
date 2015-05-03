//
//  ProductsManager.swift
//  LGCoreKit
//
//  Created by AHL on 2/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Bolts

final public class ProductsManager {

    private var sessionManager: SessionManager
    private var productsService: ProductsService
    
    public private(set) var currentParams: RetrieveProductsParams?
    
    public private(set) var products: NSArray
    public private(set) var lastPage: Bool
    
    public private(set) var isLoading: Bool
    
    // MARK: - Lifecycle

    public init(sessionManager: SessionManager, productsService: ProductsService) {
        self.sessionManager = sessionManager
        self.productsService = productsService
        
        self.products = []
        self.lastPage = true
        self.isLoading = false
    }

    // MARK: - Public methods
    
    /**
        Returns if it can retrieve the first page of products.
    
        :returns: If it can retrieve the first page of products. Returns false if already loading.
    */
    public var canRetrieveProducts: Bool {
        get {
            return !isLoading
        }
    }
    
    /**
        Returns if it can retrieve the next page of products.
    
        :returns: If it can retrieve the next page of products. Returns false if already loading, is the last page or
                  we didn't retrieve the first page.
    */
    public var canRetrieveProductsNextPage: Bool {
        get {
            if (isLoading || lastPage || currentParams == nil) {
                return false
            }
            else {
                return true
            }
        }
    }
    
    /**
        Retrieves the products with the given parameters.

        :param: params The parameters to
        :returns: The task that runs the operation. Can be nil, if already loading.
    */
    public func retrieveProductsWithParams(params: RetrieveProductsParams) -> BFTask? {
        if !canRetrieveProducts {
            return nil
        }
        
        // Initial state
        products = []
        lastPage = true
        isLoading = true
        
        // If the session is valid, just retrieve the products
        if sessionManager.isSessionValid() {
            return retrieveProductsTaskWithParams(params)
        }
        // Otherwise, retrieve the session token and then the products
        else {
            return sessionManager.retrieveSessionToken().continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
                if let strongSelf = self {
                    if task.error != nil {
                        strongSelf.isLoading = false
                        return nil
                    }
                    return strongSelf.retrieveProductsTaskWithParams(params)
                }
                return nil
            }
        }
    }
    
    /**
        Retrieves the next products page.

        :returns: The task that runs the operation. Can be nil, if already loading, we didn't request the first page 
                  or we're already in the last page.
    */
    public func retrieveProductsNextPage() -> BFTask? {
        if !canRetrieveProductsNextPage {
            return nil
        }
        
        isLoading = true
        
        // If the session is valid, just retrieve the products
        if sessionManager.isSessionValid() {
            return retrieveProductsNextPageTask()
        }
        // Otherwise, retrieve the session token and then the products
        else {
            return sessionManager.retrieveSessionToken().continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
                if let strongSelf = self {
                    if task.error != nil {
                        strongSelf.isLoading = false
                        return nil
                    }
                    return strongSelf.retrieveProductsNextPageTask()
                }
                return nil
            }
        }
    }
    
    // MARK: - Private methods
    
    private func retrieveProductsTaskWithParams(params: RetrieveProductsParams) -> BFTask {
        
        var task = BFTaskCompletionSource()
        productsService.retrieveProductsWithParams(params) { [weak self] (products: NSArray?, lastPage: Bool?, error: NSError?) -> Void in
            
            // Manager
            if let strongSelf = self {
                
                strongSelf.isLoading = false
                
                // Success
                if error == nil {
                    strongSelf.currentParams = params
                    
                    if let newProducts = products {
                        strongSelf.products = newProducts
                    }
                    if let newLastPage = lastPage {
                        strongSelf.lastPage = newLastPage
                    }
                }
            }
            
            // Task
            if let actualError = error {
                task.setError(error)
            }
            else if let newProducts = products {
                task.setResult(newProducts)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        
        return task.task
    }
    
    private func retrieveProductsNextPageTask() -> BFTask {
        
        // Increase the offset
        var newParams: RetrieveProductsParams = currentParams!
        newParams.offset = products.count
        
        var task = BFTaskCompletionSource()
        productsService.retrieveProductsWithParams(currentParams!) { [weak self] (products: NSArray?, lastPage: Bool?, error: NSError?) -> Void in
            
            // Manager
            if let strongSelf = self {
                
                strongSelf.isLoading = false
                
                // Error
                if error == nil {
                    strongSelf.currentParams = newParams
                    
                    if let newProducts = products {
                        strongSelf.products = strongSelf.products.arrayByAddingObjectsFromArray(newProducts as [AnyObject])
                    }
                    if let newLastPage = lastPage {
                        strongSelf.lastPage = newLastPage
                    }
                }
                else {
                    println()
                }
            }
            
            // Task
            if let actualError = error {
                task.setError(error)
            }
            else if let newProducts = products {
                task.setResult(newProducts)
            }
            else {
                task.setError(NSError(code: LGErrorCode.Internal))
            }
        }
        
        return task.task
    }
}
