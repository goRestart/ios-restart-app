//
//  ProductsManager.swift
//  LGCoreKit
//
//  Created by AHL on 2/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Bolts

final public class ProductsManager {

    private var productsService: ProductsService
    
    public private(set) var currentParams: RetrieveProductsParams?
    
    public private(set) var products: NSArray
    public private(set) var lastPage: Bool
    
    public private(set) var isLoading: Bool
    
    // MARK: - Lifecycle

    public init(productsService: ProductsService) {
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
        :returns: The task that runs the operation. If cannot retrieve next page it returns a task with an internal error.
    */
    public func retrieveProductsWithParams(params: RetrieveProductsParams) -> BFTask {
        if !canRetrieveProducts {
            return BFTask(error: NSError(code: LGErrorCode.Internal))
        }
        
        return retrieveProductsTaskWithParams(params)
    }
    
    /**
        Retrieves the next products page.

        :returns: The task that runs the operation. If cannot retrieve next page it returns a task with an internal error.
    */
    public func retrieveProductsNextPage() -> BFTask {
        if !canRetrieveProductsNextPage {
            return BFTask(error: NSError(code: LGErrorCode.Internal))
        }
        
        return retrieveProductsNextPageTask()
    }
    
    // MARK: - Private methods
    
    /**
        Runs & returns the product retrieval task with the given parameters.
    
        :param:   The product retrieval parameters.
        :returns: The product retrieval task.
    */
    private func retrieveProductsTaskWithParams(params: RetrieveProductsParams) -> BFTask {
        
        // Initial state
        products = []
        lastPage = true
        isLoading = true
        
        var task = BFTaskCompletionSource()
        productsService.retrieveProductsWithParams(params) { [weak self] (products: NSArray?, lastPage: Bool?, error: NSError?) -> Void in
            
            // Manager
            if let strongSelf = self {
                
                strongSelf.isLoading = false
                
                // Success
                if error == nil {
                    // Update the params as soon as succeeded, for correct handling in subsequent calls
                    strongSelf.currentParams = params
                    
                    if let newProducts = products {
                        // Assign the new products
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
    
    /**
        Runs & returns the next page product retrieval task with the given parameters.
    
        :returns: The product retrieval task.
    */
    private func retrieveProductsNextPageTask() -> BFTask {
        
        // Initial state
        isLoading = true
        
        // Increase the offset & override the access token
        var newParams: RetrieveProductsParams = currentParams!
        newParams.offset = products.count
        
        var task = BFTaskCompletionSource()
        productsService.retrieveProductsWithParams(newParams) { [weak self] (products: NSArray?, lastPage: Bool?, error: NSError?) -> Void in
            
            // Manager
            if let strongSelf = self {
                
                strongSelf.isLoading = false
                
                // Error
                if error == nil {
                    // Update the params as soon as succeeded, for correct handling in subsequent calls
                    strongSelf.currentParams = newParams
                    
                    if let newProducts = products {
                        // Add the new products
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
