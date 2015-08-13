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
    func viewModel(viewModel: EditUserLocationViewModel, updateTextFieldWithString locationName: String)
    func viewModel(viewModel: EditUserLocationViewModel, updateSearchTableWithResults results: [String])
    func viewModel(viewModel: EditUserLocationViewModel, centerMapInLocation location: CLLocationCoordinate2D, approximate: Bool)
}

public class EditUserLocationViewModel: BaseViewModel {
   
    public weak var delegate : EditUserLocationViewModelDelegate?
    
    private let searchService : CLSearchLocationSuggestionsService
    private let postalAddressService : PostalAddressRetrievalService
    
    let geocoder = CLGeocoder()

    var approximateLocation : Bool
    var goingToLocation : Bool
    var usingGPSLocation : Bool
    var predictiveResults : [Place]
    var currentPlace : Place
    
    var searchText : String {
        didSet {
            if !goingToLocation {
                self.resultsForSearchText()
            }
        }
    }
    
    // MARK : -Lifecycle
    
    override init() {
        searchText = ""
        approximateLocation = true
        goingToLocation = false
        usingGPSLocation = false
        predictiveResults = []
        currentPlace = Place()
        searchService = CLSearchLocationSuggestionsService()
        postalAddressService = CLPostalAddressRetrievalService()
        super.init()
    }
    
    func showInitialUserLocation() {
        goingToLocation = true
        var user = MyUserManager.sharedInstance.myUser()
        if let location = user?.gpsCoordinates {
            var lat = location.latitude as CLLocationDegrees
            var long = location.longitude as CLLocationDegrees
            var coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            delegate?.viewModel(self, centerMapInLocation: coordinate, approximate: self.approximateLocation)
            delegate?.viewModel(self, updateTextFieldWithString: "")
            var place = Place()
            place.postalAdress = user?.postalAddress
            place.location = location
            self.currentPlace = place

        }
        
        goingToLocation = false
    }
    
    func showGPSUserLocation() {
        goingToLocation = true
        usingGPSLocation = true

        postalAddressService.retrieveAddressForLocation(LocationManager.sharedInstance.lastKnownLocation!) { [weak self] (result: Result<PostalAddress, PostalAddressRetrievalServiceError>) -> Void in
            if let strongSelf = self {
                if let actualDelegate = strongSelf.delegate {
                    if let postalAddress = result.value {
                        actualDelegate.viewModel(strongSelf, centerMapInLocation: LocationManager.sharedInstance.lastKnownLocation!.coordinate, approximate: strongSelf.approximateLocation)
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
                        place.postalAdress = postalAddress
                        place.location = LGLocationCoordinates2D(coordinates: LocationManager.sharedInstance.lastKnownLocation!.coordinate)
                        strongSelf.currentPlace = place
                    }
                }
            }
        }
    }
    
    func resultsForSearchText() {

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
            }
        }
    }
    
    func goToLocation() {
        usingGPSLocation = false

        searchService.goToLocation(self.searchText) { [weak self](result: Result<[Place], SearchLocationSuggestionsServiceError>) -> Void in
            if let strongSelf = self {
                if let actualDelegate = strongSelf.delegate {
                    if let places = result.value {
                        if let place = places.first {
                            if let location = place.location {
                                var lat = location.latitude as CLLocationDegrees
                                var long = location.longitude as CLLocationDegrees
                                var coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                                actualDelegate.viewModel(strongSelf, centerMapInLocation: coordinate, approximate: strongSelf.approximateLocation)
                                strongSelf.currentPlace = place
                            }
                        }
                    }
                    else {
                        strongSelf.showInitialUserLocation()
                    }
                }
            }
        }
    }
    
    
    func updateApproximateSwitchChanged() {
        
        if usingGPSLocation {
            showGPSUserLocation()
        } else {
            goToLocation()
        }
    }

}
