//
//  LGLocationManager.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result
import RxSwift


// MARK: - LocationManager

class LGLocationManager: NSObject, CLLocationManagerDelegate, LocationManager {

    var didAcceptPermissions: Bool {
        switch sensorLocationService.authorizationStatus() {
        case .AuthorizedAlways, .AuthorizedWhenInUse:
            return true
        case .Restricted, .Denied, .NotDetermined:
            return false
        }
    }

    var locationEvents: Observable<LocationEvent> {
        return events
    }

    // Repositories
    private let myUserRepository: InternalMyUserRepository

    // Services
    private let sensorLocationService: LocationService
    private let ipLookupLocationService: IPLookupLocationService
    private let postalAddressRetrievalService: PostalAddressRetrievalService

    // DAO
    private let dao: DeviceLocationDAO

    // Helpers
    private let countryHelper: CountryHelper

    // iVars
    private var sensorLocation: LGLocation?
    private var inaccurateLocation: LGLocation?
    private var lastNotifiedLocation: LGLocation?
    private let events = PublishSubject<LocationEvent>()

    private var sessionDisposeBag = DisposeBag()

    /**
     Returns if the manual location is enabled.
     */
    private(set) var isManualLocationEnabled: Bool

    /**
     When set if last manual location is saved, then if an auto location is received far from it according this
     threshold a `MovedFarFromSavedManualLocation` notification will be posted.
     */
    var manualLocationThreshold: Double


    // MARK: - Lifecycle

    init(myUserRepository: InternalMyUserRepository,
         sensorLocationService: LocationService, ipLookupLocationService: IPLookupLocationService,
         postalAddressRetrievalService: PostalAddressRetrievalService, deviceLocationDAO: DeviceLocationDAO,
         countryHelper: CountryHelper) {
        self.myUserRepository = myUserRepository

        self.sensorLocationService = sensorLocationService
        self.ipLookupLocationService = ipLookupLocationService
        self.postalAddressRetrievalService = postalAddressRetrievalService

        self.dao = deviceLocationDAO

        self.countryHelper = countryHelper

        if let lastKnownLocation = sensorLocationService.lastKnownLocation {
            self.sensorLocation = LGLocation(location: lastKnownLocation, type: .Sensor)
        }
        self.inaccurateLocation = nil
        self.lastNotifiedLocation = nil

        self.isManualLocationEnabled = false

        self.manualLocationThreshold = LGCoreKitConstants.defaultManualLocationThreshold

        super.init()

        // Setup
        self.sensorLocationService.locationManagerDelegate = self
        self.setup()
    }

    func initialize() {
        retrieveInaccurateLocation()
    }

    func observeSessionManager(sessionManager: SessionManager) {
        sessionDisposeBag = DisposeBag()
        sessionManager.sessionEvents.subscribeNext { [weak self] event in
            switch event {
            case .Login:
                self?.setup()
                self?.checkUserLocationAndUpdate()
            case .Logout:
                self?.isManualLocationEnabled = false
            }
        }.addDisposableTo(sessionDisposeBag)
    }


    // MARK: > Location

    /**
     Returns the current location with the following preference/fallback:

     1. User location if its type is manual
     2. Sensor
     3. User location
     4. Device location
     5. Inaccurate (IP, or worst case: regional)
     */
    var currentLocation: LGLocation? {
        if let userLocation = myUserRepository.myUser?.location where userLocation.type == .Manual {
            return userLocation
        }
        if let sensorLocation = sensorLocation { return sensorLocation }
        if let userLocation = myUserRepository.myUser?.location { return userLocation }
        if let deviceLocation = dao.deviceLocation?.location { return deviceLocation }
        return inaccurateLocation
    }

    /**
     Returns the best accurate automatic location.
     */
    var currentAutoLocation: LGLocation? {
        if let sensorLocation = sensorLocation { return sensorLocation }
        return inaccurateLocation
    }

