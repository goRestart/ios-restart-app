//
//  EditUserLocationViewModel.swift
//  LetGo
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result


public protocol EditUserLocationViewModelDelegate: class {
    func viewModelDidStartSearchingLocation(viewModel: EditUserLocationViewModel)
    func viewModel(viewModel: EditUserLocationViewModel, updateTextFieldWithString locationName: String)
    func viewModel(viewModel: EditUserLocationViewModel, updateSearchTableWithResults results: [String])
    func viewModelDidFailFindingSuggestions(viewModel: EditUserLocationViewModel)
    func viewModel(viewModel: EditUserLocationViewModel, didFailToFindLocationWithResult result: Result<[Place], SearchLocationSuggestionsServiceError>)
    func viewModel(viewModel: EditUserLocationViewModel, centerMapInLocation location: CLLocationCoordinate2D, withPostalAddress postalAddress: PostalAddress?, approximate: Bool)
}

public class EditUserLocationViewModel: BaseViewModel {
   
    public weak var delegate : EditUserLocationViewModelDelegate?
    
    private let searchService : CLSearchLocationSuggestionsService
    private let postalAddressService : PostalAddressRetrievalService
    
    let geocoder = CLGeocoder()

    var approximateLocation : Bool      // user wants approximate location (not accurate) changes thw way the info in the map is showed
    var goingToLocation : Bool          // while map is moving to show a location, no call to suggestions is made
    var usingGPSLocation : Bool         // user uses GPS location
    var serviceAlreadyLoading : Bool    // if the service is already waiting for a response, we don't launch another request
    var predictiveResults : [Place]
    var currentPlace : Place
    
    var searchText : String {
        didSet {
            if !goingToLocation {
                self.resultsForSearchText()
            }
        }
    }
    
    // MARK: -Lifecycle
    
    override init() {
        searchText = ""
        approximateLocation =  UserDefaultsManager.sharedInstance.loadIsApproximateLocation()
        goingToLocation = false
        serviceAlreadyLoading = false
        usingGPSLocation = !LocationManager.sharedInstance.isManualLocation
        predictiveResults = []
        currentPlace = Place()
        searchService = CLSearchLocationSuggestionsService()
        postalAddressService = CLPostalAddressRetrievalService()
        super.init()
    }
    
    // MARK: public methods
    
    
    func placeResumedDataAtPosition(position: Int) -> String? {
        
        if let resumedData = predictiveResults[position].placeResumedData {
            return resumedData
        }
        return nil
    }
    
    func locationForPlaceAtPosition(position: Int) -> LGLocationCoordinates2D? {
        if let location = predictiveResults[position].location {
            return location
        }
        return nil
    }

    func postalAddressForPlaceAtPosition(position: Int) -> PostalAddress? {
        if let postalAddress = predictiveResults[position].postalAddress {
            return postalAddress
        }
        return nil
    }

    /**
        Map goes to user current location when view loads
    */
    
    func showInitialUserLocation() {
        goingToLocation = true
        var user = MyUserManager.sharedInstance.myUser()
        if let location = user?.gpsCoordinates {
            delegate?.viewModel(self, updateTextFieldWithString: "")
            var place = Place()
            place.postalAddress = user?.postalAddress
            place.location = location
            self.currentPlace = place
            var userLocationString = ""
            
            // address, zip code, city, country
            
            if !approximateLocation {
                if let address = place.postalAddress!.address {
                    userLocationString += address
                }
            }
            if let zipCode = place.postalAddress!.zipCode {
                if !userLocationString.isEmpty {
                    userLocationString += ", "
                }
                userLocationString += zipCode
            }
            if let city = place.postalAddress!.city {
                if !userLocationString.isEmpty {
                    userLocationString += ", "
                }
                userLocationString += city
            }
            if let country = place.postalAddress!.countryCode {
                if !userLocationString.isEmpty {
                    userLocationString += ", "
                }
                userLocationString += country
            }
            delegate?.viewModel(self, updateTextFieldWithString: userLocationString)
            var lat = location.latitude as CLLocationDegrees
            var long = location.longitude as CLLocationDegrees
            var coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            delegate?.viewModel(self, centerMapInLocation: coordinate, withPostalAddress: place.postalAddress, approximate: self.approximateLocation)
        }
        
        goingToLocation = false
    }
    
    /**
        when user taps GPS button, map goes to user last GPS location
    */
    
