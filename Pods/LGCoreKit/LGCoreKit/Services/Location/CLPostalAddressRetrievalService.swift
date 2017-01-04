//
//  CLPostalAddressRetrievalService.swift
//  LGCoreKit
//
//  Created by Albert Hernández López on 11/05/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

import AddressBookUI
import CoreLocation
import Result

public class CLPostalAddressRetrievalService: PostalAddressRetrievalService {
    private var geocoder: CLGeocoder


    // MARK: - Lifecycle

    public init() {
        self.geocoder = CLGeocoder()
    }


    // MARK: - PostalAddressRetrievalService

    public func retrieveAddressForLocation(_ coordinates: LGLocationCoordinates2D, completion: PostalAddressRetrievalServiceCompletion?) {
        let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            // Success
            if let actualPlacemarks = placemarks {
                var place = Place()
                if !actualPlacemarks.isEmpty {
                    let placemark = actualPlacemarks.last!
                    place = placemark.place()
                }
                completion?(PostalAddressRetrievalServiceResult(value: place))
            }
            // Error
            else if let _ = error {
                completion?(PostalAddressRetrievalServiceResult(error: .network))
            }
            else {
                completion?(PostalAddressRetrievalServiceResult(error: .internalError))
            }
        }
    }
}
