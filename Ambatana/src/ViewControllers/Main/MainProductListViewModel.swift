//
//  MainProductListViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class MainProductListViewModel: ProductListViewModel {

    // Managers, repositories & tracker
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    
    // Data
    private var lastReceivedLocation: LGLocation?
    private var shouldRetryLoad: Bool
    
    
    // MARK: - Computed iVars
    
    public override var canRetrieveProducts: Bool {
        return super.canRetrieveProducts && queryCoordinates != nil
    }
    
    
    // MARK: - Lifecycle
    
    init(locationManager: LocationManager, productRepository: ProductRepository,
        myUserRepository: MyUserRepository, tracker: Tracker) {
            self.locationManager = locationManager
            self.myUserRepository = myUserRepository
            self.tracker = tracker
            self.lastReceivedLocation = locationManager.currentLocation
            self.shouldRetryLoad = false
            super.init(locationManager: locationManager, productRepository: productRepository,
                myUserRepository: myUserRepository, cellDrawer: ProductCellDrawerFactory.drawerForProduct(true))

            self.isProfileList = false
            
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MainProductListViewModel.locationUpdate(_:)),
                name: LocationManager.Notification.LocationUpdate.rawValue, object: nil)
    }
    
    convenience init() {
        let locationManager = Core.locationManager
        let productRepository = Core.productRepository
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(locationManager: locationManager, productRepository: productRepository,
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
    
    internal override func didSucceedRetrievingProducts() {
        
        // Tracking
        let myUser = myUserRepository.myUser
        let trackerEvent = TrackerEvent.productList(myUser, categories: categories, searchQuery: queryString, pageNumber: pageNumber)
        tracker.trackEvent(trackerEvent)

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