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
    
    // setup view controller when view loads.
    
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
            
            // dirección, zip code ciudad, país
            
            if !approximateLocation {
                if let address = place.postalAddress!.address {
                    userLocationString += address
                }
            }
            if let zipCode = place.postalAddress!.zipCode {
                if count(userLocationString) > 0 {
                    userLocationString += ", "
                }
                userLocationString += zipCode
            }
            if let city = place.postalAddress!.city {
                if count(userLocationString) > 0 {
                    userLocationString += ", "
                }
                userLocationString += city
            }
            if let country = place.postalAddress!.countryCode {
                if count(userLocationString) > 0 {
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
    
    // user taps GPS button
    
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
                                if count(userLocationString) > 0 {
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
    
    // ask for suggestions list
    
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
                        }
                    }
                    strongSelf.serviceAlreadyLoading = false
                }
            }
        }
        
    }
    
    // launches the search for a location wrtitten by the user (or selected from the suggestions table)
    
    func goToLocation() {
        usingGPSLocation = false
       
        if !serviceAlreadyLoading {
            serviceAlreadyLoading = true
            delegate?.viewModelDidStartSearchingLocation(self)
            searchService.goToLocation(self.searchText) { [weak self](result: Result<[Place], SearchLocationSuggestionsServiceError>) -> Void in
                if let strongSelf = self {
                    if let actualDelegate = strongSelf.delegate {
                        if let places = result.value, let place = places.first, let location = place.location {
                            var lat = location.latitude as CLLocationDegrees
                            var long = location.longitude as CLLocationDegrees
                            var coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
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
    
    
    func updateApproximateSwitchChanged() {
        
        if let location = currentPlace.location {
            var lat = location.latitude as CLLocationDegrees
            var long = location.longitude as CLLocationDegrees
            var coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            delegate?.viewModel(self, centerMapInLocation: coordinate, withPostalAddress: currentPlace.postalAddress, approximate: self.approximateLocation)
        }
    }

    func applyLocation() {

        UserDefaultsManager.sharedInstance.saveIsApproximateLocation(approximateLocation)
        
        // save the city to update cell in settings view
        if let city = currentPlace.postalAddress?.city {
            UserDefaultsManager.sharedInstance.saveUserCity(city)
        }
        
        if usingGPSLocation {
            LocationManager.sharedInstance.gpsSettedLocation()
        } else {
            var lat = currentPlace.location!.latitude as CLLocationDegrees
            var long = currentPlace.location!.longitude as CLLocationDegrees
            var location = CLLocation(latitude: lat, longitude: long)
            LocationManager.sharedInstance.userSettedLocation(location)
        }
    }
    
}
