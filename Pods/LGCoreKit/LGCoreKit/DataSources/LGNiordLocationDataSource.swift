//
//  LGNiordLocationDataSource.swift
//  LGCoreKit
//
//  Created by Nestor on 16/08/2017.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result
import CoreLocation

class LGNiordLocationDataSource: LocationDataSource {
    
    private var apiClient: ApiClient
    private let locale: Locale
    
    // MARK: - Lifecycle
    
    init(apiClient: ApiClient, locale: Locale) {
        self.apiClient = apiClient
        self.locale = locale
    }
    
    // MARK: - LocationDataSource
    
    func retrieveLocationSuggestions(addressString: String,
                                     region: CLCircularRegion?,
                                     completion: SuggestionsLocationDataSourceCompletion?) {
        var params: [String: Any] = ["input": addressString,
                                     "language": locale.languageCode ?? LGCoreKitConstants.defaultLanguageCode,
                                     "types": "geocode"]
        if let region = region {
            params["location"] = "\(region.center.latitude),\(region.center.longitude)"
            params["radius"] = Int(LGCoreKitConstants.geocodeRegionRadius)
        }
        let request = NiordRouter.autocomplete(params: params)
        apiClient.request(request, decoder: LGNiordLocationDataSource.locationSuggestionDecoder) { result in
            if let places = result.value {
                completion?(SuggestionsLocationDataSourceResult(value: places))
            } else {
                completion?(SuggestionsLocationDataSourceResult(error: .internalError))
            }
        }
    }
    
    func retrievePostalAddress(location: LGLocationCoordinates2D,
                               completion: PostalAddressLocationDataSourceCompletion?) {
        let params: [String: Any] = ["latlng": "\(location.latitude),\(location.longitude)",
                                     "language": locale.languageCode ?? LGCoreKitConstants.defaultLanguageCode]
        let request = NiordRouter.geocode(params: params)
        apiClient.request(request, decoder: LGNiordLocationDataSource.postalAddressDecoder) { result in
            if let place = result.value {
                completion?(PostalAddressLocationDataSourceResult(value: place))
            } else {
                completion?(PostalAddressLocationDataSourceResult(error: .internalError))
            }
        }
    }
    
    func retrieveLocationSuggestionDetails(placeId: String,
                                           completion: SuggestionLocationDetailsDataSourceCompletion?) {
        let request = NiordRouter.geocodeDetails(params: ["placeid": placeId])
        apiClient.request(request, decoder: LGNiordLocationDataSource.postalAddressDetailsDecoder) { result in
            if let place = result.value {
                completion?(LocationSuggestionDetailsDataSourceResult(value: place))
            } else {
                completion?(LocationSuggestionDetailsDataSourceResult(error: .internalError))
            }
        }
    }
    
    // MARK: - Helpers
    
    static func locationSuggestionDecoder(_ object: Any) -> [Place]? {
        guard let dict = object as? [String : Any] else {
            logAndReportParseError(object: object, entity: .places,
                                   comment: "root not a [String: Any]")
            return nil
        }
        
        guard let predictionsDicts = dict["predictions"] as? [[String: Any]] else {
            logAndReportParseError(object: object, entity: .places,
                                   comment: "missing predictions key or value not a [[String: Any]]")
            return nil
        }
        
        var places: [Place] = []
        predictionsDicts.forEach { prediction in
            if let description = prediction["description"] as? String,
                let placeId = prediction["place_id"] as? String {
                places.append(Place(placeId: placeId, placeResumedData: description))
            } else {
                logAndReportParseError(object: object, entity: .place,
                                       comment: "missing description or place_id key")
            }
        }
        return places
    }
    
    static func postalAddressDecoder(_ object: Any) -> Place? {
        guard let dict = object as? [String: Any] else {
            logAndReportParseError(object: object, entity: .place,
                                   comment: "root not a [String: Any]")
            return nil
        }
        guard let results = dict["results"] as? [[String: Any]] else {
            logAndReportParseError(object: object, entity: .place,
                                   comment: "missing results key or value not a [[String: Any]]")
            return nil
            
        }
        guard let firstResult = results.first else {
            logAndReportParseError(object: object, entity: .place,
                                   comment: "empty results array")
            return nil
            
        }
        let place = LGNiordLocationDataSource.decodeNiordPlace(niordDictionary: firstResult)
        return place
    }
    
    private static func postalAddressDetailsDecoder(_ object: Any) -> Place? {
        guard let dict = object as? [String: Any] else {
            logAndReportParseError(object: object, entity: .placeDetails,
                                   comment: "root not a [String: Any]")
            return nil
        }
        guard let result = dict["result"] as? [String: Any] else {
            logAndReportParseError(object: object, entity: .placeDetails,
                                   comment: "missing result key or value not a [String: Any]")
            return nil
        }
        let place = LGNiordLocationDataSource.decodeNiordPlace(niordDictionary: result)
        return place
    }
    
    private static func decodeNiordPlace(niordDictionary dict: [String: Any]) -> Place {
        var place = Place()
        if let geometry = dict["geometry"] as? [String: Any],
            let locationValue = geometry["location"] as? [String: Any],
            let latitude = locationValue["lat"] as? Double,
            let longitude = locationValue["lng"] as? Double {
            place.location = LGLocationCoordinates2D(latitude: latitude, longitude: longitude)
        }
        var formattedAddress: String?
        if let formattedAddressValue = dict["formatted_address"] as? String {
            formattedAddress = formattedAddressValue
        }
        var city: String?
        var zipCode: String?
        var state: String?
        var countryCode: String?
        var country: String?
        if let addressComponents = dict["address_components"] as? [[String: Any]] {
            for addressComponent in addressComponents {
                guard let types = addressComponent["types"] as? [String] else { continue }
                if types.contains("country"),
                    let countryValue = addressComponent["long_name"] as? String,
                    let countryCodeValue = addressComponent["short_name"] as? String {
                    country = countryValue
                    countryCode = countryCodeValue
                }
                if types.contains("postal_code"),
                    let zipCodeValue = addressComponent["short_name"] as? String {
                    zipCode = zipCodeValue
                }
                if types.contains("administrative_area_level_1"),
                    let stateValue = addressComponent["short_name"] as? String {
                    state = stateValue
                }
                if types.contains("locality"),
                    let cityValue = addressComponent["short_name"] as? String {
                    city = cityValue
                }
            }
        }
        place.postalAddress = PostalAddress(address: formattedAddress,
                                            city: city,
                                            zipCode: zipCode,
                                            state: state,
                                            countryCode: countryCode,
                                            country: country)
        place.placeResumedData = formattedAddress
        return place
    }
}
