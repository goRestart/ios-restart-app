//
//  ProductsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result

protocol ProductsViewModelDelegate: class {
    func viewModel(viewModel: ProductsViewModel, didStartRequestingLocationServices timeout: NSTimeInterval)
    func viewModel(viewModel: ProductsViewModel, didFailRequestingLocationServices status: LocationServiceStatus)
    func viewModel(viewModel: ProductsViewModel, didTimeOutRetrievingLocation timeout: NSTimeInterval)
    func viewModel(viewModel: ProductsViewModel, didRetrieveLocation coordinates: LGLocationCoordinates2D)
}

class ProductsViewModel: BaseViewModel {
    
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
    private let myUserManager: MyUserManager
    private let locationManager: LocationManager
    private var locationRetrievalTimeoutTimer: NSTimer?
    
    // MARK: - Computed iVars
    
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
        self.myUserManager = MyUserManager.sharedInstance
        self.locationManager = LocationManager.sharedInstance        
    }
    
    // MARK: > Overriden methods
    
    internal override func didSetActive() {
        super.didSetActive()
        
        // Observe when receiving new locations and when location services requests fails
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self, selector: Selector("didReceiveLocationWithNotification:"), name: LocationManager.didReceiveLocationNotification, object: nil)
        notificationCenter.addObserver(self, selector: Selector("didFailRequestingLocationServicesWithNotification:"), name: LocationManager.didFailRequestingLocationServices, object: nil)

        // If we've a location, then notify the delegate
        if let coordinates = queryCoordinates {
            delegate?.viewModel(self, didRetrieveLocation: coordinates)
        }
        else {
            // Otherwise, notify the delegate if there's no authorization
            let locationStatus = locationManager.locationServiceStatus
            if locationStatus != .Enabled(LocationServicesAuthStatus.Authorized) {
                delegate?.viewModel(self, didFailRequestingLocationServices: locationStatus)
            }
            // And run a timer for location retrieval
            if locationRetrievalTimeoutTimer != nil {
                locationRetrievalTimeoutTimer!.invalidate()
                locationRetrievalTimeoutTimer = nil
            }
            locationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(ProductsViewModel.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)

        }
//        var shouldCheckLocation = false
//        
//        if let coordinates = queryCoordinates {
//            delegate?.viewModel(self, didRetrieveLocation: coordinates)
//        }
        
