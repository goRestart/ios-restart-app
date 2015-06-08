//
//  NewProductsViewModel.swift
//  LetGo
//
//  Created by AHL on 24/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import Bolts
import LGCoreKit
import Timepiece

@objc protocol NewProductsViewModelDelegate: class {
    
    // Location
    optional func didStartWaitingForLocation()
    optional func didTimeoutWaitingForLocation()
    
    // First load
    func didStartFirstLoad()
    func didSucceedFirstLoadWithItemsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailFirstLoadWithError(error: NSError)
    
    // Refresh
    func didStartRefreshing()
    func didSucceedRefreshingWithItemsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailRefreshingWithError(error: NSError)
    
    // Paging
    func didStartPaging()
    func didSucceedPagingWithItemsAtIndexPaths(indexPaths: [NSIndexPath])
    func didFailPagingWithError(error: NSError)
}

public class NewProductsViewModel: BaseViewModel {
   
    // Constants
    public static let numberOfColumns = 2
    
    private static let cellMinHeight: CGFloat = 160.0
    private static let cellAspectRatio: CGFloat = 210.0 / cellMinHeight
    private static let cellWidth = UIScreen.mainScreen().bounds.size.width * (1 / CGFloat(numberOfColumns))
    
    private static let itemsPagingThresholdPercentage: Float = 0.75    // when we should start asking for a new page
    
    private static let locationRetrievalTimeout: NSTimeInterval = 10    // seconds
    
    // Delegate
    weak var delegate: NewProductsViewModelDelegate?
    
    // Manager & helper
    private var productsManager: ProductsManager
    private var myUserManager: MyUserManager
    private var locationManager: LocationManager
    
    private var shouldUseLocation: Bool
    private var locationRetrievalTimeoutTimer: NSTimer?
    
    // Data
    private var products: NSArray
    
    // Input
    public var queryString: String?
    public var coordinates: LGLocationCoordinates2D?
    public var categoryIds: [Int]?
    public var sortCriteria: ProductSortCriteria?
    public var maxPrice: Int?
    public var minPrice: Int?
    public var userObjectId: String?
    
    // UI
    private(set) var defaultCellSize: CGSize
    
    // MARK: - Lifecycle
    
    public init(productsService: ProductsService = LGProductsService(), shouldUseLocation: Bool = true) {
        // Manager
        self.productsManager = ProductsManager(productsService: productsService)
        self.myUserManager = MyUserManager.sharedInstance
        self.locationManager = LocationManager.sharedInstance

        // Data
        self.products = []
        
        // Input
        self.shouldUseLocation = shouldUseLocation
        
        // UI
        let cellHeight = NewProductsViewModel.cellWidth * NewProductsViewModel.cellAspectRatio
        self.defaultCellSize = CGSizeMake(NewProductsViewModel.cellWidth, cellHeight)
        
        super.init()
    }
    
