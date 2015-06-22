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
    func didFailRequestingLocationServices(status: LocationServiceStatus)
    func didTimeoutRetrievingLocation()
    
    func didStartRetrievingFirstPageProducts()
    func didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailRetrievingFirstPageProducts(error: NSError)
    
    func didStartRetrievingNextPageProducts()
    func didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailRetrievingNextPageProducts(error: NSError)
}

class ProductsViewModel: BaseViewModel {
    
    // MARK: - Constants
    private static let columnCount: CGFloat = 2.0
    
    private static let cellMinHeight: CGFloat = 160.0
    private static let cellAspectRatio: CGFloat = 198.0 / cellMinHeight
    private static let cellWidth: CGFloat = UIScreen.mainScreen().bounds.size.width * (1 / columnCount)
    
    private static let itemsPagingThresholdPercentage: Float = 0.7    // when we should start ask for a new page
    
    private static let locationRetrievalTimeout: NSTimeInterval = 10    // seconds
    
    // MARK: - iVars
    // > Delegate
    weak var delegate: ProductsViewModelDelegate?
    
    // > Input
    var queryString: String?
    var coordinates: LGLocationCoordinates2D?
    var categoryIds: [Int]?
    var sortCriteria: ProductSortCriteria?
    var maxPrice: Int?
    var minPrice: Int?
    var userObjectId: String?
    
    // > Manager
    private let productsManager: ProductsManager
    private let myUserManager: MyUserManager
    private let locationManager: LocationManager
    private var locationRetrievalTimeoutTimer: NSTimer?
    
    // > Data
    private var products: NSArray
    private(set) var pageNumber: Int
    
    // > UI
    private(set) var defaultCellSize: CGSize!
    
    // MARK: - Computed iVars
    var numberOfProducts: Int {
        return products.count
    }
    
    var numberOfColumns: Int {
        return Int(ProductsViewModel.columnCount)
    }
    
    var canRetrieveProducts: Bool {
        // If we've valid query coordinates, then ask the products manager about it
        if let coords = queryCoordinates {
            return productsManager.canRetrieveProducts
        }
        
        return false
    }
    
