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
}

protocol EditLocationDelegate: class {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?)
}

enum EditLocationMode {
    case editUserLocation
    case editListingLocation
    case editFilterLocation
    case quickFilterLocation
}

class EditLocationViewModel: BaseViewModel {
   
    weak var delegate: EditLocationViewModelDelegate?
    weak var navigator: EditLocationNavigator?
    weak var quickLocationFiltersNavigator: QuickLocationFiltersNavigator?
    weak var locationDelegate: EditLocationDelegate?
    
    private let locationManager: LocationManager
    private let myUserRepository: MyUserRepository
    private let mode: EditLocationMode
    private let tracker: Tracker
    private let featureFlags: FeatureFlaggeable
    
    private let locationRepository: LocationRepository

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
    let currentDistanceRadius = Variable<Int?>(nil)

    //Input
    let searchText = Variable<(String, autoSelect: Bool)>("", autoSelect: false)
    let userTouchingMap = Variable<Bool>(false)
    let userMovedLocation = Variable<CLLocationCoordinate2D?>(nil)

    //Internal
    private let locationToFetch = Variable<(CLLocationCoordinate2D?, fromGps: Bool)>(nil, fromGps: false)

    
    // MARK: - Lifecycle

    convenience init(mode: EditLocationMode,
                     initialPlace: Place? = nil,
                     distanceRadius: Int? = nil) {
        self.init(locationManager: Core.locationManager,
                  myUserRepository: Core.myUserRepository,
                  locationRepository: Core.locationRepository,
                  mode: mode,
                  initialPlace: initialPlace,
                  distanceRadius: distanceRadius,
                  tracker: TrackerProxy.sharedInstance,
                  featureFlags: FeatureFlags.sharedInstance)
    }

    init(locationManager: LocationManager,
         myUserRepository: MyUserRepository,
         locationRepository: LocationRepository,
         mode: EditLocationMode,
         initialPlace: Place?,
         distanceRadius: Int?,
         tracker: Tracker,
         featureFlags: FeatureFlaggeable) {
        
        self.locationManager = locationManager
        self.myUserRepository = myUserRepository
        self.mode = mode
        self.tracker = tracker
        self.featureFlags = featureFlags

        self.approxLocation = Variable<Bool>(KeyValueStorage.sharedInstance.userLocationApproximate &&
            (mode == .editUserLocation || mode == .editListingLocation))
        
        self.predictiveResults = []
        self.currentPlace = Place.newPlace()
        self.locationRepository = locationRepository
        super.init()

        self.initPlace(initialPlace, distanceRadius: distanceRadius)
        self.setRxBindings()
    }
    
    override func backButtonPressed() -> Bool {
        guard let _ = navigator else { return false }
        closeLocation()
        return true
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        if firstTime {
            trackVisitIfNeeded()
        }
    }
    
    
    // MARK: public methods
    
    var distanceMeters: CLLocationDistance {
        guard let distanceRadius = distanceRadius else { return 0 }
        switch distanceType {
        case .km:
            return Double(distanceRadius) * 1000
        case .mi:
            return Double(distanceRadius) * Constants.metersInOneMile
        }
    }
    
    var distanceType: DistanceType {
        return DistanceType.systemDistanceType()
    }
    
    var distanceRadius: Int? {
        if let currentDistance = currentDistanceRadius.value, currentDistance <= 0 { return nil }
        return currentDistanceRadius.value
    }

    var shouldShowDistanceSlider: Bool {
        return mode == .quickFilterLocation && featureFlags.editLocationBubble == .map
    }
    
    var shouldShowCustomNavigationBar: Bool {
        return mode == .quickFilterLocation
    }
    
    var shouldShowCircleOverlay: Bool {
        return mode == .quickFilterLocation
    }
    
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

    func showGPSLocation() {
        guard let location = locationManager.currentAutoLocation else { return }
        placeLocation.value = location.coordinate
        locationToFetch.value = (location.coordinate, fromGps: true)
    }

    func selectPlace(_ resultsIndex: Int) {
        guard resultsIndex >= 0 && resultsIndex < predictiveResults.count else { return }
        setPlace(predictiveResults[resultsIndex], forceLocation: true, fromGps: false, enableSave: true)
    }

    func applyLocation() {
        switch mode {
        case .editUserLocation:
            updateUserLocation()
        case .editFilterLocation, .editListingLocation:
            locationDelegate?.editLocationDidSelectPlace(currentPlace, distanceRadius: distanceRadius)
            let trackerEvent = TrackerEvent.location(locationType: locationManager.currentLocation?.type,
                                                     locationServiceStatus: locationManager.locationServiceStatus,
                                                     typePage: .filter,
                                                     zipCodeFilled: nil,
                                                     distanceRadius: distanceRadius)
            tracker.trackEvent(trackerEvent)
            closeLocation()
        case .quickFilterLocation:
            locationDelegate?.editLocationDidSelectPlace(currentPlace, distanceRadius: distanceRadius)
            let trackerEvent = TrackerEvent.location(locationType: locationManager.currentLocation?.type,
                                                     locationServiceStatus: locationManager.locationServiceStatus,
                                                     typePage: .feedBubble,
                                                     zipCodeFilled: nil,
                                                     distanceRadius: distanceRadius)
            tracker.trackEvent(trackerEvent)
            closeQuickLocation()
        }
    }
    
