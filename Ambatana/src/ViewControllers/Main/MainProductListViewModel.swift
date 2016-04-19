//
//  MainProductListViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import CoreLocation

public class MainProductListViewModel: ProductListViewModel {

    // Managers, repositories & tracker
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let requester: MainProductListRequester
    private let tracker: Tracker
    
    // Data
    private var lastReceivedLocation: LGLocation?
    private var shouldRetryLoad: Bool
    
    
    // MARK: - Computed iVars
    
    public override var canRetrieveProducts: Bool {
        return super.canRetrieveProducts && requester.queryCoordinates != nil
    }

    public func filteringOrSearching() -> Bool {
        return requester.queryString != nil || requester.hasFilters()
    }
    
    
    // MARK: - Lifecycle
    
    init(requester: MainProductListRequester, locationManager: LocationManager, productRepository: ProductRepository,
        myUserRepository: MyUserRepository, tracker: Tracker) {
            self.locationManager = locationManager
            self.myUserRepository = myUserRepository
        self.requester = requester
            self.tracker = tracker
            self.lastReceivedLocation = locationManager.currentLocation
            self.shouldRetryLoad = false
        super.init(requester: requester, locationManager: locationManager, productRepository: productRepository,
                myUserRepository: myUserRepository, cellDrawer: ProductCellDrawerFactory.drawerForProduct(true))

            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainProductListViewModel.locationUpdate(_:)),
                name: LocationManager.Notification.LocationUpdate.rawValue, object: nil)
    }
    
    convenience init(requester: MainProductListRequester) {
        let locationManager = Core.locationManager
        let productRepository = Core.productRepository
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(requester: requester, locationManager: locationManager, productRepository: productRepository,
            myUserRepository: myUserRepository, tracker: tracker)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    internal override func didSetActive(active: Bool) {
        super.didSetActive(active)

        // Active
        if (active) {
            if let currentLocation = locationManager.currentLocation {
                retrieveProductsIfNeededWithNewLocation(currentLocation)
            }
        }
    }
    
    // MARK: - Public methods

    public func sessionDidChange() {
        guard canRetrieveProducts else {
            shouldRetryLoad = true
            return
        }
        retrieveProductsFirstPage()
    }
    
    public func retrieveProductsFirstPage() {
        // Update before requesting the first page
        super.retrieveProducts()
    }
    
    // MARK: - Internal methods
    
    internal func didSucceedRetrievingProducts() {
        
        if shouldRetryLoad {
            // in case the user allows sensors while loading the product list with the iplookup parameters
            shouldRetryLoad = false
            retrieveProductsFirstPage()
        }
    }
    
    // MARK: - Private methods
    
    private func retrieveProductsIfNeededWithNewLocation(newLocation: LGLocation) {

        var shouldUpdate = false

        if canRetrieveProducts {
            // If there are no products, then refresh
            if numberOfProducts == 0 {
                shouldUpdate = true
            }
            // If new location is manual OR last location was manual, and location has changed then refresh
            else if newLocation.type == .Manual || lastReceivedLocation?.type == .Manual {
                if let lastReceivedLocation = lastReceivedLocation {
                    if (newLocation != lastReceivedLocation) {
                        shouldUpdate = true
                    }
                }
            }
            // If new location is not manual and we improved the location type to sensors
            else if lastReceivedLocation?.type != .Sensor && newLocation.type == .Sensor {
                shouldUpdate = true
            }
        } else if numberOfProducts == 0 && lastReceivedLocation?.type != .Sensor && newLocation.type == .Sensor {
            // in case the user allows sensors while loading the product list with the iplookup parameters
            shouldRetryLoad = true
        }

        if shouldUpdate{
            retrieveProductsFirstPage()
        }
        
        // Track the received location
        lastReceivedLocation = newLocation
    }
    
    // MARK: > NSNotificationCenter
    
    /** 
        Called when a new location is received. It retrieves the first product page in case we do not have products.
    */
    @objc private func locationUpdate(notification: NSNotification) {
        
        if let newLocation = notification.object as? LGLocation {

            // Tracking: when a new location is received and has different type than previous one
            var shouldTrack = false
            if let actualLastReceivedLocation = lastReceivedLocation {
                if actualLastReceivedLocation.type != newLocation.type {
                    shouldTrack = true
                }
            }
            else {
                shouldTrack = true
            }
            if shouldTrack {
                let locationServiceStatus = locationManager.locationServiceStatus
                let trackerEvent = TrackerEvent.location(newLocation, locationServiceStatus: locationServiceStatus)
                tracker.trackEvent(trackerEvent)
            }
            
            // Retrieve products (should be place after tracking, as it updates lastReceivedLocation)
            retrieveProductsIfNeededWithNewLocation(newLocation)
        }
    }
}


class MainProductListRequester: ProductListRequester {

    private let productRepository: ProductRepository
    private let locationManager: LocationManager

    var queryString: String?
    var filters: ProductFilters?

    convenience init() {
        self.init(productRepository: Core.productRepository, locationManager: Core.locationManager)
    }

    init(productRepository: ProductRepository, locationManager: LocationManager) {
        self.productRepository = productRepository
        self.locationManager = locationManager
    }

    func productsRetrieval(offset offset: Int, completion: ProductsCompletion?) {
        productRepository.index(retrieveProductsParams, pageOffset: offset, completion: completion)
    }

    func isLastPage(resultCount: Int) -> Bool {
        return resultCount == 0
    }

    func hasFilters() -> Bool {
        return filters?.selectedCategories != nil || filters?.selectedWithin != nil || filters?.distanceRadius != nil
    }

    func distanceFromProductCoordinates(productCoords: LGLocationCoordinates2D) -> Double {

        var meters = 0.0

        if let coordinates = queryCoordinates {
            let quadKeyStr = coordinates.coordsToQuadKey(LGCoreKitConstants.defaultQuadKeyPrecision)
            let actualQueryCoords = LGLocationCoordinates2D(fromCenterOfQuadKey: quadKeyStr)
            let queryLocation = CLLocation(latitude: actualQueryCoords.latitude, longitude: actualQueryCoords.longitude)
            let productLocation = CLLocation(latitude: productCoords.latitude, longitude: productCoords.longitude)

            meters = queryLocation.distanceFromLocation(productLocation)
        }

        let distanceType = DistanceType.systemDistanceType()
        switch (distanceType) {
        case .Km:
            return meters * 0.001
        case .Mi:
            return meters * 0.000621371
        }
    }

    private var queryCoordinates: LGLocationCoordinates2D? {
        if let coordinates = filters?.place?.location {
            return coordinates
        } else if let currentLocation = locationManager.currentLocation {
            return LGLocationCoordinates2D(location: currentLocation)
        }
        return nil
    }

    private var countryCode: String? {
        if let countryCode = filters?.place?.postalAddress?.countryCode {
            return countryCode
        }
        return locationManager.currentPostalAddress?.countryCode
    }

    private var retrieveProductsParams: RetrieveProductsParams {
        var params: RetrieveProductsParams = RetrieveProductsParams()
        params.coordinates = queryCoordinates
        params.queryString = queryString
        params.countryCode = countryCode
        params.categoryIds = filters?.selectedCategories.map{ $0.rawValue }
        params.timeCriteria = filters?.selectedWithin
        params.sortCriteria = filters?.selectedOrdering
        params.distanceRadius = filters?.distanceRadius
        params.distanceType = filters?.distanceType
        return params
    }
}
