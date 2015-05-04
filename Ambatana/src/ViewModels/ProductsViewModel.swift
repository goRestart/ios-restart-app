//
//  ProductsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Bolts
import LGCoreKit

protocol ProductsViewModelDelegate: class {
    func didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailRetrievingFirstPageProducts(error: NSError)
    
    func didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailRetrievingNextPageProducts(error: NSError)
}

class ProductsViewModel {
    
    // Manager
    private let productsManager: ProductsManager
    
    // iVars
    private var products: NSArray
    var numberOfProducts: Int {
        get {
            return products.count
        }
    }
    
    weak var delegate: ProductsViewModelDelegate?
    
    // MARK: - Lifecycle
    
    init() {
        let sessionManager = SessionManager.sharedInstance
        let productsService = LGProductsService()
        self.productsManager = ProductsManager(sessionManager: sessionManager, productsService: productsService)
        self.products = []
    }
    
    // MARK: - Internal methods
    
    func productAtIndex(index: Int) -> PartialProduct {
        return products.objectAtIndex(index) as! PartialProduct
    }
    
    func retrieveProductsWithQueryString(queryString: String?, coordinates: LGLocationCoordinates2D, categoryIds: [Int]?, sortCriteria: ProductSortCriteria?, maxPrice: Int?, minPrice: Int?, userObjectId: String?) {

        let accessToken = SessionManager.sharedInstance.sessionToken?.accessToken ?? ""
        var params = RetrieveProductsParams(coordinates: coordinates, accessToken: accessToken)
        params.queryString = queryString
        params.categoryIds = categoryIds
        params.sortCriteria = sortCriteria
        params.maxPrice = maxPrice
        params.minPrice = minPrice
        params.userObjectId = userObjectId
        
        let currentCount = numberOfProducts
        productsManager.retrieveProductsWithParams(params)?.continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
            
            if let strongSelf = self {
                let delegate = strongSelf.delegate
                                
                // Success
                if task.error == nil {
                    let products = task.result as! NSArray
                    strongSelf.products = products
                    
                    var indexPaths: [NSIndexPath] = ProductsViewModel.indexPathsFromIndex(currentCount, count: products.count)
                    delegate?.didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths)
                }
                // Error
                else {
                    let error = task.error
                    delegate?.didFailRetrievingFirstPageProducts(error)
                }
            }
            return nil
        }
    }
    
    func retrieveProductsNextPage() {

        let currentCount = numberOfProducts
        productsManager.retrieveProductsNextPage()?.continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
            if let strongSelf = self {
                let delegate = strongSelf.delegate
                
                // Success
                if task.error == nil {
                    let newProducts = task.result as! NSArray
                    strongSelf.products = strongSelf.products.arrayByAddingObjectsFromArray(newProducts as [AnyObject])
                    
                    var indexPaths: [NSIndexPath] = ProductsViewModel.indexPathsFromIndex(currentCount, count: newProducts.count)
                    delegate?.didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths)
                }
                // Error
                else {
                    let error = task.error
                    delegate?.didFailRetrievingNextPageProducts(error)
                }
            }
            return nil
        }
    }
    
    // MARK: - Private methods
    
    private static func indexPathsFromIndex(index: Int, count: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        for i in index..<index + count {
            indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
        }
        return indexPaths
    }
}
