//
//  CLLocationRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import CoreLocation
import Result

public class LGLocationRepository: LocationRepository {

    let dataSource: LocationDataSource
    var clLocationManager: CLLocationManagerProtocol

    
    // MARK: - Lifecycle

    public init(dataSource: LocationDataSource, locationManager: CLLocationManagerProtocol) {
        self.dataSource = dataSource
        self.clLocationManager = locationManager
    }

    // MARK: - Public Methods.
    
    public var distance: CLLocationDistance {
        get {
            return clLocationManager.distanceFilter
        }
        set {
            clLocationManager.distanceFilter = newValue
        }
    }
    public var accuracy: CLLocationDistance {
        get {
            return clLocationManager.desiredAccuracy
        }
        set {
            clLocationManager.desiredAccuracy = newValue
        }
    }
    public var lastKnownLocation: CLLocation? {
        get {
            return clLocationManager.location
        }
    }
    
    public func setLocationManagerDelegate(delegate: CLLocationManagerDelegate) {
        clLocationManager.delegate = delegate
    }
    
    public func locationEnabled() -> Bool {
        return CLLocationManager.locationServicesEnabled()
    }
    
    public func authorizationStatus() -> CLAuthorizationStatus {
        return CLLocationManager.authorizationStatus()
    }
    
    public func requestWhenInUseAuthorization() {
        clLocationManager.requestWhenInUseAuthorization()
    }
    
    public func requestAlwaysAuthorization() {
        clLocationManager.requestAlwaysAuthorization()
    }
    
    public func startUpdatingLocation() {
        clLocationManager.startUpdatingLocation()
    }
    
    public func stopUpdatingLocation() {
        clLocationManager.stopUpdatingLocation()
    }

    public func retrieveAddressForLocation(_ searchText: String, completion: SuggestionsLocationRepositoryCompletion?) {

        dataSource.retrieveAddressForLocation(searchText) { (result) in
            if let value = result.value {
                completion?(SuggestionsLocationRepositoryResult(value: value))
                
            } else if let error = result.error {
                completion?(SuggestionsLocationRepositoryResult(error: error))
            }
        }
    }
    
    public func retrieveAddressForLocation(_ coordinates: LGLocationCoordinates2D, completion: PostalAddressLocationRepositoryCompletion?) {
        dataSource.retrieveAddressForLocation(coordinates) { (result) in
            if let value = result.value {
                completion?(PostalAddressLocationRepositoryResult(value: value))
                
            } else if let error = result.error {
                completion?(PostalAddressLocationRepositoryResult(error: error))
            }
        }
    }
    
    public func retrieveLocationWithCompletion(_ completion: IPLookupLocationRepositoryCompletion?) {
        dataSource.retrieveLocationWithCompletion { (result) in
            if let value = result.value {
                completion?(IPLookupLocationRepositoryResult(value: value))
                
            } else if let error = result.error {
                completion?(IPLookupLocationRepositoryResult(error: error))
            }
        }
    }
}

