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
    func viewModel(viewModel: EditUserLocationViewModel, didFailToFindLocationWithResult
        result: SearchLocationSuggestionsServiceResult)
    func viewModel(viewModel: EditUserLocationViewModel, centerMapInLocation location: CLLocationCoordinate2D,
        withPostalAddress postalAddress: PostalAddress?, approximate: Bool)
    func viewModelDidStartApplyingLocation(viewModel: EditUserLocationViewModel)
    func viewModelDidApplyLocation(viewModel: EditUserLocationViewModel)
    func viewModelDidFailApplyingLocation(viewModel: EditUserLocationViewModel)
}

public class EditUserLocationViewModel: BaseViewModel {
   
    public weak var delegate : EditUserLocationViewModelDelegate?
    
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    
    private let searchService : CLSearchLocationSuggestionsService
    private let postalAddressService : PostalAddressRetrievalService
    
    let geocoder = CLGeocoder()

    var approximateLocation : Bool      // user wants approximate location (not accurate) changes thw way the info in the map is showed
    var goingToLocation : Bool          // while map is moving to show a location, no call to suggestions is made
    var usingGPSLocation : Bool         // user uses GPS location
    var serviceAlreadyLoading : Bool    // if the service is already waiting for a response, we don't launch another request
    var pendingGoToLocation : Bool      // In case goToLocation was called while serviceAlreadyLoading
    var predictiveResults : [Place]
    var currentPlace : Place
    
    var searchText : String {
        didSet {
            if !goingToLocation {
                self.resultsForSearchText()
            }
        }
    }
    
    // MARK: - Lifecycle

    override convenience init() {
        let locationManager = Core.locationManager
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(locationManager: locationManager, myUserRepository: myUserRepository, tracker: tracker)
    }

    init(locationManager: LocationManager, myUserRepository: MyUserRepository, tracker: Tracker) {
        self.locationManager = locationManager
        self.myUserRepository = myUserRepository
        self.tracker = tracker
        
        self.searchText = ""
        self.approximateLocation = locationManager.currentLocation?.type != .Sensor &&
            locationManager.currentLocation?.type != .Manual
        self.goingToLocation = false
        self.serviceAlreadyLoading = false
        self.pendingGoToLocation = false
        self.usingGPSLocation = locationManager.currentLocation?.type != .Manual
        
        self.predictiveResults = []
        self.currentPlace = Place.newPlace()
        self.searchService = CLSearchLocationSuggestionsService()
        self.postalAddressService = CLPostalAddressRetrievalService()
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

        if let myUser = myUserRepository.myUser, let location = myUser.location {
            delegate?.viewModel(self, updateTextFieldWithString: "")

            let place = Place(postalAddress: myUser.postalAddress, location:LGLocationCoordinates2D(location: location))
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
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            delegate?.viewModel(self, centerMapInLocation: coordinate, withPostalAddress: place.postalAddress,
                approximate: self.approximateLocation)
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
            if let location = locationManager.currentAutoLocation {
            
                // Notify
                delegate?.viewModelDidStartSearchingLocation(self)
                
                // Retrieve the address
                serviceAlreadyLoading = true
                postalAddressService.retrieveAddressForLocation(location.location) {
                    [weak self] (result: PostalAddressRetrievalServiceResult) -> Void in

                    if let strongSelf = self {
                        if let actualDelegate = strongSelf.delegate {
                            if let place = result.value, let postalAddress = place.postalAddress {
                                actualDelegate.viewModel(strongSelf, centerMapInLocation: location.coordinate,
                                    withPostalAddress: postalAddress, approximate: strongSelf.approximateLocation)
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
                                
                                strongSelf.currentPlace = place
                            }
                        }
                        strongSelf.serviceAlreadyLoading = false
                    }
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
            searchService.retrieveAddressForLocation(self.searchText) {
                [weak self] (suggestionsResult: SearchLocationSuggestionsServiceResult) -> Void in
                
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
                    
                    //Make the pending call
                    if strongSelf.pendingGoToLocation {
                        strongSelf.goToLocation(0)
                    }
                }
            }
        }
    }
    
    /**
        Launches the search for a location written by the user (or selected from the suggestions table)
    */

    func goToLocation(resultsIndex: Int?) {
        usingGPSLocation = false
        pendingGoToLocation = false

        if let resultsIndex = resultsIndex where resultsIndex >= 0 && resultsIndex < predictiveResults.count {
            setPlace(predictiveResults[resultsIndex])
            return
        }

        if !serviceAlreadyLoading {
            serviceAlreadyLoading = true
            delegate?.viewModelDidStartSearchingLocation(self)
            searchService.retrieveAddressForLocation(self.searchText) {
                [weak self] (result: SearchLocationSuggestionsServiceResult) -> Void in
                guard let strongSelf = self else { return }

                if !strongSelf.setFirstPlace(result.value) {
                    strongSelf.delegate?.viewModel(strongSelf, didFailToFindLocationWithResult: result)
                }

                strongSelf.serviceAlreadyLoading = false
            }
        }
        else {
            pendingGoToLocation = true
        }
    }

    private func setFirstPlace(places: [Place]?) -> Bool {
        if let places = places, let place = places.first {
            return setPlace(place)
        }
        return false
    }

    private func setPlace(place: Place?) -> Bool {
        guard let place = place, let location = place.location else { return false }
        let coordinate = location.coordinates2DfromLocation()
        self.currentPlace = place
        self.delegate?.viewModel(self, centerMapInLocation: coordinate, withPostalAddress: place.postalAddress,
            approximate: self.approximateLocation)
        return true
    }


    /**
        Manages the change in the view when the user switches from aproxximate to accurate
    */
    
    func updateApproximateSwitchChanged() {
        
        if let location = currentPlace.location {
            let coordinate = location.coordinates2DfromLocation()
            delegate?.viewModel(self, centerMapInLocation: coordinate, withPostalAddress: currentPlace.postalAddress,
                approximate: self.approximateLocation)
        }
    }


    /**
        Saves the user location
    */

    func applyLocation() {

        let myCompletion: Result<MyUser, RepositoryError> -> () = { [weak self] result in
            guard let strongSelf = self else { return }
            if let value = result.value {
                if let myUserLocation = value.location {
                    let trackerEvent = TrackerEvent.profileEditEditLocation(myUserLocation)
                    strongSelf.tracker.trackEvent(trackerEvent)
                }
                strongSelf.delegate?.viewModelDidApplyLocation(strongSelf)
            }
            else {
                strongSelf.delegate?.viewModelDidFailApplyingLocation(strongSelf)
            }
        }
        
        if usingGPSLocation {
            self.delegate?.viewModelDidStartApplyingLocation(self)
            locationManager.setAutomaticLocation(myCompletion)
        } else if let lat = currentPlace.location?.latitude, let long = currentPlace.location?.longitude {
            self.delegate?.viewModelDidStartApplyingLocation(self)
            let location = CLLocation(latitude: lat, longitude: long)
            let postalAddress = currentPlace.postalAddress ?? PostalAddress(address: nil, city: nil, zipCode: nil,
                countryCode: nil, country: nil)
            locationManager.setManualLocation(location, postalAddress: postalAddress, completion: myCompletion)
        } else {
            self.delegate?.viewModelDidFailApplyingLocation(self)
        }
    }
}
