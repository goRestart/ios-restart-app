//
//  MockLocationManager.swift
//  LetGo
//
//  Created by Albert Hernández López on 22/11/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import RxSwift

class MockLocationManager: LocationManager {
    var myUserResult: MyUserResult?
    var askForLocationPermissions = false


    // MARK: - LocationManager

    var locationEvents: Observable<LocationEvent> = PublishSubject<LocationEvent>()
    var didAcceptPermissions: Bool = false
    var isManualLocationEnabled: Bool = false
    var manualLocationThreshold: Double = 1000

    func initialize() {
    }

    var currentLocation: LGLocation?
    var currentAutoLocation: LGLocation?

    func setManualLocation(_ location: CLLocation, postalAddress: PostalAddress, completion: MyUserCompletion?) {
        performAfterDelayWithCompletion(completion, result: myUserResult!)
    }

    func setAutomaticLocation(_ userUpdateCompletion: MyUserCompletion?) {
        performAfterDelayWithCompletion(userUpdateCompletion, result: myUserResult!)
    }

    var locationServiceStatus: LocationServiceStatus = .disabled

    func startSensorLocationUpdates() -> LocationServiceStatus {
        return locationServiceStatus
    }

    func stopSensorLocationUpdates() {
    }

    func shouldAskForLocationPermissions() -> Bool {
        return askForLocationPermissions
    }
}