    private var canRetrieveProductsNextPage: Bool {
        return productsManager.canRetrieveProductsNextPage
    }
    
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
            coords = userCoordinates
        }
        else {
            coords = nil
        }
        return coords
    }
    
    // MARK: - Lifecycle
    
    override init() {
        let productsService = LGProductsService()
        self.productsManager = ProductsManager(productsService: productsService)
        self.myUserManager = MyUserManager.sharedInstance
        self.locationManager = LocationManager.sharedInstance
        
        self.products = []
        self.pageNumber = 0
        
        let cellHeight = ProductsViewModel.cellWidth * ProductsViewModel.cellAspectRatio
        self.defaultCellSize = CGSizeMake(ProductsViewModel.cellWidth, cellHeight)
    }
    
    // MARK: > Overriden methods
    
    internal override func didSetActive() {
        super.didSetActive()
        // Observe when receiving new locations and when location services requests fails
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("didReceiveLocationWithNotification:"), name: LocationManager.didReceiveLocationNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("didFailRequestingLocationServicesWithNotification:"), name: LocationManager.didFailRequestingLocationServices, object: nil)

        var shouldCheckLocation = false
        
        // If there are no products, then reload if possible
        if numberOfProducts == 0 {
            // Reload if possible
            if canRetrieveProducts {
                retrieveProductsFirstPage()
            }
            // Otherwise, check location
            else {
                shouldCheckLocation = true
            }
        }
        // If it's not loading, then it should check location
        else if !productsManager.isLoading {
            shouldCheckLocation = true
        }
        
        if shouldCheckLocation {
            // If no location access, then notify the delegate
            let locationStatus = locationManager.locationServiceStatus
            if locationStatus != .Enabled(LocationServicesAuthStatus.Authorized) {
                delegate?.didFailRequestingLocationServices(locationStatus)
            }
                // If we've location access but we don't have a location yet, run a timer
            else if queryCoordinates == nil {
                if locationRetrievalTimeoutTimer != nil {
                    locationRetrievalTimeoutTimer!.invalidate()
                    locationRetrievalTimeoutTimer = nil
                }
                locationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(ProductsViewModel.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)
            }
        }
    }
    
    internal override func didSetInactive() {
        super.didSetInactive()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Internal methods
    
    // MARK: > Requests
    
    /**
        Retrieve the products first page, with the current query parameters.
    
        :returns: If the operation started.
    */
    func retrieveProductsFirstPage() -> Bool {
        
        var operationDidStart: Bool = false
        if let actualCoordinates = queryCoordinates {
            var params: RetrieveProductsParams = RetrieveProductsParams()
            params.coordinates = actualCoordinates
            params.queryString = queryString
            params.categoryIds = categoryIds
            params.sortCriteria = sortCriteria
            params.maxPrice = maxPrice
            params.minPrice = minPrice
            params.userObjectId = userObjectId
            if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
                params.distanceType = usesMetric ? .Km : .Mi
            }
            
            delegate?.didStartRetrievingFirstPageProducts()
            
            let currentCount = numberOfProducts
            
            productsManager.retrieveProductsWithParams(params).continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
                
                if let strongSelf = self {
                    let delegate = strongSelf.delegate
                    
                    // Success
                    if let products = task.result as? NSArray {
                        strongSelf.products = products
                        strongSelf.pageNumber = 0
                        
                        var indexPaths: [NSIndexPath] = ProductsViewModel.indexPathsFromIndex(currentCount, count: products.count)
                        delegate?.didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths)
                    }
                    // Error
                    else if let error = task.error {
                        delegate?.didFailRetrievingFirstPageProducts(error)
                    }
                    else {
                        delegate?.didFailRetrievingFirstPageProducts(NSError(code: LGErrorCode.Internal))
                    }
                }
                return nil
            }
            operationDidStart = true
        }
        return operationDidStart
    }
    
    /**
        Retrieve the products next page, with the last query parameters.
    */
    func retrieveProductsNextPage() {
        
        delegate?.didStartRetrievingNextPageProducts()
        
        let currentCount = numberOfProducts
        
        productsManager.retrieveProductsNextPage().continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
            
            if let strongSelf = self {
                let delegate = strongSelf.delegate
                
                // Success
                if let newProducts = task.result as? NSArray {
                    strongSelf.products = strongSelf.products.arrayByAddingObjectsFromArray(newProducts as [AnyObject])
                    strongSelf.pageNumber++
                    
                    var indexPaths: [NSIndexPath] = ProductsViewModel.indexPathsFromIndex(currentCount, count: newProducts.count)
                    delegate?.didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths)
                }
                    // Error
                else if let error = task.error {
                    delegate?.didFailRetrievingNextPageProducts(error)
                }
                else {
                    delegate?.didFailRetrievingNextPageProducts(NSError(code: LGErrorCode.Internal))
                }
            }
            return nil
        }
    }
    
    // MARK: > UI
    
    /**
        Returns the product at the given index.
    
        :param: index The index of the product.
        :returns: The product.
    */
    func productAtIndex(index: Int) -> Product {
        return products.objectAtIndex(index) as! Product
    }
    
    /**
        Returns the product object id for the product at the given index.
    
        :param: index The index of the product.
        :returns: The product object id.
    */
    func productObjectIdForProductAtIndex(index: Int) -> String? {
        return productAtIndex(index).objectId
    }
    
    /**
        Returns the size of the cell at the given index path.
    
        :param: index The index of the product.
        :returns: The cell size.
    */
    func sizeForCellAtIndex(index: Int) -> CGSize {
        let product = productAtIndex(index)
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
    
    /**
        Sets which item is currently visible on screen. If it exceeds a certain threshold then it loads next page, if possible.
    
        :param: index The index of the product currently visible on screen.
    */
    func setCurrentItemIndex(index: Int) {
        let threshold = Int(Float(numberOfProducts) * ProductsViewModel.itemsPagingThresholdPercentage)
        let shouldRetrieveProductsNextPage = index >= threshold
        if shouldRetrieveProductsNextPage && canRetrieveProductsNextPage {
            retrieveProductsNextPage()
        }
    }
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    /** Called when a new location is received. */
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {
        // If we had a timer running, kill it
        if locationRetrievalTimeoutTimer != nil {
            locationRetrievalTimeoutTimer!.invalidate()
            locationRetrievalTimeoutTimer = nil
        }
        
        // If there are no products then reload if possible
        if numberOfProducts == 0 && canRetrieveProducts {
            retrieveProductsFirstPage()
        }
    }
    
    /** Called when a location services request fails. */
    @objc private func didFailRequestingLocationServicesWithNotification(notification: NSNotification) {
        // no location access, then notify the delegate
        let locationStatus = locationManager.locationServiceStatus
        if locationStatus != .Enabled(LocationServicesAuthStatus.Authorized) {
            delegate?.didFailRequestingLocationServices(locationStatus)
        }
    }
    
    // MARK: > Timer
    
    /** Called when a location retrieval times out. */
    @objc func locationRetrievalTimedOut() {
        if queryCoordinates == nil {
            delegate?.didTimeoutRetrievingLocation()
        }
    }
    
    // MARK: > Helper
    
    /**
        Returns the index paths for the given range.
    
        :param: index Starting index
        :param: count How many items
        :returns: An index paths array.
    */
    private static func indexPathsFromIndex(index: Int, count: Int) -> [NSIndexPath] {
        var indexPaths: [NSIndexPath] = []
        for i in index..<index + count {
            indexPaths.append(NSIndexPath(forItem: i, inSection: 0))
        }
        return indexPaths
    }
}