    /**
     Returns the current postal address with the following preference/fallback (follows currentLocation behaviour):

     1. User postalAddress if its type is manual
     2. Device postalAddress if sensor location enabled
     3. User postalAddress
     4. Device postalAddress
     */
    var currentPostalAddress: PostalAddress? {
        if let userLocation = myUserRepository.myUser?.location,
            userPostalAddress = myUserRepository.myUser?.postalAddress where userLocation.type == .Manual {
            return userPostalAddress
        }
        if let _ = sensorLocation { return dao.deviceLocation?.postalAddress }
        if let userPostalAddress = myUserRepository.myUser?.postalAddress { return userPostalAddress }
        return dao.deviceLocation?.postalAddress
    }

    /**
     Sets the given location as manual.
     - parameter location: The location.
     - parameter postalAddress: The postal address.
     - parameter userUpdateCompletion: The `MyUser` update completion closure.
     */
    func setManualLocation(location: CLLocation, postalAddress: PostalAddress,
                                  completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        guard let lgLocation = LGLocation(location: location, type: .Manual) else {
            completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Invalid CLLocation")))
            return
        }
        isManualLocationEnabled = true

        updateLocation(lgLocation, postalAddress: postalAddress, userUpdateCompletion: completion)
    }

    /**
     Sets the location as automatic.
     - parameter userUpdateCompletion: The `MyUser` update completion closure.
     */
    func setAutomaticLocation(userUpdateCompletion: ((Result<MyUser, RepositoryError>) -> ())?) {
        isManualLocationEnabled = false

        guard let currentAutoLocation = currentAutoLocation else { return }
        updateLocation(currentAutoLocation, postalAddress: nil, userUpdateCompletion: userUpdateCompletion)
    }

    /**
     Returns the current location service status.
     */
    var locationServiceStatus: LocationServiceStatus {
        return LocationServiceStatus(enabled: sensorLocationService.locationEnabled(),
                                     authStatus: sensorLocationService.authorizationStatus())
    }


    // MARK: > Sensor location updates

    /**
     Starts updating sensor location.

     - returns: The location service status.
     */
    func startSensorLocationUpdates() -> LocationServiceStatus {
        let enabled = sensorLocationService.locationEnabled()
        let authStatus = sensorLocationService.authorizationStatus()

        if enabled {
            // If not determined, ask authorization
            if shouldAskForLocationPermissions() {
                sensorLocationService.requestWhenInUseAuthorization()
            } else {
                // Otherwise, start the location updates
                sensorLocationService.startUpdatingLocation()
            }
        }
        return LocationServiceStatus(enabled: enabled, authStatus: authStatus)
    }

    /**
     Stops updating location.
     */
    func stopSensorLocationUpdates() {
        sensorLocationService.stopUpdatingLocation()
    }


    // MARK: - CLLocationManagerDelegate

    func shouldAskForLocationPermissions() -> Bool {
        return sensorLocationService.authorizationStatus() == .NotDetermined
    }

    /*
     Warning, this method will be called on app launch because it's called when the CLLOcationManager it's initialized.
     */
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        defer { dao.save(status) }

        if didAcceptPermissions {
            startSensorLocationUpdates()
        }

        // Only notify if there really is a change in the auth status, not always
        guard let currentStatus = dao.locationStatus where currentStatus != status else { return }

