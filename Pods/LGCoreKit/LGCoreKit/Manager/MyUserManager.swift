//
//  MyUserManager.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import Bolts
import CoreLocation
import Parse

public class MyUserManager {
    
    // Constants
    public static let didReceiveAddressNotification = "MyUserManager.didReceiveAddressNotification"
    
    // iVars
    private var userSaveService: UserSaveService
    private var postalAddressRetrivalService: PostalAddressRetrievalService

    // Singleton
    public static let sharedInstance: MyUserManager = MyUserManager()
    
    // MARK: - Lifecycle
    
    public init(userSaveService: UserSaveService = PAUserSaveService(), postalAddressRetrivalService: PostalAddressRetrievalService = CLPostalAddressRetrievalService()) {
        self.userSaveService = userSaveService
        self.postalAddressRetrivalService = postalAddressRetrivalService
        
        // Start observing location changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveLocationWithNotification:", name: LocationManager.didReceiveLocationNotification, object: nil)
    }
    
    deinit {
        // Stop observing
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Public methods
    
    public func myUser() -> User? {
        return PFUser.currentUser()
    }
    
    public func isAnonymousUser() -> Bool {
        if let myUser = myUser() {
            return myUser.isAnonymous
        }
        return true
    }
    
    public func saveIfNew() -> BFTask {
        if let myUser = myUser() {
            if !myUser.isSaved {
                return save(myUser)
            }
        }
        
        return BFTask(error: NSError(code: LGErrorCode.Internal))
    }
    
    public func saveUserCoordinates(coordinates: CLLocationCoordinate2D) -> BFTask? {
        return saveLocationAndRetrieveAddress(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude))
    }
    
    // MARK: - Private methods
    
    // MARK: > Helper
    
    private func save(user: User) -> BFTask {
        
        var task = BFTaskCompletionSource()
        
        userSaveService.saveUser(user) { (success: Bool, error: NSError?) -> Void in
            if let actualError = error {
                task.setError(error)
            }
            else {
                task.setResult(success)
            }
        }
        return task.task
    }
    
    private func retrieveAddressForLocation(location: CLLocation) -> BFTask {
        var task = BFTaskCompletionSource()
        postalAddressRetrivalService.retrieveAddressForLocation(location) { (address: PostalAddress?, error: NSError?) in
            if let actualError = error {
                task.setError(error)
            }
            else if let actualAddress = address {
                task.setResult(actualAddress)
            }
        }
        return task.task
    }
    
    private func saveLocationAndRetrieveAddress(location: CLLocation) -> BFTask? {
        if let myUser = myUser() {
            // Save the received location and erase previous postal address data, if any
            myUser.gpsCoordinates = LGLocationCoordinates2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let address = PostalAddress()
            myUser.postalAddress = address
            save(myUser)
            
            // Then, retrieve the address for the received location
            return retrieveAddressForLocation(location).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                if let postalAddress = task.result as? PostalAddress {
                    myUser.postalAddress = postalAddress
                    
                    // If we know the country code, then notify the CurrencyHelper
                    if let countryCode = postalAddress.countryCode {
                        if !countryCode.isEmpty {
                            CurrencyHelper.sharedInstance.setCountryCode(countryCode)
                        }
                    }
                    
                    // Save the user again
                    return self.save(myUser)
                }
                return nil
            }
        }
        return nil
    }
    
    // MARK: > NSNotificationCenter
    
    @objc private func didReceiveLocationWithNotification(notification: NSNotification) {

        if let location = notification.object as? CLLocation {
            saveLocationAndRetrieveAddress(location)
        }
    }
}