    override func didSetActive() {
        super.didSetActive()
        
        // NSNotificationCenter: receive location updates
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("didReceiveLocationWithNotification:"), name: LocationManager.didReceiveLocationNotification, object: nil)
    }
    
    override func didSetInactive() {
        super.didSetInactive()
        
        // NSNotificationCenter
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Public methods

    // MARK: > Data
    
    var numberOfProducts: Int {
        return products.count
    }
    
    // MARK: > UI
    
    /**
        Sets which item is currently visible on screen. If it exceeds a threshold then it loads next page, if possible.
    
        :param: index The index of the product currently visible on screen.
    */
    func setVisibleItemIndex(index: Int) {
        let threshold = Int(Float(numberOfProducts) * NewProductsViewModel.itemsPagingThresholdPercentage)
        if index >= threshold {
            retrieveNextPage()
        }
    }
    
    /**
        Returns the size of the cell at the given index path.
    
        :param: index The index of the product.
        :returns: The cell size.
    */
    func sizeForCellAtIndex(index: Int) -> CGSize {
        let product = products.objectAtIndex(index) as! PartialProduct
        if let thumbnailSize = product.thumbnailSize {
            if thumbnailSize.height != 0 && thumbnailSize.width != 0 {
                let thumbFactor = thumbnailSize.height / thumbnailSize.width
                var baseSize = defaultCellSize
                baseSize.height = max(NewProductsViewModel.cellMinHeight, round(baseSize.height * CGFloat(thumbFactor)))
                return baseSize
            }
        }
        return defaultCellSize
    }
    
    public func thumbnailURLForProductAtIndex(index: Int) -> NSURL? {
        return productAtIndex(index).thumbnailURL
    }
    
    public func statusImageNameForProductAtIndex(index: Int) -> String? {
        let product = productAtIndex(index)
        if let status = product.status {
            if status == .Sold {
                return "label_sold"
            }
            else if let createdAt = product.createdAt {
                let now = NSDate()
                if now.timeIntervalSinceDate(createdAt) < 1.day {
                    return "label_new"
                }
            }
        }
        return nil
    }
    
    public func titleForProductAtIndexPath(index: Int) -> String {
        return productAtIndex(index).name.lg_capitalizedWords()
    }
    
    public func priceForProductAtIndex(index: Int) -> String {
        return productAtIndex(index).formattedPrice()
    }
    
    public func distanceForProductAtIndex(index: Int) -> String {
        return productAtIndex(index).formattedDistance()
    }
    
    // MARK: > Requests
    
    /**
        Retrieve the products first page, with the current query parameters.
    
        :returns: If the operation started.
    */
    public func retrieveFirstPage() -> Bool {
        if !productsManager.canRetrieveProducts {
            return false
        }
     
        let didStartRetrieving: Bool
        var params: RetrieveProductsParams = queryParametersWithoutCoordinates()
        
        // If it should use location
        if shouldUseLocation {

            // Then try to add the coordinates to the query
            if let coordinates = queryCoordinates() {
                params.coordinates = coordinates
                didStartRetrieving = retrieveFirstPageWithParams(params)
            }
            // If not possible, then wait for location
            else {
                // Kill the timer, if any
                if locationRetrievalTimeoutTimer != nil {
                    locationRetrievalTimeoutTimer!.invalidate()
                    locationRetrievalTimeoutTimer = nil
                }
                // Notify the delegate
                delegate?.didStartWaitingForLocation?()
                
                // Start the timer
                locationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(NewProductsViewModel.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)
                
                didStartRetrieving = true
            }
        }
        // Otherwise, we can start retrieving
        else {
            didStartRetrieving = retrieveFirstPageWithParams(params)
        }
        
        return didStartRetrieving
    }
    
    /**
        Retrieve the products next page, with the last query parameters.
    
        :returns: If the operation started.
    */
    public func retrieveNextPage() -> Bool {
        if !productsManager.canRetrieveProductsNextPage {
            return false
        }
        
        if let task = productsManager.retrieveProductsNextPage() {
            
            // Notify the delegate
            delegate?.didStartPaging()
            
            task.continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
                if let strongSelf = self {
                    let delegate = strongSelf.delegate
                    
                    // Success
                    if let newProducts = task.result as? NSArray {
                        
                        let currentCount = strongSelf.numberOfProducts

                        // Add the new products
                        strongSelf.products = strongSelf.products.arrayByAddingObjectsFromArray(newProducts as [AnyObject])
                        
                        // Notify the delegate
                        let indexPaths = NewProductsViewModel.indexPathsFromIndex(currentCount, count: newProducts.count)
                        delegate?.didSucceedPagingWithItemsAtIndexPaths(indexPaths)

                    }
                    // Error
                    else {
                        // Notify the delegate
                        let error = task.error ?? NSError(code: .Internal)
                        delegate?.didFailPagingWithError(error)
                    }
                }
                return nil
            }
            return true
        }
        
        return false
    }
    
    // MARK: - Private methods
    
    private func retrieveFirstPageWithParams(params: RetrieveProductsParams) -> Bool {

        if let task = productsManager.retrieveProductsWithParams(params) {
                
                let currentCount = numberOfProducts
                
                // Notify the delegate
                if currentCount > 0 {
                    delegate?.didStartFirstLoad()
                }
                else {
                    delegate?.didStartRefreshing()
                }
                
                task.continueWithBlock { [weak self] (task: BFTask!) -> AnyObject! in
                    if let strongSelf = self {
                        let delegate = strongSelf.delegate
                        
                        // Success
                        if let products = task.result as? NSArray {
                            
                            // Keep track of the new products
                            strongSelf.products = products
                            
                            // Notify the delegate
                            let indexPaths = NewProductsViewModel.indexPathsFromIndex(currentCount, count: products.count)
                            if currentCount > 0 {
                                delegate?.didSucceedFirstLoadWithItemsAtIndexPaths(indexPaths)
                            }
                            else {
                                delegate?.didSucceedRefreshingWithItemsAtIndexPaths(indexPaths)
                            }
                        }
                            // Error
                        else {
                            // Notify the delegate
                            let error = task.error ?? NSError(code: .Internal)
                            if currentCount > 0 {
                                delegate?.didFailFirstLoadWithError(error)
                            }
                            else {
                                delegate?.didFailRefreshingWithError(error)
                            }
                        }
                    }
                    return nil
                }
                return true
        }
        
        return false
    }
    
    /**
        Returns the query parameters w/o coordinates.
        
        :returns: The query parameters w/o coordinates.
    */
    private func queryParametersWithoutCoordinates() -> RetrieveProductsParams {
        var params: RetrieveProductsParams = RetrieveProductsParams()
        params.queryString = queryString
        params.categoryIds = categoryIds
        params.sortCriteria = sortCriteria
        params.maxPrice = maxPrice
        params.minPrice = minPrice
        params.userObjectId = userObjectId
        return params
    }
    
    /**
        Returns the query coordinates, if available.
    
        :returns: Returns the query coordinates, if available.
    */
    private func queryCoordinates() -> LGLocationCoordinates2D? {
        let coords: LGLocationCoordinates2D?
        
        // If we had specified coordinates, then use them
        if let specifiedCoordinates = coordinates {
            coords = specifiedCoordinates
        }
            // Else if, try to use last LocationManager location
        else if let lastKnownLocation = LocationManager.sharedInstance.lastKnownLocation {
            coords = LGLocationCoordinates2D(coordinates: lastKnownLocation.coordinate)
        }
            // Else if, try to use last user saved location
        else if let userCoordinates = MyUserManager.sharedInstance.myUser()?.gpsCoordinates {
            coords = LGLocationCoordinates2D(coordinates: userCoordinates)
        }
        else {
            coords = nil
        }
        
        return coords
    }
    
    // MARK: > NSNotificationCenter
    
    /**
        Called when receiving a new location.
    
        :param: notification The notification that arised this method.
    */
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {
        // If we had a timer running, kill it
        if locationRetrievalTimeoutTimer != nil {
            locationRetrievalTimeoutTimer!.invalidate()
            locationRetrievalTimeoutTimer = nil
        }
        
        // If it should use location and there are no products then retrieve the first page
        if shouldUseLocation && numberOfProducts == 0 {
            retrieveFirstPage()
        }
    }
    
    // MARK: > Timer
    
    /** Called when a location retrieval times out. */
    @objc func locationRetrievalTimedOut() {
        // If coordinates cannot be built then notify the delegate about the timeout
        if queryCoordinates() == nil {
            delegate?.didTimeoutWaitingForLocation?()
        }
    }
    
    // MARK: > Helper
    
    /**
        Returns the product at the given index.
    
        :param: index The index of the product.
        :returns: The product.
    */
    func productAtIndex(index: Int) -> PartialProduct {
        return products.objectAtIndex(index) as! PartialProduct
    }
    
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
