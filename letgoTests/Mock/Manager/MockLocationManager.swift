//
//  MockLocationManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit

class MockLocationManager: LocationManager {
    var myUserResult: MyUserResult?
    var askForLocationPermissions = false


    // MARK: - LocationManager

    var didAcceptPermissions: Bool = false
    var isManualLocationEnabled: Bool = false
    var manualLocationThreshold: Double = 1000

    func initialize() {
    }

    var currentLocation: LGLocation?
    var currentAutoLocation: LGLocation?
    var currentPostalAddress: PostalAddress?

    func setManualLocation(location: CLLocation, postalAddress: PostalAddress, completion: MyUserCompletion?) {
        completion?(myUserResult!)
    }

    func setAutomaticLocation(userUpdateCompletion: MyUserCompletion?) {
        userUpdateCompletion?(myUserResult!)
    }

    var locationServiceStatus: LocationServiceStatus = .Disabled

    func startSensorLocationUpdates() -> LocationServiceStatus {
        return locationServiceStatus
    }

    func stopSensorLocationUpdates() {
    }

    func shouldAskForLocationPermissions() -> Bool {
        return askForLocationPermissions
    }
}
