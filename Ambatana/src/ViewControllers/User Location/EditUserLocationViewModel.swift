//
//  EditUserLocationViewModel.swift
//  LetGo
//
//  Created by Dídac on 12/08/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import MapKit
import Result
import RxSwift


public protocol EditUserLocationViewModelDelegate: class {
    func viewModel(viewModel: EditUserLocationViewModel, updateSearchTableWithResults results: [String])
    func viewModelDidFailFindingSuggestions(viewModel: EditUserLocationViewModel)
    func viewModel(viewModel: EditUserLocationViewModel, didFailToFindLocationWithError error: String)
    func viewModelDidApplyLocation(viewModel: EditUserLocationViewModel)
    func viewModelDidFailApplyingLocation(viewModel: EditUserLocationViewModel)
}

public class EditUserLocationViewModel: BaseViewModel {
   
    public weak var delegate: EditUserLocationViewModelDelegate?
    
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let tracker: Tracker
    
    private let searchService: CLSearchLocationSuggestionsService
    private let postalAddressService: PostalAddressRetrievalService

    private var usingGPSLocation = false        // user uses GPS location
    private var serviceAlreadyLoading = false   // if the service is already waiting for a response, we don't launch another request
    private var pendingGoToLocation = false      // In case goToLocation was called while serviceAlreadyLoading
    private var predictiveResults: [Place]
    private var currentPlace: Place


    // MARK: - Rx variables

    let disposeBag = DisposeBag()

    //Output
    let placeTitle = Variable<String>("")
    let placeSubtitle = Variable<String>("")
    let placeLocation = Variable<CLLocationCoordinate2D?>(nil)
    let placeInfoText = Variable<String>("")
    let approxLocation: Variable<Bool>
    let loading = Variable<Bool>(false)

    //Input
    let searchText = Variable<(String, autoSelect: Bool)>("", autoSelect: false)
    let userTouchingMap = Variable<Bool>(false)
    let userMovedLocation = Variable<CLLocationCoordinate2D?>(nil)

    //Internal
    private let locationToFetch = Variable<(CLLocationCoordinate2D?, fromGps: Bool)>(nil, fromGps: false)

    
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

        self.approxLocation = Variable<Bool>(locationManager.currentLocation?.type != .Sensor &&
                locationManager.currentLocation?.type != .Manual)
        
        self.predictiveResults = []
        self.currentPlace = Place.newPlace()
        self.searchService = CLSearchLocationSuggestionsService()
        self.postalAddressService = CLPostalAddressRetrievalService()
        super.init()

