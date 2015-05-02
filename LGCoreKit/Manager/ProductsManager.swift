//
//  ProductsManager.swift
//  LGCoreKit
//
//  Created by AHL on 2/5/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

final public class ProductsManager {

    private var sessionManager: SessionManager
    private var productsService: ProductsService
    
    public private(set) var currentParams: RetrieveProductsParams?
    
    public private(set) var products: [PartialProduct]
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

    public func retrieveProductsWithParams(params: RetrieveProductsParams, completion: RetrieveProductsCompletion) -> Bool {
        if isLoading {
            return false
        }
        
        products = []
        lastPage = true
        isLoading = true
        
        // Store the params so can be reused on next page calls
        currentParams = params
        
        let myCompletion = { [weak self] (products: [PartialProduct]?, lastPage: Bool?, error: LGError?) -> Void in
            if let strongSelf = self {
                // Error
                if let actualError = error {
                    strongSelf.currentParams = nil
                }
                // Success
                else {
                    if let newProducts = products {
                        strongSelf.products = newProducts
                    }
                    if let newLastPage = lastPage {
                        strongSelf.lastPage = newLastPage
                    }
                }
            }
            completion(products: products, lastPage: lastPage, error: error)
        }
        
        productsService.retrieveProductsWithParams(params, completion: myCompletion)
        return true
    }
    
    public func retrieveProductsNextPageWithCompletion(completion: RetrieveProductsCompletion) -> Bool {
        // If loading, is the last page or we didn't retrieve the first page
        if isLoading || lastPage || currentParams == nil {
            return false
        }
        
        isLoading = true
        
        let myCompletion = { [weak self] (products: [PartialProduct]?, lastPage: Bool?, error: LGError?) -> Void in
            if let strongSelf = self {
                // Success
                if error != nil {
                    if let newProducts = products {
                        strongSelf.products += newProducts
                    }
                    if let newLastPage = lastPage {
                        strongSelf.lastPage = newLastPage
                    }
                }
            }
            completion(products: products, lastPage: lastPage, error: error)
        }
        
        return true
    }
    
    // MARK: - Private methods
    
//    private func kk() {
//        let completion = { [weak self] (token: SessionToken?, error: LGError?) -> Void in
//            if let strongSelf = self {
//                
//            }
//            if let actualError = error {
//                
//            }
//        }
//        
//        if sessionManager.isSessionValid() {
//            // go
//        }
//        else {
//            //sessionManager.retrieveSessionTokenWithCompletion(<#completion: RetrieveTokenCompletion?##(token: SessionToken?, error: LGError?) -> Void#>)
//        }
//    }
}
