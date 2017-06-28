//
//  LGSearchLocationSuggestionsDataSource.swift
//  LGCoreKit
//
//  Created by Juan Iglesias on 26/06/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//


import Argo
import Result
import CoreLocation

class LGLocationDataSource: LocationDataSource {
    
    // iVars
    private var geocoder: CLGeocoder
    private var apiClient: ApiClient

    // MARK: - Lifecycle
    
    public init(apiClient: ApiClient) {
        geocoder = CLGeocoder()
        self.apiClient = apiClient
        
    }

    
    public func retrieveAddressForLocation(_ searchText: String, completion: SuggestionsLocationDataSourceCompletion?) {
        
        geocoder.geocodeAddressString(searchText, completionHandler: { (placemarks, error) -> Void in
            
            if let actualPlacemarks = placemarks {
                var suggestedResults: [Place] = []
                if !actualPlacemarks.isEmpty {
                    for placemark in actualPlacemarks {
                        suggestedResults.append(placemark.place())
                    }
                }
                completion?(SuggestionsLocationDataSourceResult(value: suggestedResults))
            }
                // Error
            else if let actualError = error {
                if actualError._code == CLError.Code.geocodeFoundNoResult.rawValue {
                    completion?(SuggestionsLocationDataSourceResult(error: .notFound))
                } else {
                    completion?(SuggestionsLocationDataSourceResult(error: .network))
                }
            }
            else {
                completion?(SuggestionsLocationDataSourceResult(error: .internalError))
            }
        })
    }
    
    func retrieveAddressForLocation(_ location: LGLocationCoordinates2D, completion: PostalAddressLocationDataSourceCompletion?) {
        
        let location = CLLocation(latitude: location.latitude, longitude: location.longitude)
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) -> Void in
            // Success
            if let actualPlacemarks = placemarks {
                var place = Place()
                if !actualPlacemarks.isEmpty {
                    let placemark = actualPlacemarks.last!
                    place = placemark.place()
                }
                completion?(PostalAddressLocationDataSourceResult(value: place))
            }
                // Error
            else if let _ = error {
                completion?(PostalAddressLocationDataSourceResult(error: .network))
            }
            else {
                completion?(PostalAddressLocationDataSourceResult(error: .internalError))
            }
        }
    }
    
    func retrieveLocationWithCompletion(_ completion: IPLookupLocationDataSourceCompletion?) {
        
        let request = LocationRouter.ipLookup
        apiClient.request(request, decoder: LGLocationDataSource.decoder) {
            (result: Result<LGLocationCoordinates2D, ApiError>) -> () in
            
            if let value = result.value {
                completion?(IPLookupLocationDataSourceResult(value: value))
            } else if let error = result.error {
                completion?(IPLookupLocationDataSourceResult(error: IPLookupLocationError(apiError: error)))
            }
        }
    }
    
    static func decoder(_ object: Any) -> LGLocationCoordinates2D? {
        guard let theLocation : LGLocationCoordinates2D = LGArgo.jsonToCoordinates(JSON(object),
                                                                                   latKey: "latitude", lonKey: "longitude").value else {
                                                                                    return nil
        }
        return theLocation
    }
}