        self.initPlace()
        self.setRxBindings()
    }
    
    
    // MARK: public methods

    var placeCount: Int {
        return predictiveResults.count
    }
    
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
        when user taps GPS button, map goes to user last GPS location
    */

    func showGPSLocation() {
        guard let location = locationManager.currentAutoLocation else { return }
        placeLocation.value = location.location.coordinate
        locationToFetch.value = (location.location.coordinate, fromGps: true)
    }

    /**
        Search for suggestions for the user search
    */

    

    /**
        Selects a location from the suggestions table
    */
    func selectPlace(resultsIndex: Int) {
        guard resultsIndex >= 0 && resultsIndex < predictiveResults.count else { return }
        setPlace(predictiveResults[resultsIndex], forceLocation: true, fromGps: false)
    }


    /**
        Saves the user location
    */

    func applyLocation() {
        let myCompletion: Result<MyUser, RepositoryError> -> () = { [weak self] result in
            guard let strongSelf = self else { return }
            strongSelf.loading.value = false
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
            loading.value = true
            locationManager.setAutomaticLocation(myCompletion)
        } else if let lat = currentPlace.location?.latitude, long = currentPlace.location?.longitude,
            postalAddress = currentPlace.postalAddress{
                loading.value = true
                let location = CLLocation(latitude: lat, longitude: long)
                locationManager.setManualLocation(location, postalAddress: postalAddress, completion: myCompletion)
        } else {
            self.delegate?.viewModelDidFailApplyingLocation(self)
        }
    }


    // MARK: - Private methods

    private func initPlace() {
        guard let myUser =  myUserRepository.myUser,location = myUser.location else { return }
        let place = Place(postalAddress: myUser.postalAddress, location:LGLocationCoordinates2D(location: location))
        setPlace(place, forceLocation: true, fromGps: location.type != .Manual)
    }

    private func setPlace(place: Place, forceLocation: Bool, fromGps: Bool) {
        currentPlace = place
        usingGPSLocation = fromGps
        dispatch_async(dispatch_get_main_queue()) {
            self.updateInfoText()
            self.placeTitle.value = self.currentPlace.title
            self.placeSubtitle.value = self.currentPlace.subtitle
            if forceLocation {
                self.placeLocation.value = self.currentPlace.location?.coordinates2DfromLocation()
            }
        }
    }

    private func setRxBindings() {

        approxLocation.asObservable().subscribeNext{ [weak self] _ in
            self?.updateInfoText()
        }.addDisposableTo(disposeBag)

        searchText.asObservable()
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribeNext{ [weak self] searchText, autoSelect in
                self?.resultsForSearchText(searchText, autoSelectFirst: autoSelect)
            }.addDisposableTo(disposeBag)

        userMovedLocation.asObservable()
            .subscribeNext { [weak self] coordinates in
                guard let coordinates = coordinates else { return }
                dispatch_async(dispatch_get_main_queue()) {
                    self?.locationToFetch.value = (coordinates, false)
                }
            }
            .addDisposableTo(disposeBag)


        //Place retrieval
        locationToFetch.asObservable()
            .filter { coordinates, gpsLocation in return coordinates != nil }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .filter { [weak self] _ in
                return !(self?.userTouchingMap.value ?? true)
            }
            .map { coordinates, gpsLocation in
                return self.postalAddressService.rx_retrieveAddressForCoordinates(coordinates, fromGps: gpsLocation)
            }
            .switchLatest()
            .subscribeNext { [weak self] place, gpsLocation in
                self?.setPlace(place, forceLocation: false, fromGps: gpsLocation)
            }
            .addDisposableTo(disposeBag)
    }

    private func updateInfoText() {
        placeInfoText.value = currentPlace.fullText(showAddress: !approxLocation.value)
    }

    private func resultsForSearchText(textToSearch: String, autoSelectFirst: Bool) {
        searchService.retrieveAddressForLocation(textToSearch) { [weak self] result in
            guard let strongSelf = self else { return }

            if autoSelectFirst {
                if let error = result.error {
                    let errorMsg = error == .NotFound ?
                        LGLocalizedString.changeLocationErrorUnknownLocationMessage(textToSearch) :
                        LGLocalizedString.changeLocationErrorSearchLocationMessage
                    strongSelf.delegate?.viewModel(strongSelf, didFailToFindLocationWithError: errorMsg)
                } else if let place = result.value?.first {
                    strongSelf.setPlace(place, forceLocation: true, fromGps: false)
                }
            } else {
                if let suggestions = result.value {
                    strongSelf.predictiveResults = suggestions
                    var suggestionsStrings : [String] = []
                    for place in suggestions {
                        suggestionsStrings.append(place.placeResumedData!)
                    }
                    strongSelf.delegate?.viewModel(strongSelf, updateSearchTableWithResults: suggestionsStrings)
                } else {
                    strongSelf.delegate?.viewModelDidFailFindingSuggestions(strongSelf)
                }
            }
        }
    }
}

extension PostalAddressRetrievalService {
    public func rx_retrieveAddressForCoordinates(coordinates: CLLocationCoordinate2D?, fromGps: Bool)
        -> Observable<(Place, Bool)> {
            guard let coordinates = coordinates else { return rx_retrieveAddressForLocation(nil, fromGps: fromGps) }
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            return rx_retrieveAddressForLocation(location, fromGps: fromGps)
    }

    public func rx_retrieveAddressForLocation(location: CLLocation?, fromGps: Bool) -> Observable<(Place, Bool)> {
        return Observable.create({ observer -> Disposable in
            guard let location = location else {
                observer.onError(PostalAddressRetrievalServiceError.Internal)
                return AnonymousDisposable({})
            }
            self.retrieveAddressForLocation(location) {
                (result: PostalAddressRetrievalServiceResult) -> Void in
                guard let resolvedPlace = result.value else {
                    observer.onError(result.error ?? .Internal)
                    return
                }

                observer.onNext(resolvedPlace, fromGps)
                observer.onCompleted()
            }
            return AnonymousDisposable({})
        })
    }
}

extension CLSearchLocationSuggestionsService {

}


extension Place {
    var title: String {
        return postalAddress?.address ?? ""
    }

    var subtitle: String {
        var subtitle = postalAddress?.zipCode ?? ""
        if let city = postalAddress?.city {
            if !subtitle.isEmpty {
                subtitle += " "
            }
            subtitle += city
        }
        return subtitle
    }

    func fullText(showAddress showAddress: Bool) -> String {
        var result = ""
        if showAddress {
            if let address = postalAddress?.address {
                result += address
            }
        }
        if let zipCode = postalAddress?.zipCode {
            if !result.isEmpty {
                result += ", "
            }
            result += zipCode
        }
        if let city = postalAddress?.city {
            if !result.isEmpty {
                result += ", "
            }
            result += city
        }
        if let country = postalAddress?.countryCode {
            if !result.isEmpty {
                result += ", "
            }
            result += country
        }
        return result
    }
}
