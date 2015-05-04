//
//  ProductsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Bolts
import CoreLocation
import LGCoreKit
import Parse

protocol ProductsViewModelDelegate: class {
    func didStartRetrievingFirstPageProducts()
    func didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailRetrievingFirstPageProducts(error: NSError)
    
    func didStartRetrievingNextPageProducts()
    func didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailRetrievingNextPageProducts(error: NSError)
}

class ProductsViewModel {
    
    // Constants
    private static let columnCount: CGFloat = 2.0
    
    private static let cellMinHeight: CGFloat = 160.0
    private static let cellAspectRatio: CGFloat = 210.0 / cellMinHeight
    private static let cellWidth: CGFloat = UIScreen.mainScreen().bounds.size.width * (1 / columnCount)
    
    private static let itemsPagingThresholdPercentage: Float = 0.9    // when we should start ask for a new page
    
    // Manager
    private let productsManager: ProductsManager
    
    // iVars
    private var products: NSArray
    private(set) var defaultCellSize: CGSize!
    
    var numberOfProducts: Int {
        get {
            return products.count
        }
    }
    var numberOfColumns: Int {
        get {
            return Int(ProductsViewModel.columnCount)
        }
    }
    var canRetrieveProducts: Bool {
        get {
            return productsManager.canRetrieveProducts
        }
    }
    var canRetrieveProductsNextPage: Bool {
        get {
            return productsManager.canRetrieveProductsNextPage
        }
    }
    
    // Delegate
    weak var delegate: ProductsViewModelDelegate?
    
    // MARK: - Lifecycle
    
    init() {
        let sessionManager = SessionManager.sharedInstance
        let productsService = LGProductsService()
        self.productsManager = ProductsManager(sessionManager: sessionManager, productsService: productsService)
        self.products = []
        
        let cellHeight = ProductsViewModel.cellWidth * ProductsViewModel.cellAspectRatio
        self.defaultCellSize = CGSizeMake(ProductsViewModel.cellWidth, cellHeight)
    }
    
    // MARK: - Internal methods
    
    func currentLocationCoordinates() -> LGLocationCoordinates2D? {
        
        let currentLocation: LGLocationCoordinates2D?
        if let lastKnownLocation = LGLocationCoordinates2D(coordinates: LocationManager.sharedInstance.lastKnownLocation) {
            currentLocation = lastKnownLocation
        }
        else if let lastRegisteredLocation = LGLocationCoordinates2D(coordinates: LocationManager.sharedInstance.lastRegisteredLocation) {
            currentLocation = lastRegisteredLocation
        }
        else if let userGeoPoint = PFUser.currentUser()?["gpscoords"] as? PFGeoPoint {
            currentLocation = LGLocationCoordinates2D(latitude: userGeoPoint.latitude, longitude: userGeoPoint.longitude)
        }
        else {
            currentLocation = nil
        }

        return currentLocation
    }
    
    func productAtIndex(index: Int) -> PartialProduct {
        return products.objectAtIndex(index) as! PartialProduct
    }
    
    func productObjectIdForProductAtIndex(index: Int) -> String? {
        return productAtIndex(index).objectId
    }
    
    func sizeForCellAtIndex(index: Int) -> CGSize {
        let product = products.objectAtIndex(index) as! PartialProduct
        if let thumbnailSize = product.thumbnailSize {
            if thumbnailSize.height != 0 && thumbnailSize.width != 0 {
                let thumbFactor = thumbnailSize.height / thumbnailSize.width
                var baseSize = defaultCellSize
                baseSize.height = max(ProductsViewModel.cellMinHeight, round(baseSize.height * CGFloat(thumbFactor)))
                return baseSize
            }
        }
        return defaultCellSize
    }
    
    func shouldRetrieveProductsNextPageWhenAtIndex(index: Int) -> Bool {
        let threshold = Int(Float(numberOfProducts) * ProductsViewModel.itemsPagingThresholdPercentage)
        return index >= threshold
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
        
        if let task = productsManager.retrieveProductsWithParams(params) {
            
            delegate?.didStartRetrievingFirstPageProducts()
            
            let currentCount = numberOfProducts
            task.continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
                
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
    }
    
    func retrieveProductsNextPage() {

        if let task = productsManager.retrieveProductsNextPage() {
            
            delegate?.didStartRetrievingNextPageProducts()
            
            let currentCount = numberOfProducts
            task.continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
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
    }
    
    // MARK: - Private methods
    
    // MARK: > Helper
    
    private static func indexPathsFromIndex(index: Int, count: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        for i in index..<index + count {
            indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
        }
        return indexPaths
    }
}
