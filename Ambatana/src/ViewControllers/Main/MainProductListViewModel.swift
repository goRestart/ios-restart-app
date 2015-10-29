//
//  MainProductListViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public class MainProductListViewModel: ProductListViewModel {

    // Manager
    private let myUserManager: MyUserManager
    
    // Data
    private var lastReceivedLocation: LGLocation?
    private var locationActivatedWhileLoading: Bool
    
    // MARK: - Computed iVars
    
    public override var canRetrieveProducts: Bool {
        return super.canRetrieveProducts && queryCoordinates != nil
    }
    
    // MARK: - Lifecycle

    override init() {
        self.myUserManager = MyUserManager.sharedInstance
        self.lastReceivedLocation = self.myUserManager.currentLocation
        self.locationActivatedWhileLoading = false
        super.init()
        
        self.countryCode = self.myUserManager.myUser()?.postalAddress.countryCode
        self.isProfileList = false
        
        // Observe MyUserManager location updates
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("didReceiveLocationWithNotification:"), name: MyUserManager.Notification.locationUpdate.rawValue, object: nil)
    }
    
     deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    internal override func didSetActive(active: Bool) {
        super.didSetActive(active)

        // Active
        if (active) {
            if let currentLocation = MyUserManager.sharedInstance.currentLocation {
                retrieveProductsIfNeededWithNewLocation(currentLocation)
            }
        }
    }
    
    // MARK: - Public methods
    
    public override func retrieveProductsFirstPage() {
        // Update before requesting the first page
        countryCode = self.myUserManager.myUser()?.postalAddress.countryCode
        super.retrieveProductsFirstPage()
    }
    
    // MARK: - Internal methods
    
    internal override func didSucceedRetrievingProducts() {
        
        // Tracking
        let myUser = myUserManager.myUser()
        let trackerEvent = TrackerEvent.productList(myUser, categories: categories, searchQuery: queryString, pageNumber: pageNumber)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)

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
            // If new location is manual OR last location was manual, then refresh
            else if newLocation.type == .Manual || lastReceivedLocation?.type == .Manual {
                retrieveProductsFirstPage()
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
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {
        
        if let newLocation = notification.object as? LGLocation {

            if let lastLocation = lastReceivedLocation {
                if lastLocation.type != newLocation.type {
                    // Tracking.  Only when the location type changes.
                    let locationServiceStatus = myUserManager.locationServiceStatus
                    let trackerEvent = TrackerEvent.location(newLocation, locationServiceStatus: locationServiceStatus)
                    TrackerProxy.sharedInstance.trackEvent(trackerEvent)
                }
            }
            retrieveProductsIfNeededWithNewLocation(newLocation)
        }
    }
}