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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveLocationWithNotification:", name: LocationManager.didReceiveLocationNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: - Public methods
    
    public func myUser() -> MyUser? {
        return PFUser.currentUser()
    }
    
    public func saveUserCoordinates(coordinates: CLLocationCoordinate2D) -> BFTask? {
        return saveLocationAndRetrieveAddress(CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude))
    }
    
    // MARK: - Private methods
    
    // MARK: > Helper
    
    private func save() -> BFTask? {
        
        if let myUser = myUser() {
            var task = BFTaskCompletionSource()
            
            userSaveService.saveUser(myUser) { (success: Bool, error: NSError?) -> Void in
                if let actualError = error {
                    task.setError(error)
                }
                else {
                    task.setResult(success)
                }
            }
            return task.task
        }
        return nil
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
            myUser.gpsCoordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            myUser.address = ""
            myUser.city = ""
            myUser.countryCode = ""
            myUser.zipCode = ""
            save()
            
            // Then, retrieve the address for the received location
            return retrieveAddressForLocation(location).continueWithSuccessBlock { (task: BFTask!) -> AnyObject! in
                if let postalAddress = task.result as? PostalAddress {
                    myUser.address = postalAddress.address ?? ""
                    myUser.city = postalAddress.city ?? ""
                    let countryCode = postalAddress.countryCode
                    myUser.countryCode = countryCode ?? ""
                    myUser.zipCode = postalAddress.zipCode ?? ""
                    
                    // If we know the country code, then notify the CurrencyHelper
                    if countryCode != nil && !(countryCode!.isEmpty) {
                        CurrencyHelper.sharedInstance.setCountryCode(countryCode!)
                    }
                    
                    // Save the user again
                    return self.save()
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