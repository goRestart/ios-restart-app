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
            
            // If we do not have products
            if numberOfProducts == 0 {
               
                // Reload if possible (has coordinates & the manager is not loading)
                if canRetrieveProducts {
                     retrieveProductsFirstPage()
                }
                // Otherwise, if there are not coordinates
                else if queryCoordinates == nil {
                    
                    // If location status is not enabled nor authorized notify the delegate
                    let locationStatus = locationManager.locationServiceStatus
                    if locationStatus != .Enabled(LocationServicesAuthStatus.Authorized) {
                        locationDelegate?.viewModel(self, didFailRequestingLocationServices: locationStatus)
                    }
                    
                    // Restart the location retrieval timer
                    restartTimer()
                }
                // Else, will eventually got the products response
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
        Restarts the location retrieval timeout timer.
    */
    private func restartTimer() {
        if locationRetrievalTimeoutTimer != nil {
            locationRetrievalTimeoutTimer!.invalidate()
            locationRetrievalTimeoutTimer = nil
        }
        locationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(MainProductListViewModel.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)
    }
    
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