    func cancelSetLocation() {
        closeQuickLocation()
    }
    
    // MARK: - Private methods

    private func initPlace(_ initialPlace: Place?, distanceRadius: Int?) {
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
        case .editFilterLocation, .quickFilterLocation:
            if let place = initialPlace {
                setPlace(place, forceLocation: true, fromGps: false, enableSave: false)
            } else {
                guard let location = locationManager.currentLocation, let postalAddress = locationManager.currentLocation?.postalAddress
                    else { return }
                let place = Place(postalAddress: postalAddress, location:LGLocationCoordinates2D(location: location))
                setPlace(place, forceLocation: true, fromGps: location.type != .manual, enableSave: false)
            }
            approxLocationHidden.value = true
            currentDistanceRadius.value = distanceRadius
        case .editListingLocation:
            if let place = initialPlace, let location = place.location {
                locationRepository.retrieveAddressForLocation(location) { [weak self] result in
                    guard let strongSelf = self else { return }
                    if let resolvedPlace = result.value {
                        strongSelf.currentPlace = resolvedPlace.postalAddress?.countryCode != nil ?
                            resolvedPlace : Place(postalAddress: strongSelf.locationManager.currentLocation?.postalAddress,
                                                  location: strongSelf.locationManager.currentLocation?.location)
                        strongSelf.setPlace(strongSelf.currentPlace, forceLocation: true, fromGps: true, enableSave: true)
                    } else if let _ = result.error {
                        strongSelf.currentPlace = Place(postalAddress: strongSelf.locationManager.currentLocation?.postalAddress,
                                                        location: strongSelf.locationManager.currentLocation?.location)
                        strongSelf.setPlace(strongSelf.currentPlace, forceLocation: true, fromGps: false, enableSave: true)
                    }
                }
            }
            approxLocationHidden.value = false
        }
    }

    private func setPlace(_ place: Place, forceLocation: Bool, fromGps: Bool, enableSave: Bool) {

        if mode == .editListingLocation && currentPlace.postalAddress?.countryCode != place.postalAddress?.countryCode {
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
                return self.locationRepository.rx_retrieveAddressForCoordinates(coordinates, fromGps: gpsLocation)
            }
            .switchLatest()
            .subscribeNext { [weak self] place, gpsLocation in
                self?.setPlace(place, forceLocation: false, fromGps: gpsLocation, enableSave: true)
            }
            .addDisposableTo(disposeBag)
        
        currentDistanceRadius.asObservable()
            .skip(1)
            .unwrap()
            .map { _ in true }
            .bindTo(setLocationEnabled).addDisposableTo(disposeBag)
        
    }

    private func updateInfoText() {
        placeInfoText.value = currentPlace.fullText(showAddress: !approxLocation.value)
    }

    private func resultsForSearchText(_ textToSearch: String, autoSelectFirst: Bool) {
        predictiveResults = []
        delegate?.vmUpdateSearchTableWithResults([])
        locationRepository.retrieveAddressForLocation(textToSearch) { [weak self] result in
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
            guard let strongSelf = self else { return }
            strongSelf.loading.value = false
            if let value = result.value {
                let trackerEvent = TrackerEvent.location(locationType: value.location?.type,
                                                         locationServiceStatus: strongSelf.locationManager.locationServiceStatus,
                                                         typePage: .profile,
                                                         zipCodeFilled: nil,
                                                         distanceRadius: nil)
                strongSelf.tracker.trackEvent(trackerEvent)
                strongSelf.closeLocation()
            } else {
                strongSelf.delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeLocationErrorUpdatingLocationMessage, completion: nil)
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
            delegate?.vmPop()
        }
    }
    
    private func closeQuickLocation() {
        quickLocationFiltersNavigator?.closeQuickLocationFilters()
    }

    private func trackVisitIfNeeded() {
        let event: TrackerEvent
        switch mode {
        case .editUserLocation:
            event = TrackerEvent.profileEditEditLocationStart()
        case .editFilterLocation, .quickFilterLocation:
            event = TrackerEvent.filterLocationStart()
        case .editListingLocation:
            return
        }
        tracker.trackEvent(event)
    }
}

extension LocationRepository {
    func rx_retrieveAddressForCoordinates(_ coordinates: CLLocationCoordinate2D?, fromGps: Bool)
        -> Observable<(Place, Bool)> {
            guard let coordinates = coordinates else { return rx_retrieveAddressForLocation(nil, fromGps: fromGps) }
            let location = CLLocation(latitude: coordinates.latitude, longitude: coordinates.longitude)
            return rx_retrieveAddressForLocation(location, fromGps: fromGps)
    }

    func rx_retrieveAddressForLocation(_ location: CLLocation?, fromGps: Bool) -> Observable<(Place, Bool)> {
        return Observable.create({ observer -> Disposable in
            guard let location = location else {
                observer.onError(LocationError.internalError)
                // Change how to return anonymousDisposable http://stackoverflow.com/questions/40936295/what-is-the-rxswift-3-0-equivalent-to-anonymousdisposable-from-rxswift-2-x
                return Disposables.create()
            }
            self.retrieveAddressForLocation(LGLocationCoordinates2D(latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude)) {
                (result: PostalAddressLocationRepositoryResult) -> Void in
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
        if result.isEmpty {
            result = placeResumedData ?? LGLocalizedString.filtersTagLocationSelected
        }
        return result
    }
}
