//
//  ProductsManager.swift
//  LGCoreKit
//
//  Created by AHL on 2/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Result

final public class ProductsManager {

    private var productsRetrieveService: ProductsRetrieveService
    private var userProductsRetrieveService: UserProductsRetrieveService
    
    public private(set) var currentParams: RetrieveProductsParams?
    
    public private(set) var products: [Product]
    public private(set) var lastPage: Bool
    
    public private(set) var isLoading: Bool
    
    // MARK: - Lifecycle

    public init(productsRetrieveService: ProductsRetrieveService, userProductsRetrieveService: UserProductsRetrieveService) {
        self.productsRetrieveService = productsRetrieveService
        self.userProductsRetrieveService = userProductsRetrieveService
        
        self.products = []
        self.lastPage = false
        self.isLoading = false
    }

    // MARK: - Public methods
    
    /**
        Returns if it can retrieve the first page of products.
    
        - returns: If it can retrieve the first page of products. Returns false if already loading.
    */
    public var canRetrieveProducts: Bool {
        get {
            return !isLoading
        }
    }
    
    /**
        Returns if it can retrieve the next page of products.
    
        - returns: If it can retrieve the next page of products. Returns false if already loading, is the last page or
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
    
        - parameter params: The product retrieval parameters.
        - parameter result: The result.
    */
    public func retrieveProductsWithParams(params: RetrieveProductsParams, completion: ProductsRetrieveServiceCompletion?)  {
        
        if !canRetrieveProducts {
            completion?(ProductsRetrieveServiceResult(error: .Internal))
            return
        }
        
        // Initial state, but loading
        products = []
        lastPage = false
        isLoading = true
        
        productsRetrieveService.retrieveProductsWithParams(params) { [weak self] (myResult: ProductsRetrieveServiceResult) in
            if let strongSelf = self {
                
                strongSelf.isLoading = false
                
                // Success
                if let response = myResult.value {
                    // Update the params as soon as succeeded, for correct handling in subsequent calls
                    strongSelf.currentParams = params
                    
                    // Assign the new products & keep track if it's last page
                    strongSelf.products = response.products
                    
                    strongSelf.lastPage = response.products.count < 1
                }
                
                completion?(myResult)
            }
        }
    }
    
    /**
        Retrieves the products next page with the previous parameters.
    
        - parameter result: The result.
    */
//    public func retrieveProductsNextPageWithResult(completion: ProductsRetrieveServiceCompletion?) {
    public func retrieveProductsNextPageWithCompletion(completion: ProductsRetrieveServiceCompletion?) {
        
        if !canRetrieveProductsNextPage {
            completion?(ProductsRetrieveServiceResult(error: .Internal))
            return
        }
        
        // Initial state
        isLoading = true
        
        // Increase the offset & override the access token
        var newParams: RetrieveProductsParams = currentParams!
        newParams.offset = products.count
        
        productsRetrieveService.retrieveProductsWithParams(newParams) { [weak self] (myResult: ProductsRetrieveServiceResult) in
            if let strongSelf = self {
                
                strongSelf.isLoading = false
                
                // Success
                if let response = myResult.value {
                    // Update the params as soon as succeeded, for correct handling in subsequent calls
                    strongSelf.currentParams = newParams
                    
                    // Add the new products & keep track if it's last page
                    strongSelf.products += response.products
                    
                    strongSelf.lastPage = response.products.count < 1
                }
                
                completion?(myResult)
            }
        }
    }
    
    /**
        Retrieves the products with the given parameters.
    
        - parameter params: The product retrieval parameters.
        - parameter result: The result.
    */
    public func retrieveUserProductsWithParams(params: RetrieveProductsParams, completion: ProductsRetrieveServiceCompletion?)  {
        
        if !canRetrieveProducts {
            completion?(ProductsRetrieveServiceResult(error: .Internal))
            return
        }
        
        // Initial state
        products = []
        lastPage = true
        isLoading = true
        
        userProductsRetrieveService.retrieveUserProductsWithParams(params) { [weak self] (myResult: ProductsRetrieveServiceResult) in
            if let strongSelf = self {
                
                strongSelf.isLoading = false
                
                // Success
                if let response = myResult.value {
                    // Update the params as soon as succeeded, for correct handling in subsequent calls
                    strongSelf.currentParams = params
                    
                    // Assign the new products & keep track if it's last page
                    strongSelf.products = response.products
                    strongSelf.lastPage = response.products.count < 1
                }
                
                completion?(myResult)
            }
        }
    }
    
    /**
        Retrieves the products next page with the previous parameters.
    
        - parameter result: The result.
    */
//    public func retrieveUserProductsNextPageWithResult(result: ProductsRetrieveServiceResult?) {
    public func retrieveUserProductsNextPageWithCompletion(completion: ProductsRetrieveServiceCompletion?) {
        
        if !canRetrieveProductsNextPage {
            completion?(ProductsRetrieveServiceResult(error: .Internal))
            return
        }
        
        // Initial state
        isLoading = true
        
        // Increase the offset & override the access token
        var newParams: RetrieveProductsParams = currentParams!
        newParams.offset = products.count
        
        userProductsRetrieveService.retrieveUserProductsWithParams(newParams) { [weak self] (myResult: ProductsRetrieveServiceResult) in
            if let strongSelf = self {
                
                strongSelf.isLoading = false
                
                // Success
                if let response = myResult.value {
                    // Update the params as soon as succeeded, for correct handling in subsequent calls
                    strongSelf.currentParams = newParams
                    
                    // Add the new products & keep track if it's last page
                    strongSelf.products += response.products
                    strongSelf.lastPage = response.products.count < 1
                }
                
                completion?(myResult)
            }
        }
    }
}
