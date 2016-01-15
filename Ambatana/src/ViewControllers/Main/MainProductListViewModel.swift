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
    private var locationActivatedWhileLoading: Bool
    
    // MARK: - Computed iVars
    
    public override var canRetrieveProducts: Bool {
        return super.canRetrieveProducts && queryCoordinates != nil
    }
    
    // MARK: - Lifecycle

    init(locationManager: LocationManager, myUserRepository: MyUserRepository, tracker: Tracker) {
        self.locationManager = locationManager
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        self.lastReceivedLocation = locationManager.currentLocation
        self.locationActivatedWhileLoading = false
        super.init()
        
        self.countryCode = myUserRepository.myUser?.postalAddress.countryCode
        self.isProfileList = false
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("locationUpdate:"), name: LocationManager.Notification.LocationUpdate.rawValue, object: nil)
    }
    
    override convenience init() {
        let locationManager = Core.locationManager
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(locationManager: locationManager, myUserRepository: myUserRepository, tracker: tracker)
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
    
    public override func retrieveProductsFirstPage() {
        // Update before requesting the first page
        countryCode = locationManager.currentPostalAddress?.countryCode
        super.retrieveProductsFirstPage()
    }
    
    // MARK: - Internal methods
    
    internal override func didSucceedRetrievingProducts() {
        
        // Tracking
        let myUser = myUserRepository.myUser
        let trackerEvent = TrackerEvent.productList(myUser, categories: categories, searchQuery: queryString, pageNumber: pageNumber)
        tracker.trackEvent(trackerEvent)

        if locationActivatedWhileLoading {
            // in case the user allows sensors while loading the product list with the iplookup parameters
            locationActivatedWhileLoading = false
            retrieveProductsFirstPage()
        }
    }
    
    // MARK: - Private methods
    
    private func retrieveProductsIfNeededWithNewLocation(newLocation: LGLocation) {
        
        // If new location is manual
        if canRetrieveProducts {
            
            // If there are no products, then refresh
            if numberOfProducts == 0 {
                retrieveProductsFirstPage()
            }
            // If new location is manual OR last location was manual, and location has changed then refresh
            else if newLocation.type == .Manual || lastReceivedLocation?.type == .Manual {
                if let lastReceivedLocation = lastReceivedLocation {
                    if (newLocation != lastReceivedLocation) {
                        retrieveProductsFirstPage()
                    }
                }
            }
            // If new location is not manual and we improved the location type to sensors
            else if lastReceivedLocation?.type != .Sensor && newLocation.type == .Sensor {
                retrieveProductsFirstPage()
            }
        } else if numberOfProducts == 0 && lastReceivedLocation?.type != .Sensor && newLocation.type == .Sensor {
            // in case the user allows sensors while loading the product list with the iplookup parameters
            locationActivatedWhileLoading = true
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