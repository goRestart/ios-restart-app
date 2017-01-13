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


protocol EditLocationViewModelDelegate: BaseViewModelDelegate {
    func vmUpdateSearchTableWithResults(_ results: [String])
    func vmDidFailFindingSuggestions()
    func vmDidFailToFindLocationWithError(_ error: String)
    func vmGoBack()
}

protocol EditLocationDelegate: class {
    func editLocationDidSelectPlace(_ place: Place)
}

enum EditLocationMode {
    case editUserLocation, selectLocation, editProductLocation
}

class EditLocationViewModel: BaseViewModel {
   
    weak var delegate: EditLocationViewModelDelegate?
    weak var navigator: EditLocationNavigator?
    weak var locationDelegate: EditLocationDelegate?
    
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let mode: EditLocationMode
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
    let placeLocation = Variable<CLLocationCoordinate2D?>(nil)
    let placeInfoText = Variable<String>("")
    let approxLocation: Variable<Bool>
    let setLocationEnabled = Variable<Bool>(false)
    let approxLocationHidden = Variable<Bool>(false)
    let loading = Variable<Bool>(false)

    //Input
    let searchText = Variable<(String, autoSelect: Bool)>("", autoSelect: false)
    let userTouchingMap = Variable<Bool>(false)
    let userMovedLocation = Variable<CLLocationCoordinate2D?>(nil)

    //Internal
    private let locationToFetch = Variable<(CLLocationCoordinate2D?, fromGps: Bool)>(nil, fromGps: false)

    
    // MARK: - Lifecycle

    convenience init(mode: EditLocationMode) {
        let locationManager = Core.locationManager
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(locationManager: locationManager, myUserRepository: myUserRepository, mode: mode, initialPlace: nil,
                  tracker: tracker)
    }

    convenience init(mode: EditLocationMode, initialPlace: Place?) {
        let locationManager = Core.locationManager
        let myUserRepository = Core.myUserRepository
        let tracker = TrackerProxy.sharedInstance
        self.init(locationManager: locationManager, myUserRepository: myUserRepository, mode: mode,
                  initialPlace: initialPlace, tracker: tracker)
    }

    init(locationManager: LocationManager, myUserRepository: MyUserRepository, mode: EditLocationMode,
         initialPlace: Place?, tracker: Tracker) {
        self.locationManager = locationManager
        self.myUserRepository = myUserRepository
        self.mode = mode
        self.tracker = tracker

        self.approxLocation = Variable<Bool>(KeyValueStorage.sharedInstance.userLocationApproximate &&
            (mode == .editUserLocation || mode == .editProductLocation))
        
        self.predictiveResults = []
        self.currentPlace = Place.newPlace()
        self.searchService = CLSearchLocationSuggestionsService()
        self.postalAddressService = CLPostalAddressRetrievalService()
        super.init()

        self.initPlace(initialPlace)
        self.setRxBindings()
    }
    
    override func backButtonPressed() -> Bool {
        closeLocation()
        return true
    }
    
    
    // MARK: public methods

    var placeCount: Int {
        return predictiveResults.count
    }
    
    func placeResumedDataAtPosition(_ position: Int) -> String? {
        return predictiveResults[position].placeResumedData
    }
    
    func locationForPlaceAtPosition(_ position: Int) -> LGLocationCoordinates2D? {
        return predictiveResults[position].location
    }

    func postalAddressForPlaceAtPosition(_ position: Int) -> PostalAddress? {
        return predictiveResults[position].postalAddress
    }

    /**
        when user taps GPS button, map goes to user last GPS location
    */
    func showGPSLocation() {
        guard let location = locationManager.currentAutoLocation else { return }
        placeLocation.value = location.coordinate
        locationToFetch.value = (location.coordinate, fromGps: true)
    }

    /**
        Selects a location from the suggestions table
    */
    func selectPlace(_ resultsIndex: Int) {
        guard resultsIndex >= 0 && resultsIndex < predictiveResults.count else { return }
        setPlace(predictiveResults[resultsIndex], forceLocation: true, fromGps: false, enableSave: true)
    }

