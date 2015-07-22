//
//  MainProductListViewModel.swift
//  LetGo
//
//  Created by Albert Hernández López on 21/07/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public protocol MainProductListViewModelDelegate: ProductListViewModelDelegate {
    func viewModel(viewModel: MainProductListViewModel, didFailRequestingLocationServices status: LocationServiceStatus)
    func viewModel(viewModel: MainProductListViewModel, didTimeOutRetrievingLocation timeout: NSTimeInterval)
}

public class MainProductListViewModel: ProductListViewModel {
    
    // Constants
    private static let locationRetrievalTimeout: NSTimeInterval = 10    // seconds
    
    // Delegate
    public weak var mainProductListViewModelDelegate: MainProductListViewModelDelegate? {
        didSet {
            delegate = mainProductListViewModelDelegate
        }
    }
    
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
        else if !isLoading {
            shouldCheckLocation = true
        }
        
        if shouldCheckLocation {
            // If no location access, then notify the delegate
            let locationStatus = locationManager.locationServiceStatus
            if locationStatus != .Enabled(LocationServicesAuthStatus.Authorized) {
                mainProductListViewModelDelegate?.viewModel(self, didFailRequestingLocationServices: locationStatus)
            }
            // If we've location access but we don't have a location yet, run a timer
            else if queryCoordinates == nil {
                if locationRetrievalTimeoutTimer != nil {
                    locationRetrievalTimeoutTimer!.invalidate()
                    locationRetrievalTimeoutTimer = nil
                }
                locationRetrievalTimeoutTimer = NSTimer.scheduledTimerWithTimeInterval(MainProductListViewModel.locationRetrievalTimeout, target: self, selector: Selector("locationRetrievalTimedOut"), userInfo: nil, repeats: false)
            }
        }
    }
    
    internal override func didSetInactive() {
        super.didSetInactive()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - Private methods
    
    // MARK: > Timer
    
    /**
        Called when a location retrieval times out.
    */
    @objc func locationRetrievalTimedOut() {
        // If we do not have query coordinates then notify the delegate about the location retrieal timeout
        if queryCoordinates == nil {
            mainProductListViewModelDelegate?.viewModel(self, didTimeOutRetrievingLocation: MainProductListViewModel.locationRetrievalTimeout)
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
        
        // If we do not have products
        if numberOfProducts == 0 {
            // As we've coordinates then run the first page retrieval
            if let coordinates = queryCoordinates {
                retrieveProductsFirstPage()
            }
        }
    }
    
    /** 
        Called when a location services request fails. 
    */
    @objc private func didFailRequestingLocationServicesWithNotification(notification: NSNotification) {
        // Notify the delegate
        let status = locationManager.locationServiceStatus
        mainProductListViewModelDelegate?.viewModel(self, didFailRequestingLocationServices: status)
    }
}