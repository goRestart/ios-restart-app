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
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        case .restricted, .denied, .notDetermined:
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
    
    func observeSessionManager(_ sessionManager: SessionManager) {
        sessionDisposeBag = DisposeBag()
        sessionManager.sessionEvents.subscribeNext { [weak self] event in
            switch event {
            case .login:
                self?.setup()
                self?.checkUserLocationAndUpdate()
            case .logout:
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
        if let userLocation = myUserRepository.myUser?.location, userLocation.type == .manual {
            return userLocation
        }
        if let deviceLocation = dao.deviceLocation?.location, deviceLocation.type == .sensor {
            return deviceLocation
        }
        if let userLocation = myUserRepository.myUser?.location { return userLocation }
        return  dao.deviceLocation?.location
        
    }
    
    /**
     Returns the best accurate automatic location.
     */
    var currentAutoLocation: LGLocation? {
        return dao.deviceLocation?.location
    }
    
    
    /**
     Sets the given location as manual.
     - parameter location: The location.
     - parameter postalAddress: The postal address.
     - parameter userUpdateCompletion: The `MyUser` update completion closure.
     */
    func setManualLocation(_ location: CLLocation, postalAddress: PostalAddress,
                           completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        guard let lgLocation = LGLocation(location: location, type: .manual, postalAddress: postalAddress) else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Invalid CLLocation")))
            return
        }
        isManualLocationEnabled = true
        
        updateLocation(lgLocation, userUpdateCompletion: completion)
    }
    
    /**
     Sets the location as automatic.
     - parameter userUpdateCompletion: The `MyUser` update completion closure.
     */
    func setAutomaticLocation(_ userUpdateCompletion: ((Result<MyUser, RepositoryError>) -> ())?) {
        isManualLocationEnabled = false
        
        guard let currentAutoLocation = currentAutoLocation else { return }
        updateLocation(currentAutoLocation, userUpdateCompletion: userUpdateCompletion)
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
        return sensorLocationService.authorizationStatus() == .notDetermined
    }
    
    /*
     Warning, this method will be called on app launch because it's called when the CLLOcationManager it's initialized.
     */
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        defer { dao.save(status) }
        
        if didAcceptPermissions {
            _ = startSensorLocationUpdates()
        }
        
        // Only notify if there really is a change in the auth status, not always
        guard let currentStatus = dao.locationStatus, currentStatus != status else { return }
        
        events.onNext(.changedPermissions)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        
        // there is no postalAddress at that point, it will update on updateLocation
        let newLocation = LGLocation(location: lastLocation, type: .sensor, postalAddress: nil)
        guard let location = newLocation else { return }
        
        updateLocation(location)
    }
    
    
    // MARK: - Private methods
    
    // MARK: > Setup
    
    /**
     Setup.
     */
    private func setup() {
        isManualLocationEnabled = myUserRepository.myUser?.location?.type == .manual
    }
    
    
    // MARK: > Innacurate location & address retrieval
    
    /**
     Requests the IP lookup location retrieval and, if fails it uses the regional.
     */
    private func retrieveInaccurateLocation() {
        guard currentLocation == nil else { return }
        ipLookupLocationService.retrieveLocationWithCompletion { [weak self] (result: IPLookupLocationServiceResult) -> Void in
            if let strongSelf = self {
                guard strongSelf.currentLocation == nil else { return }
                // If there's no previous location it should update
                var newLocation: LGLocation? = nil
                if let coordinates = result.value {
                    newLocation = LGLocation(latitude: coordinates.latitude, longitude: coordinates.longitude,
                                             type: .ipLookup, postalAddress: nil)
                } else {
                    newLocation = strongSelf.retrieveRegionalLocational()
                }
                if let location = newLocation { strongSelf.updateLocation(location) }
            }
        }
    }
    
    /**
     Requests the regional location.
     - returns: The regional location.
     */
    private func retrieveRegionalLocational() -> LGLocation? {
        return LGLocation(coordinate: countryHelper.regionCoordinate, type: .regional, postalAddress: nil)
    }
    
    /**
     Retrieves the postal address for the given location and updates my user & installation.
     - parameter location: The location to retrieve the postal address from.
     - parameter completion: The completion closure, what will be called on user update.
     */
    private func retrievePostalAddressAndUpdate(_ location: LGLocation,
                                                completion: ((Result<MyUser, RepositoryError>) -> ())?) {
        
        postalAddressRetrievalService.retrieveAddressForLocation(location.location) { [weak self] result in
            let postalAddress = result.value?.postalAddress ?? PostalAddress.emptyAddress()
            let newLocation = location.updating(postalAddress: postalAddress)
            self?.updateLocation(newLocation, userUpdateCompletion: completion)
        }
    }
    
    
    // MARK: > Location update
    
    
    /**
     Updates location and postal address in my user & installation, and runs recursively if `postalAddress` is `nil`
     after retrieving it.
     - parameter location: The location.
     - parameter userUpdateCompletion: The completion closure for `MyUser` update.
     */
    private func updateLocation(_ location: LGLocation,
                                userUpdateCompletion: ((Result<MyUser, RepositoryError>) -> ())? = nil) {
        
        if let _ = location.postalAddress {
            let deviceLocationUpdated = updateDeviceLocation(location)
            let userLocationUpdated = updateUserLocation(location, completion: userUpdateCompletion)
            if deviceLocationUpdated || userLocationUpdated {
                handleLocationUpdate()
            }
        } else {
            retrievePostalAddressAndUpdate(location, completion: userUpdateCompletion)
        }
    }
    
    /**
     Updates location and postal address in `DeviceLocation`.
     - parameter location: The location.
     */
    private func updateDeviceLocation(_ location: LGLocation) -> Bool {
        var updatedDeviceLocation: DeviceLocation? = nil
        var willUpdateDeviceLocation = false
        if let deviceLocation = dao.deviceLocation {
            if deviceLocation.shouldReplaceWithNewLocation(location) {
                updatedDeviceLocation = LGDeviceLocation(location: location)
            }
        } else {
            // If non-cached device location then create a new one
            updatedDeviceLocation = LGDeviceLocation(location: location)
        }
        if let updatedDeviceLocation = updatedDeviceLocation {
            dao.save(updatedDeviceLocation)
            willUpdateDeviceLocation = true
        }
        return willUpdateDeviceLocation
    }
    
    /**
     Updates location and postal address in `MyUser`.
     - parameter location: The location.
     - parameter completion: The completion closure.
     */
    private func updateUserLocation(_ location: LGLocation,
                                    completion: ((Result<MyUser, RepositoryError>) -> ())? = nil) -> Bool {
        var willUpdateUserLocation = false
        guard let myUser = myUserRepository.myUser else {
            completion?(Result<MyUser, RepositoryError>(error: .internalError(message: "Missing MyUser objectId")))
            return willUpdateUserLocation
        }
        
        checkFarAwayMovementAndNotify(myUser: myUser, location: location)
        
        if myUser.shouldReplaceWithNewLocation(location, manualLocationEnabled: isManualLocationEnabled) {
            willUpdateUserLocation = true
            let myCompletion: (Result<MyUser, RepositoryError>) -> () = { [weak self] result in
                self?.handleLocationUpdate()
                completion?(result)
            }
            myUserRepository.updateLocation(location, completion: myCompletion)
        } else {
            //We're not updating location but everything is ok
            completion?(Result<MyUser, RepositoryError>(value: myUser))
            willUpdateUserLocation = false
        }
        return willUpdateUserLocation
    }
    
    
    /**
     If the last saved location in myUser is manual, the new location is not manual and are far away enough
     then post a notification
     - parameter location: the new location
     */
    private func checkFarAwayMovementAndNotify(myUser: MyUser, location: LGLocation) {
        if let myUserLocation = myUser.location, myUserLocation.type == .manual && location.type != .manual &&
            myUserLocation.distanceFromLocation(location) > manualLocationThreshold {
            
            events.onNext(.movedFarFromSavedManualLocation)
        }
    }
    
    /**
     Handles a location update.
     */
    private func handleLocationUpdate() {
        guard let currentLocation = currentLocation, currentLocation != lastNotifiedLocation else { return }
        
        lastNotifiedLocation = currentLocation
        events.onNext(.locationUpdate)
    }
    
    
    /**
     Checks current user and updates user location if needed
     */
    private func checkUserLocationAndUpdate() {
        guard let myUser = myUserRepository.myUser else { return }
        
        guard let location = dao.deviceLocation?.location, let _ = dao.deviceLocation?.postalAddress else {
            return
        }
        if myUser.shouldReplaceWithNewLocation(location, manualLocationEnabled: isManualLocationEnabled) {
            myUserRepository.updateLocation(location, completion: nil)
        }
    }
}