    func showGPSUserLocation() {
        goingToLocation = true
        usingGPSLocation = true

        if !serviceAlreadyLoading {
            serviceAlreadyLoading = true
            delegate?.viewModelDidStartSearchingLocation(self)
            postalAddressService.retrieveAddressForLocation(LocationManager.sharedInstance.lastGPSLocation!) { [weak self] (result: Result<PostalAddress, PostalAddressRetrievalServiceError>) -> Void in
                if let strongSelf = self {
                    if let actualDelegate = strongSelf.delegate {
                        if let postalAddress = result.value {
                            actualDelegate.viewModel(strongSelf, centerMapInLocation: LocationManager.sharedInstance.lastGPSLocation!.coordinate, withPostalAddress: postalAddress, approximate: strongSelf.approximateLocation)
                            var userLocationString = ""
                            if let zipCode = postalAddress.zipCode {
                                userLocationString += zipCode
                            }
                            if let city = postalAddress.city {
                                if !userLocationString.isEmpty {
                                    userLocationString += ", "
                                }
                                userLocationString += city
                            }
                            actualDelegate.viewModel(strongSelf, updateTextFieldWithString: userLocationString)
                            
                            var place = Place()
                            place.postalAddress = postalAddress
                            place.location = LGLocationCoordinates2D(coordinates: LocationManager.sharedInstance.lastGPSLocation!.coordinate)
                            strongSelf.currentPlace = place
                        }
                    }
                    strongSelf.serviceAlreadyLoading = false
                }
            }
        }
    }
    
    /**
        Search for suggestions for the user search
    */
    
    func resultsForSearchText() {

        if !serviceAlreadyLoading {
            serviceAlreadyLoading = true
            searchService.retrieveAddressForLocation(self.searchText) { [weak self] (suggestionsResult: Result<[Place], SearchLocationSuggestionsServiceError>) -> Void in
                
                if let strongSelf = self {
                    if let actualDelegate = strongSelf.delegate {
                        if let suggestions = suggestionsResult.value {
                            // success!
                            self?.predictiveResults = suggestions
                            var suggestionsStrings : [String] = []
                            for place in suggestions {
                                suggestionsStrings.append(place.placeResumedData!)
                            }
                            actualDelegate.viewModel(strongSelf, updateSearchTableWithResults: suggestionsStrings)
                        } else {
                            actualDelegate.viewModelDidFailFindingSuggestions(strongSelf)
                        }
                    }
                    strongSelf.serviceAlreadyLoading = false
                }
            }
        }
        
    }
    
    /**
        Launches the search for a location written by the user (or selected from the suggestions table)
    */

    
    func goToLocation() {
        usingGPSLocation = false
        
        if !serviceAlreadyLoading {
            serviceAlreadyLoading = true
            delegate?.viewModelDidStartSearchingLocation(self)
            searchService.retrieveAddressForLocation(self.searchText) { [weak self](result: Result<[Place], SearchLocationSuggestionsServiceError>) -> Void in
                if let strongSelf = self {
                    if let actualDelegate = strongSelf.delegate {
                        if let places = result.value, let place = places.first, let location = place.location {
                            var coordinate = location.coordinates2DfromLocation()
                            strongSelf.currentPlace = place
                            actualDelegate.viewModel(strongSelf, centerMapInLocation: coordinate, withPostalAddress: place.postalAddress, approximate: strongSelf.approximateLocation)
                        }
                        else {
                            actualDelegate.viewModel(strongSelf, didFailToFindLocationWithResult: result)
                        }
                    }
                    strongSelf.serviceAlreadyLoading = false
                }
            }
        }
    }

    
    /**
        Manages the change in the view when the user switches from aproxximate to accurate
    */
    
    func updateApproximateSwitchChanged() {
        
        if let location = currentPlace.location {
            var coordinate = location.coordinates2DfromLocation()
            delegate?.viewModel(self, centerMapInLocation: coordinate, withPostalAddress: currentPlace.postalAddress, approximate: self.approximateLocation)
        }
    }


    /**
        Saves the user location
    */

    func applyLocation() {

        UserDefaultsManager.sharedInstance.saveIsApproximateLocation(approximateLocation)

        if let actualPostalAddress = currentPlace.postalAddress {
            var user = MyUserManager.sharedInstance.myUser()
            user?.postalAddress = actualPostalAddress
        }
        
        if usingGPSLocation {
            LocationManager.sharedInstance.gpsDidSetLocation()
        } else {
            var lat = currentPlace.location!.latitude as CLLocationDegrees
            var long = currentPlace.location!.longitude as CLLocationDegrees
            var location = CLLocation(latitude: lat, longitude: long)
            LocationManager.sharedInstance.userDidSetLocation(location)
        }
    }
    
}