    /**
        Saves the user location
    */
    func applyLocation() {
        switch mode {
        case .editUserLocation:
            updateUserLocation()
        case .selectLocation, .editProductLocation:
            locationDelegate?.editLocationDidSelectPlace(currentPlace)
            closeLocation()
        }
    }


    // MARK: - Private methods

    private func initPlace(_ initialPlace: Place?) {
        switch mode {
        case .editUserLocation:
            if let place = initialPlace {
                setPlace(place, forceLocation: true, fromGps: false, enableSave: false)
            } else {
                guard let myUser =  myUserRepository.myUser, let location = myUser.location else { return }
                let place = Place(postalAddress: myUser.postalAddress, location:LGLocationCoordinates2D(location: location))
                setPlace(place, forceLocation: true, fromGps: location.type != .manual, enableSave: false)
            }
            approxLocationHidden.value = false
        case .selectLocation:
            if let place = initialPlace {
                setPlace(place, forceLocation: true, fromGps: false, enableSave: false)
            } else {
                guard let location = locationManager.currentLocation, let postalAddress = locationManager.currentPostalAddress
                    else { return }
                let place = Place(postalAddress: postalAddress, location:LGLocationCoordinates2D(location: location))
                setPlace(place, forceLocation: true, fromGps: location.type != .manual, enableSave: false)
            }
            approxLocationHidden.value = true
        case .editProductLocation:
            if let place = initialPlace, let location = place.location {
                postalAddressService.retrieveAddressForLocation(location) { [weak self] result in
                    guard let strongSelf = self else { return }
                    if let resolvedPlace = result.value {
                        strongSelf.currentPlace = resolvedPlace.postalAddress?.countryCode != nil ?
                            resolvedPlace : Place(postalAddress: strongSelf.locationManager.currentPostalAddress,
                                                  location: strongSelf.locationManager.currentLocation?.location)
                        strongSelf.setPlace(strongSelf.currentPlace, forceLocation: true, fromGps: true, enableSave: true)
                    } else if let _ = result.error {
                        strongSelf.currentPlace = Place(postalAddress: strongSelf.locationManager.currentPostalAddress,
                                                        location: strongSelf.locationManager.currentLocation?.location)
                        strongSelf.setPlace(strongSelf.currentPlace, forceLocation: true, fromGps: false, enableSave: true)
                    }
                }
            }
            approxLocationHidden.value = false
        }
    }

    private func setPlace(_ place: Place, forceLocation: Bool, fromGps: Bool, enableSave: Bool) {

        if mode == .editProductLocation && currentPlace.postalAddress?.countryCode != place.postalAddress?.countryCode {
            delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeLocationErrorCountryAlertMessage) { [weak self] in
                self?.setMapToPreviousKnownPlace()
            }
            return
        }