        events.onNext(.ChangedPermissions)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }

        sensorLocation = LGLocation(location: lastLocation, type: .Sensor)
        guard let location = sensorLocation else { return }

        updateLocation(location)
    }


    // MARK: - Private methods

    // MARK: > Setup

    /**
     Setup.
     */
    private func setup() {
        isManualLocationEnabled = myUserRepository.myUser?.location?.type == .Manual
    }


    // MARK: > Innacurate location & address retrieval

    /**
     Requests the IP lookup location retrieval and, if fails it uses the regional.
     */
    private func retrieveInaccurateLocation() {
        ipLookupLocationService.retrieveLocationWithCompletion {
            [weak self] (result: IPLookupLocationServiceResult) -> Void in
            if let strongSelf = self {
                // If there's no previous location it should update
                var shouldUpdateLocation = strongSelf.currentLocation == nil

                if let coordinates = result.value {
                    let newLocation = LGLocation(latitude: coordinates.latitude, longitude: coordinates.longitude,
                        type: .IPLookup)
                    strongSelf.inaccurateLocation = newLocation
                } else {
                    strongSelf.inaccurateLocation = strongSelf.retrieveRegionalLocational()
                }

                // If the current location is not the same as the one received then we notify the delegate
                shouldUpdateLocation = shouldUpdateLocation ||
                    strongSelf.currentLocation?.location != strongSelf.inaccurateLocation?.location
                if let newLocation = strongSelf.currentLocation where shouldUpdateLocation {
                    strongSelf.updateLocation(newLocation)
                }
            }
        }
    }

    /**
     Requests the regional location.
     - returns: The regional location.
     */
    private func retrieveRegionalLocational() -> LGLocation? {
        return LGLocation(coordinate: countryHelper.regionCoordinate, type: .Regional)
    }

    /**
     Retrieves the postal address for the given location and updates my user & installation.
     - parameter location: The location to retrieve the postal address from.
     - parameter completion: The completion closure, what will be called on user update.
     */
    private func retrievePostalAddressAndUpdate(location: LGLocation,
                                                completion: ((Result<MyUser, RepositoryError>) -> ())?) {

        postalAddressRetrievalService.retrieveAddressForLocation(location.location) { [weak self] result in
            let postalAddress = result.value?.postalAddress ?? PostalAddress.emptyAddress()
            self?.updateLocation(location, postalAddress: postalAddress, userUpdateCompletion: completion)
        }
    }


    // MARK: > Location update


    /**
     Updates location and postal address in my user & installation, and runs recursively if `postalAddress` is `nil`
     after retrieving it.
     - parameter location: The location.
     - parameter postalAddress: The postal address.
     - parameter userUpdateCompletion: The completion closure for `MyUser` update.
     */
    private func updateLocation(location: LGLocation, postalAddress: PostalAddress? = nil,
                                userUpdateCompletion: ((Result<MyUser, RepositoryError>) -> ())? = nil) {

        if let postalAddress = postalAddress {
            updateDeviceLocation(location, postalAddress: postalAddress)
            updateUserLocation(location, postalAddress: postalAddress, completion: userUpdateCompletion)
            handleLocationUpdate(location, postalAddress: postalAddress)
        } else {
            retrievePostalAddressAndUpdate(location, completion: userUpdateCompletion)
        }
    }

    /**
     Updates location and postal address in `DeviceLocation`.
     - parameter location: The location.
     - parameter postalAddress: The postal address.
     */
    private func updateDeviceLocation(location: LGLocation, postalAddress: PostalAddress) {
        var updatedDeviceLocation: DeviceLocation? = nil
        if let deviceLocation = dao.deviceLocation {
            if deviceLocation.shouldReplaceWithNewLocation(location) {
                updatedDeviceLocation = LGDeviceLocation(location: location, postalAddress: postalAddress)
            }
        } else {
            // If non-cached device location then create a new one
            updatedDeviceLocation = LGDeviceLocation(location: location, postalAddress: postalAddress)
        }
        if let updatedDeviceLocation = updatedDeviceLocation {
            dao.save(updatedDeviceLocation)
        }
    }

    /**
     Updates location and postal address in `MyUser`.
     - parameter location: The location.
     - parameter postalAddress: The postal address.
     - parameter completion: The completion closure.
     */
    private func updateUserLocation(location: LGLocation, postalAddress: PostalAddress,
                                    completion: ((Result<MyUser, RepositoryError>) -> ())? = nil) {

        guard let myUser = myUserRepository.myUser else {
            completion?(Result<MyUser, RepositoryError>(error: .Internal(message: "Missing MyUser objectId")))
            return
        }

        checkFarAwayMovementAndNotify(myUser: myUser, location: location)

        if myUser.shouldReplaceWithNewLocation(location, manualLocationEnabled: isManualLocationEnabled) {
            let myCompletion: (Result<MyUser, RepositoryError>) -> () = { [weak self] result in
                self?.handleLocationUpdate(location, postalAddress: postalAddress)
                completion?(result)
            }
            myUserRepository.updateLocation(location, postalAddress: postalAddress, completion: myCompletion)
        } else {
            //We're not updating location but everything is ok
            completion?(Result<MyUser, RepositoryError>(value: myUser))
        }
    }


    /**
     If the last saved location in myUser is manual, the new location is not manual and are far away enough
     then post a notification

     - parameter location: the new location
     */
    private func checkFarAwayMovementAndNotify(myUser myUser: MyUser, location: LGLocation) {
        if let myUserLocation = myUser.location where myUserLocation.type == .Manual && location.type != .Manual &&
            myUserLocation.distanceFromLocation(location) > manualLocationThreshold {

            events.onNext(.MovedFarFromSavedManualLocation)
        }
    }

    /**
     Handles a location update.
     - parameter location: The location.
     - parameter postalAddress: The postal address.s
     */
    private func handleLocationUpdate(location: LGLocation, postalAddress: PostalAddress?) {
        guard let currentLocation = currentLocation where currentLocation != lastNotifiedLocation else { return }

        lastNotifiedLocation = currentLocation
        events.onNext(.LocationUpdate)
    }


    /**
     Checks current user and updates user location if needed
     */
    private func checkUserLocationAndUpdate() {
        guard let myUser = myUserRepository.myUser else { return }

        guard let location = dao.deviceLocation?.location, postalAddress = dao.deviceLocation?.postalAddress else {
            return
        }
        if myUser.shouldReplaceWithNewLocation(location, manualLocationEnabled: isManualLocationEnabled) {
            myUserRepository.updateLocation(location, postalAddress: postalAddress, completion: nil)
        }
    }
}


