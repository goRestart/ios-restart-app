    //
//  MainProductListViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public protocol MainProductListViewModelLocationDelegate: ProductListViewModelDataDelegate {
    func viewModel(viewModel: MainProductListViewModel, didFailRequestingLocationServices status: LocationServiceStatus)
    func viewModelDidTimeOutRetrievingLocation(viewModel: MainProductListViewModel)
}

public class MainProductListViewModel: ProductListViewModel {
    
    // Delegate
    public weak var locationDelegate: MainProductListViewModelLocationDelegate?
    
    // Manager
    private let myUserManager: MyUserManager
    private let locationManager: LocationManager
    
    // Data
    private var lastReceivedLocation: LGLocation?
    
    // Flags
    private var didNotifyAboutLocationTimeOut: Bool
    
    // MARK: - Computed iVars
    
    public override var canRetrieveProducts: Bool {
        return super.canRetrieveProducts && queryCoordinates != nil
    }
    
    // MARK: - Lifecycle
    
    override init() {
        self.myUserManager = MyUserManager.sharedInstance
        self.locationManager = LocationManager.sharedInstance
        self.didNotifyAboutLocationTimeOut = false
        self.lastReceivedLocation = self.locationManager.lastKnownLocation
        super.init()
        self.isProfileList = false
    }
    
    internal override func didSetActive(active: Bool) {
        super.didSetActive(active)
        
        // Active
        if (active) {
            // Observe LocationManager
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: Selector("didReceiveLocationWithNotification:"), name: LocationManager.didReceiveLocationNotification, object: nil)
            notificationCenter.addObserver(self, selector: Selector("didFailRequestingLocationServicesWithNotification:"), name: LocationManager.didFailRequestingLocationServices, object: nil)
            notificationCenter.addObserver(self, selector: Selector("didTimeOutRetrievingLocationWithNotification:"), name: LocationManager.didTimeOutRetrievingLocation, object: nil)
            
            // If we do not have products & we can retrieve products (has coordinates & the manager is not loading), then do it
            if numberOfProducts == 0 && canRetrieveProducts {
               retrieveProductsFirstPage()
            }
            // If location manager location retrieval already timed out, we didn't notify and there's no location, then notify
            else if !didNotifyAboutLocationTimeOut && locationManager.locationRetrievalDidTimeOut && locationManager.lastKnownLocation == nil {
                notifyTimeOutRetrievingLocation()
            }
        }
        // Inactive
        else {
            // Stop observing
            NSNotificationCenter.defaultCenter().removeObserver(self)
        }
    }
    
    // MARK: - Internal methods
    
    internal override func didSucceedRetrievingProducts() {
        // Tracking
        let myUser = myUserManager.myUser()
        let trackerEvent = TrackerEvent.productList(myUser, categories: categories, searchQuery: queryString, pageNumber: pageNumber)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    // MARK: - Private methods
    
    // MARK: > NSNotificationCenter
    
    /** 
        Called when a new location is received. It retrieves the first product page in case we do not have products.
    */
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {
        
        if let newLocation = notification.object as? LGLocation {
            // If we improved the location type to sensors then run the first page retrieval
            if let actualLastReceivedLocation = lastReceivedLocation {
                if actualLastReceivedLocation.type != .Sensor && newLocation.type == .Sensor && canRetrieveProducts {
                    retrieveProductsFirstPage()
                }
                
                // Track the received location
                lastReceivedLocation = newLocation
            }
            
            // Tracking
            let locationServiceStatus = LocationManager.sharedInstance.locationServiceStatus
            let trackerEvent = TrackerEvent.location(newLocation, locationServiceStatus: locationServiceStatus)
            TrackerProxy.sharedInstance.trackEvent(trackerEvent)
        }
        
        // If we can retrieve products and we do not any, then run the first page retrieval
        if canRetrieveProducts && numberOfProducts == 0 {
            retrieveProductsFirstPage()
        }
    }
    
    /** 
        Called when a location services request fails. 
    */
    @objc private func didFailRequestingLocationServicesWithNotification(notification: NSNotification) {
        // Notify the delegate
        let status = locationManager.locationServiceStatus
        locationDelegate?.viewModel(self, didFailRequestingLocationServices: status)
    }
    
    /**
        Called when a location services request times out.
    */
    @objc private func didTimeOutRetrievingLocationWithNotification(notification: NSNotification) {
        if !didNotifyAboutLocationTimeOut {
            notifyTimeOutRetrievingLocation()
        }
    }
    
    /**
        Notifies about the time out retriving location.
    */
    private func notifyTimeOutRetrievingLocation() {
        didNotifyAboutLocationTimeOut = true
        locationDelegate?.viewModelDidTimeOutRetrievingLocation(self)
    }
}