//        // If there are no products, then reload if possible
//        if numberOfProducts == 0 {
//            // Reload if possible
//            if canRetrieveProducts {
//                retrieveProductsFirstPage()
//            }
//            // Otherwise, check location
//            else {
//                shouldCheckLocation = true
//            }
//        }
//        // If it's not loading, then it should check location
//        else if !productsManager.isLoading {
//            shouldCheckLocation = true
//        }
//        
//        if shouldCheckLocation {
//            // If no location access, then notify the delegate
//            let locationStatus = locationManager.locationServiceStatus
//            if locationStatus != .Enabled(LocationServicesAuthStatus.Authorized) {
//                delegate?.didFailRequestingLocationServices(locationStatus)
//            }
//                // If we've location access but we don't have a location yet, run a timer
//            else if queryCoordinates == nil {
//                if locationRetrievalTimeoutTimer != nil {
//                    locationRetrievalTimeoutTimer!.invalidate()
//                    locationRetrievalTimeoutTimer = nil
//                }
//                locationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(ProductsViewModel.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)
//            }
//        }
    }
    
    internal override func didSetInactive() {
        super.didSetInactive()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Internal methods
    
    // MARK: > Requests
    
//    /**
//        Retrieve the products first page, with the current query parameters.
//    
//        :returns: If the operation started.
//    */
//    func retrieveProductsFirstPage() -> Bool {
//        
//        var operationDidStart: Bool = false
//        if let actualCoordinates = queryCoordinates {
//            var params: RetrieveProductsParams = RetrieveProductsParams()
//            params.coordinates = actualCoordinates
//            params.queryString = queryString
//            params.categoryIds = categoryIds
//            params.sortCriteria = sortCriteria
//            params.maxPrice = maxPrice
//            params.minPrice = minPrice
//            params.userObjectId = userObjectId
//            if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
//                params.distanceType = usesMetric ? .Km : .Mi
//            }
//            
//            delegate?.didStartRetrievingFirstPageProducts()
//            
//            let currentCount = numberOfProducts
//            
//            let myResult = { [weak self] (result: Result<ProductsResponse, ProductsRetrieveServiceError>) -> Void in
//                if let strongSelf = self {
//                    let delegate = strongSelf.delegate
//                    
//                    // Success
//                    if let productsResponse = result.value {
//                        let products = productsResponse.products
//                        strongSelf.products = products
//                        strongSelf.pageNumber = 0
//                        
//                        var indexPaths: [NSIndexPath] = ProductsViewModel.indexPathsFromIndex(currentCount, count: products.count)
//                        delegate?.didSucceedRetrievingFirstPageProductsAtIndexPaths(indexPaths)
//                    }
//                    // Error
//                    else if let error = result.error {
//                        delegate?.didFailRetrievingFirstPageProducts(error)
//                    }
//                }
//            }
//            operationDidStart = true
//            productsManager.retrieveProductsWithParams(params, result: myResult)
//        }
//        return operationDidStart
//    }
//    
//    /**
//        Retrieve the products next page, with the last query parameters.
//    */
//    func retrieveProductsNextPage() {
//        
//        delegate?.didStartRetrievingNextPageProducts()
//        
//        let currentCount = numberOfProducts
//        
//        let myResult = { [weak self] (result: Result<ProductsResponse, ProductsRetrieveServiceError>) -> Void in
//            if let strongSelf = self {
//                let delegate = strongSelf.delegate
//                
//                // Success
//                if let productsResponse = result.value {
//                    let newProducts = productsResponse.products
//                    strongSelf.products = strongSelf.products.arrayByAddingObjectsFromArray(newProducts as [AnyObject])
//                    strongSelf.pageNumber++
//                    
//                    var indexPaths: [NSIndexPath] = ProductsViewModel.indexPathsFromIndex(currentCount, count: newProducts.count)
//                    delegate?.didSucceedRetrievingNextPageProductsAtIndexPaths(indexPaths)
//                }
//                // Error
//                else if let error = result.error {
//                    delegate?.didFailRetrievingNextPageProducts(error)
//                }
//            }
//        }
//        productsManager.retrieveProductsNextPageWithResult(myResult)
//    }
//    
//    // MARK: > UI
//    
//    /**
//        Returns the product at the given index.
//    
//        :param: index The index of the product.
//        :returns: The product.
//    */
//    func productAtIndex(index: Int) -> Product {
//        return products.objectAtIndex(index) as! Product
//    }
//    
//    /**
//        Returns the product object id for the product at the given index.
//    
//        :param: index The index of the product.
//        :returns: The product object id.
//    */
//    func productObjectIdForProductAtIndex(index: Int) -> String? {
//        return productAtIndex(index).objectId
//    }
//    
//    /**
//        Returns the size of the cell at the given index path.
//    
//        :param: index The index of the product.
//        :returns: The cell size.
//    */
//    func sizeForCellAtIndex(index: Int) -> CGSize {
//        let product = productAtIndex(index)
//        if let thumbnailSize = product.thumbnailSize {
//            if thumbnailSize.height != 0 && thumbnailSize.width != 0 {
//                let thumbFactor = thumbnailSize.height / thumbnailSize.width
//                var baseSize = defaultCellSize
//                baseSize.height = max(ProductsViewModel.cellMinHeight, round(baseSize.height * CGFloat(thumbFactor)))
//                return baseSize
//            }
//        }
//        return defaultCellSize
//    }
//    
//    /**
//        Sets which item is currently visible on screen. If it exceeds a certain threshold then it loads next page, if possible.
//    
//        :param: index The index of the product currently visible on screen.
//    */
//    func setCurrentItemIndex(index: Int) {
//        let threshold = Int(Float(numberOfProducts) * ProductsViewModel.itemsPagingThresholdPercentage)
//        let shouldRetrieveProductsNextPage = index >= threshold
//        if shouldRetrieveProductsNextPage && canRetrieveProductsNextPage {
//            retrieveProductsNextPage()
//        }
//    }
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    /** Called when a new location is received. */
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {
        // If we had a timer running, kill it
        if locationRetrievalTimeoutTimer != nil {
            locationRetrievalTimeoutTimer!.invalidate()
            locationRetrievalTimeoutTimer = nil
        }
        
        // Notify the delegate
        if let coordinates = queryCoordinates {
            delegate?.viewModel(self, didRetrieveLocation: coordinates)
        }
    }
    
    /** Called when a location services request fails. */
    @objc private func didFailRequestingLocationServicesWithNotification(notification: NSNotification) {
        // Notify the delegate
        let status = locationManager.locationServiceStatus
        delegate?.viewModel(self, didFailRequestingLocationServices: status)
    }
    
    // MARK: > Timer
    
    /** Called when a location retrieval times out. */
    @objc func locationRetrievalTimedOut() {
        if queryCoordinates == nil {
            delegate?.viewModel(self, didTimeOutRetrievingLocation: ProductsViewModel.locationRetrievalTimeout)
        }
    }
}
