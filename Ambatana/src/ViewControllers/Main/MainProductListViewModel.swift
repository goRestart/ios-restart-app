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
    func viewModel(viewModel: MainProductListViewModel, didTimeOutRetrievingLocation timeout: NSTimeInterval)
}

public class MainProductListViewModel: ProductListViewModel {
    
    // Constants
    private static let locationRetrievalTimeout: NSTimeInterval = 15    // seconds
    
    // Delegate
    public weak var locationDelegate: MainProductListViewModelLocationDelegate?
    
    // Manager & timer
    private let myUserManager: MyUserManager
    private let locationManager: LocationManager
    private var locationRetrievalTimeoutTimer: NSTimer?
    
    // MARK: - Computed iVars
    
    public override var canRetrieveProducts: Bool {
        return super.canRetrieveProducts && queryCoordinates != nil
    }
    
    internal override var retrieveProductsFirstPageParams: RetrieveProductsParams {
        var params = super.retrieveProductsFirstPageParams
        params.coordinates = queryCoordinates
        return params
    }
    
    private var queryCoordinates: LGLocationCoordinates2D? {
        let coords: LGLocationCoordinates2D?
        // If we had specified coordinates
        if let specifiedCoordinates = coordinates {
            coords = specifiedCoordinates
        }
        // Try to use last LocationManager location
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
        super.init()
    }
    
    internal override func didSetActive(active: Bool) {
        super.didSetActive(active)
        
        // Active
        if (active) {
            // Observe when receiving new location notifications by LocationManager
            let notificationCenter = NSNotificationCenter.defaultCenter()
            notificationCenter.addObserver(self, selector: Selector("didReceiveLocationWithNotification:"), name: LocationManager.didReceiveLocationNotification, object: nil)
            notificationCenter.addObserver(self, selector: Selector("didFailRequestingLocationServicesWithNotification:"), name: LocationManager.didFailRequestingLocationServices, object: nil)
            
            // If we can retrieve products and we do not any, then run the first page retrieval
            if canRetrieveProducts && numberOfProducts == 0 {
                retrieveProductsFirstPage()
            }
            // If we cannot retrieve products but have products, then it's about location
            else if numberOfProducts == 0 {

                // If location status is not enabled & authorized notify then delegate know
                let locationStatus = locationManager.locationServiceStatus
                if locationStatus != .Enabled(LocationServicesAuthStatus.Authorized) {
                    locationDelegate?.viewModel(self, didFailRequestingLocationServices: locationStatus)
                }
                
                // Re/start the location retrieval timer
                if locationRetrievalTimeoutTimer != nil {
                    locationRetrievalTimeoutTimer!.invalidate()
                    locationRetrievalTimeoutTimer = nil
                }
                locationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(MainProductListViewModel.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)
            }
            
            // If we can retrieve products and we do not any, then run the first page retrieval
            if numberOfProducts == 0 {
               
                // Reload if possible
                if canRetrieveProducts {
                     retrieveProductsFirstPage()
                }
                // Otherwise
                else if queryCoordinates == nil {
                    
                    // If location status is not enabled & authorized notify the delegate
                    let locationStatus = locationManager.locationServiceStatus
                    if locationStatus != .Enabled(LocationServicesAuthStatus.Authorized) {
                        locationDelegate?.viewModel(self, didFailRequestingLocationServices: locationStatus)
                    }
                    
                    // Restart the location retrieval timer
                    if locationRetrievalTimeoutTimer != nil {
                        locationRetrievalTimeoutTimer!.invalidate()
                        locationRetrievalTimeoutTimer = nil
                    }
                    locationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(MainProductListViewModel.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)
                }
            }
        }
        // Inactive
        else {
            // Stop observing
            NSNotificationCenter.defaultCenter().removeObserver(self)
            
            // Stop the location retrieval timer
            if locationRetrievalTimeoutTimer != nil {
                locationRetrievalTimeoutTimer!.invalidate()
                locationRetrievalTimeoutTimer = nil
            }
        }
    }
    
    // MARK: - Internal methods
    
    internal override func didSucceedRetrievingProducts() {
        // Tracking
        let myUser = MyUserManager.sharedInstance.myUser()
        let trackerEvent = TrackerEvent.productList(myUser, categories: categories, searchQuery: queryString, pageNumber: pageNumber)
        TrackerProxy.sharedInstance.trackEvent(trackerEvent)
    }
    
    // MARK: - Private methods
    
    // MARK: > Timer
    
    /**
        Called when a location retrieval times out.
    */
    @objc func locationRetrievalTimedOut() {
        // If we do not have query coordinates then notify the delegate about the location retrieal timeout
        if queryCoordinates == nil {
            locationDelegate?.viewModel(self, didTimeOutRetrievingLocation: MainProductListViewModel.locationRetrievalTimeout)
        }
    }
    
    // MARK: > NSNotificationCenter
    
    /** 
        Called when a new location is received. It retrieves the first product page in case we do not have products.
    */
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {
        // If we had a timer running, kill it
        if locationRetrievalTimeoutTimer != nil {
            locationRetrievalTimeoutTimer!.invalidate()
            locationRetrievalTimeoutTimer = nil
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
}