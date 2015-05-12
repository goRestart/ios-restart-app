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
//    func didStartLoading()
//    func didFailLoading()

//    func didStartRefreshing()
//    func didFailRefreshing()
//    func didSucceedRefreshing()
//    
//    func didStartRetrievingLocation()
//    func didFailRetrievingLocation()
    
    
    
    
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
    private let myUserManager: MyUserManager
    private let locationManager: LocationManager
    
    // iVars
    var active: Bool {
        didSet {
            if active {
                setActive()
            }
            else {
                setInactive()
            }
        }
    }
    
    var canRetrieveProducts: Bool {
        get {
            // If we've valid query coordinates, then ask the products manager about it
            if let coords = queryCoordinates {
                return productsManager.canRetrieveProducts
            }
            
            return false
        }
    }
    
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
    
    // Input
    var queryString: String?
    var coordinates: LGLocationCoordinates2D?
    var categoryIds: [Int]?
    var sortCriteria: ProductSortCriteria?
    var maxPrice: Int?
    var minPrice: Int?
    var userObjectId: String?
    
    // Delegate
    weak var delegate: ProductsViewModelDelegate?
    
    // MARK: - Lifecycle
    
    init() {
        let sessionManager = SessionManager.sharedInstance
        let productsService = LGProductsService()
        self.productsManager = ProductsManager(sessionManager: sessionManager, productsService: productsService)
        self.myUserManager = MyUserManager.sharedInstance
        self.locationManager = LocationManager.sharedInstance
        
        self.products = []
        
        let cellHeight = ProductsViewModel.cellWidth * ProductsViewModel.cellAspectRatio
        self.defaultCellSize = CGSizeMake(ProductsViewModel.cellWidth, cellHeight)

        self.active = false
    }
    
    // MARK: - Internal methods
    
    // MARK: > Requests
    
    func retrieveProductsFirstPage() -> Bool {
        
        let accessToken = SessionManager.sharedInstance.sessionToken?.accessToken ?? ""
        
        // If we had specified coordinates
        let coords: LGLocationCoordinates2D?
        if let specifiedCoordinates = coordinates {
            coords = specifiedCoordinates
        }
            // Else if possible try to use last LocationManager location
        else if let lastKnownLocation = LocationManager.sharedInstance.lastKnownLocation {
            coords = LGLocationCoordinates2D(coordinates: lastKnownLocation.coordinate)
        }
            // Else if possible try to use last user saved location
        else if let userCoordinates = MyUserManager.sharedInstance.myUser()?.gpsCoordinates {
            coords = LGLocationCoordinates2D(coordinates: userCoordinates)
        }
        else {
            coords = nil
        }
        
        if let actualCoordinates = queryCoordinates {
            var params: RetrieveProductsParams = RetrieveProductsParams(coordinates: actualCoordinates, accessToken: accessToken)
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
                return true
            }
        }
        return false
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
    
    // MARK: > Active
    
    func setActive() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveLocationWithNotification:", name: LocationManager.DidReceiveLocationNotification, object: nil)
        if numberOfProducts == 0 {
            retrieveProductsFirstPage()
        }
    }
    
    func setInactive() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: > UI
    
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
    
    func setCurrentItemIndex(index: Int) {
        if shouldRetrieveProductsNextPageWhenAtIndex(index) && canRetrieveProductsNextPage {
            retrieveProductsNextPage()
        }
    }
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {
        // If we don't have specified coordinates, and there are no products the reload
        if coordinates == nil && numberOfProducts == 0 {
            retrieveProductsFirstPage()
        }
    }
    
    // MARK: > Helper
    
    private var queryCoordinates: LGLocationCoordinates2D? {
        let coords: LGLocationCoordinates2D?
        // If we had specified coordinates
        if let specifiedCoordinates = coordinates {
            coords = specifiedCoordinates
        }
            // Else if possible try to use last LocationManager location
        else if let lastKnownLocation = LocationManager.sharedInstance.lastKnownLocation {
            coords = LGLocationCoordinates2D(coordinates: lastKnownLocation.coordinate)
        }
            // Else if possible try to use last user saved location
        else if let userCoordinates = MyUserManager.sharedInstance.myUser()?.gpsCoordinates {
            coords = LGLocationCoordinates2D(coordinates: userCoordinates)
        }
        else {
            coords = nil
        }
        return coords
    }
    
    private static func indexPathsFromIndex(index: Int, count: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        for i in index..<index + count {
            indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
        }
        return indexPaths
    }
    
    private func shouldRetrieveProductsNextPageWhenAtIndex(index: Int) -> Bool {
        let threshold = Int(Float(numberOfProducts) * ProductsViewModel.itemsPagingThresholdPercentage)
        return index >= threshold
    }
    
    private var canRetrieveProductsNextPage: Bool {
        get {
            return productsManager.canRetrieveProductsNextPage
        }
    }
}