        currentPlace = place
        usingGPSLocation = fromGps
        setLocationEnabled.value = enableSave
        DispatchQueue.main.async {
            self.updateInfoText()
            if forceLocation {
                self.placeLocation.value = self.currentPlace.location?.coordinates2DfromLocation()
            }
        }
    }

    private func setMapToPreviousKnownPlace() {
        setLocationEnabled.value = false
        placeLocation.value = currentPlace.location?.coordinates2DfromLocation()
        locationToFetch.value = (currentPlace.location?.coordinates2DfromLocation(), fromGps: false)
    }

    private func setRxBindings() {

        approxLocation.asObservable().subscribeNext{ [weak self] value in
            KeyValueStorage.sharedInstance.userLocationApproximate = value
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
                DispatchQueue.main.async {
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
                self?.setPlace(place, forceLocation: false, fromGps: gpsLocation, enableSave: true)
            }
            .addDisposableTo(disposeBag)
    }

    private func updateInfoText() {
        placeInfoText.value = currentPlace.fullText(showAddress: !approxLocation.value)
    }

    private func resultsForSearchText(_ textToSearch: String, autoSelectFirst: Bool) {
        predictiveResults = []
        delegate?.vmUpdateSearchTableWithResults([])
        searchService.retrieveAddressForLocation(textToSearch) { [weak self] result in
            if autoSelectFirst {
                if let error = result.error {
                    let errorMsg = error == .notFound ?
                        LGLocalizedString.changeLocationErrorUnknownLocationMessage(textToSearch) :
                        LGLocalizedString.changeLocationErrorSearchLocationMessage
                    self?.delegate?.vmDidFailToFindLocationWithError(errorMsg)
                } else if let place = result.value?.first {
                    self?.setPlace(place, forceLocation: true, fromGps: false, enableSave: true)
                }
            } else {
                // Guard to avoid slow responses override last one
                guard let currentText = self?.searchText.value.0, currentText == textToSearch else { return }
                if let suggestions = result.value {
                    self?.predictiveResults = suggestions
                    let suggestionsStrings : [String] = suggestions.flatMap {$0.placeResumedData}
                    self?.delegate?.vmUpdateSearchTableWithResults(suggestionsStrings)
                } else {
                    self?.delegate?.vmDidFailFindingSuggestions()
                }
            }
        }
    }

    private func updateUserLocation() {
        let myCompletion: (Result<MyUser, RepositoryError>) -> () = { [weak self] result in
            self?.loading.value = false
            if let value = result.value {
                if let myUserLocation = value.location {
                    let trackerEvent = TrackerEvent.profileEditEditLocation(myUserLocation)
                    self?.tracker.trackEvent(trackerEvent)
                }
                self?.closeLocation()
            } else {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeLocationErrorUpdatingLocationMessage, completion: nil)
            }
        }

        if usingGPSLocation {
            loading.value = true
            locationManager.setAutomaticLocation(myCompletion)
        } else if let lat = currentPlace.location?.latitude, let long = currentPlace.location?.longitude,
            let postalAddress = currentPlace.postalAddress {
                loading.value = true
                let location = CLLocation(latitude: lat, longitude: long)
                locationManager.setManualLocation(location, postalAddress: postalAddress, completion: myCompletion)
        } else {
            delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeLocationErrorUpdatingLocationMessage, completion: nil)
        }
    }
    
    private func closeLocation() {
        if let navigator = navigator {
            navigator.closeEditLocation()
        } else {
            delegate?.vmGoBack()
        }
    }
}

extension PostalAddressRetrievalService {
    func rx_retrieveAddressForCoordinates(_ coordinates: CLLocationCoordinate2D?, fromGps: Bool)
        -> Observable<(Place, Bool)> {
            guard let coordinates = coordinates else { return rx_retrieveAddressForLocation(nil, fromGps: fromGps) }
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            return rx_retrieveAddressForLocation(location, fromGps: fromGps)
    }

    func rx_retrieveAddressForLocation(_ location: CLLocation?, fromGps: Bool) -> Observable<(Place, Bool)> {
        return Observable.create({ observer -> Disposable in
            guard let location = location else {
                observer.onError(PostalAddressRetrievalServiceError.internalError)
                // Change how to return anonymousDisposable http://stackoverflow.com/questions/40936295/what-is-the-rxswift-3-0-equivalent-to-anonymousdisposable-from-rxswift-2-x
                return Disposables.create()
            }
            self.retrieveAddressForLocation(LGLocationCoordinates2D(latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude)) {
                (result: PostalAddressRetrievalServiceResult) -> Void in
                guard let resolvedPlace = result.value else {
                    observer.onError(result.error ?? .internalError)
                    return
                }

                observer.onNext(resolvedPlace, fromGps)
                observer.onCompleted()
            }
            return Disposables.create()
        })
    }
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

    func fullText(showAddress: Bool) -> String {
        var result = ""
        if showAddress {
            if let address = postalAddress?.address {
                result += address
            }
        } else {
            // Usually address has already the postal code and the city
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
            if let state = postalAddress?.state {
                if !result.isEmpty {
                    result += " "
                }
                result += state
            }
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