// MARK: - MyUser

private extension MyUser {
    func shouldReplaceWithNewLocation(_ newLocation: LGLocation, manualLocationEnabled: Bool) -> Bool {
        guard let savedLocationType = location?.type else { return true }
        guard let newLocationType = newLocation.type else { return false }
        
        switch savedLocationType {
        case .ipLookup:
            switch newLocationType {
            case .ipLookup, .manual, .sensor:
                return true
            case .regional:
                return false
            }
        case .manual:
            switch newLocationType {
            case .manual:
                return true
            case .ipLookup, .sensor, .regional:
                return !manualLocationEnabled
            }
        case .regional:
            switch newLocationType {
            case .ipLookup:
                return false
            case .regional, .manual, .sensor:
                return true
            }
        case .sensor:
            switch newLocationType {
            case .ipLookup, .regional:
                return false
            case .manual, .sensor:
                return true
            }
        }
    }
}


// MARK: - DeviceLocation

private extension DeviceLocation {
    func shouldReplaceWithNewLocation(_ newLocation: LGLocation) -> Bool {
        guard let savedLocationType = location?.type else { return true }
        guard let newLocationType = newLocation.type else { return false }
        
        switch savedLocationType {
        case .ipLookup:
            switch newLocationType {
            case .ipLookup, .sensor:
                return true
            case .manual, .regional:
                return false
            }
        case .manual, .regional:
            switch newLocationType {
            case .ipLookup, .manual:
                return false
            case .regional, .sensor:
                return true
            }
        case .sensor:
            switch newLocationType {
            case .ipLookup, .regional, .manual:
                return false
            case .sensor:
                return true
            }
        }
    }
}