// MARK: - MyUser

private extension MyUser {
    func shouldReplaceWithNewLocation(newLocation: LGLocation, manualLocationEnabled: Bool) -> Bool {
        guard let savedLocationType = location?.type else { return true }
        guard let newLocationType = newLocation.type else { return false }

        switch savedLocationType {
        case .IPLookup:
            switch newLocationType {
            case .IPLookup, .Manual, .Sensor:
                return true
            case .Regional:
                return false
            }
        case .Manual:
            switch newLocationType {
            case .Manual:
                return true
            case .IPLookup, .Sensor, .Regional:
                return !manualLocationEnabled
            }
        case .Regional:
            switch newLocationType {
            case .IPLookup:
                return false
            case .Regional, .Manual, .Sensor:
                return true
            }
        case .Sensor:
            switch newLocationType {
            case .IPLookup, .Regional:
                return false
            case .Manual, .Sensor:
                return true
            }
        }
    }
}


// MARK: - DeviceLocation

private extension DeviceLocation {
    func shouldReplaceWithNewLocation(newLocation: LGLocation) -> Bool {
        guard let savedLocationType = location?.type else { return true }
        guard let newLocationType = newLocation.type else { return false }
        
        switch savedLocationType {
        case .IPLookup:
            switch newLocationType {
            case .IPLookup, .Sensor:
                return true
            case .Manual, .Regional:
                return false
            }
        case .Manual, .Regional:
            switch newLocationType {
            case .IPLookup, .Manual:
                return false
            case .Regional, .Sensor:
                return true
            }
        case .Sensor:
            switch newLocationType {
            case .IPLookup, .Regional, .Manual:
                return false
            case .Sensor:
                return true
            }
        }
    }
}

