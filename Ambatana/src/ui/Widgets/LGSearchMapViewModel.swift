import CoreLocation
import LGCoreKit
import MapKit
import RxSwift
import LGComponents


protocol LGSearchMapViewModelDelegate: class {
    func vmUpdateSearchTableWithResults(_ results: [String])
    func vmDidFailFindingSuggestions()
    func vmDidFailToFindLocationWithError(_ error: String)
}

protocol LGSearchMapViewControllerModelDelegate: BaseViewModelDelegate { }

class LGSearchMapViewModel: BaseViewModel {
    
    private let locationManager: LocationManager
    private let locationRepository: LocationRepository
    
    weak var delegate: LGSearchMapViewModelDelegate?
    weak var viewControllerDelegate: LGSearchMapViewControllerModelDelegate?
    
    private let disposeBag = DisposeBag()
    private var predictiveResults: [Place]
    private var currentPlace: Place
    private var usingGPSLocation = false
    private let initialPlace: Place
    
    let placeLocation = Variable<Place?>(nil)
    private let placeGPSLocation = Variable<Place?>(nil)
    var placeGPSObservable: Observable<Place?> {
        return placeGPSLocation.asObservable()
    }
    private let placeSuggestedSelected = Variable<Place?>(nil)
    var placeSuggestedObservable: Observable<Place?> {
        return placeSuggestedSelected.asObservable()
    }
    let placeInfoText = Variable<String>("")
    let setLocationEnabled = Variable<Bool>(false)
    
    let loading = Variable<Bool>(false)
    let currentDistanceRadius = Variable<Int?>(nil)
    let userMovedLocation = Variable<CLLocationCoordinate2D?>(nil)
    
    let searchText = Variable<(String, autoSelect: Bool)>(("", autoSelect: false))
    
    private let locationToFetch = Variable<(CLLocationCoordinate2D?, fromGps: Bool)>((nil, fromGps: false))
    
    convenience init(currentPlace: Place?) {
        let locationManager = Core.locationManager
        let locationRepository = Core.locationRepository
        self.init(locationManager: locationManager, locationRepository: locationRepository, currentPlace: currentPlace)
    }
    
    init(locationManager: LocationManager, locationRepository: LocationRepository, currentPlace: Place?) {
        self.locationManager = locationManager
        self.locationRepository = locationRepository
        self.predictiveResults = []
        self.currentPlace = currentPlace ?? Place.newPlace()
        self.initialPlace = currentPlace ?? Place(postalAddress: nil, location: locationManager.currentAutoLocation?.location)
        super.init()
        self.initPlace(initialPlace, distanceRadius: distanceRadius)
        setupRX()
    }
    
    var coordinate: LGLocationCoordinates2D? {
        return locationManager.currentLocation?.location
    }
    
    var distanceRadius: Int? {
        if let currentDistance = currentDistanceRadius.value, currentDistance <= 0 { return nil }
        return currentDistanceRadius.value
    }
    
    var distanceMeters: CLLocationDistance {
        guard let distanceRadius = distanceRadius else { return 0 }
        switch distanceType {
        case .km:
            return Double(distanceRadius) * 1000
        case .mi:
            return Double(distanceRadius) * SharedConstants.metersInOneMile
        }
    }
    
    var distanceType: DistanceType {
        return DistanceType.systemDistanceType()
    }
    
    var placeCount: Int {
        return predictiveResults.count
    }
    
    func showGPSLocation() {
        guard let location = locationManager.currentAutoLocation else { return }
        placeLocation.value = Place(postalAddress: location.postalAddress, location: LGLocationCoordinates2D(coordinates: location.coordinate))
        locationToFetch.value = (location.coordinate, fromGps: true)
        placeGPSLocation.value = placeLocation.value
    }
    
    private func setupRX() {
        searchText.asObservable().skip(1)
            .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribeNext{ [weak self] searchText, autoSelect in
                self?.resultsForSearchText(searchText, autoSelectFirst: autoSelect)
            }.disposed(by: disposeBag)
        
        locationToFetch.asObservable()
            .filter { coordinates, gpsLocation in return coordinates != nil }
            .debounce(0.5, scheduler: MainScheduler.instance)
            .map { coordinates, gpsLocation in
                return self.locationRepository.rx_retrieveAddressForCoordinates(coordinates, fromGps: gpsLocation)
            }
            .switchLatest()
            .subscribeNext { [weak self] place, gpsLocation in
                self?.setPlace(place, forceLocation: false, fromGps: gpsLocation, enableSave: true)
            }
            .disposed(by: disposeBag)
        
        userMovedLocation.asObservable()
            .subscribeNext { [weak self] coordinates in
                guard let coordinates = coordinates else { return }
                DispatchQueue.main.async {
                    self?.locationToFetch.value = (coordinates, false)
                }
        }.disposed(by: disposeBag)
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
    
    func selectPlace(_ resultsIndex: Int) {
        guard resultsIndex >= 0 && resultsIndex < predictiveResults.count else { return }
        let place = predictiveResults[resultsIndex]
        if let shouldRetrieveDetails = place.shouldRetrieveDetails, shouldRetrieveDetails {
            guard let placeId = place.placeId else { return }
            viewControllerDelegate?.vmShowLoading(nil)
            locationRepository.retrieveLocationSuggestionDetails(placeId: placeId) { [weak self] result in
                guard let strongSelf = self else { return }
                strongSelf.viewControllerDelegate?.vmHideLoading(nil, afterMessageCompletion: nil)
                if let updatedPlace = result.value {
                    strongSelf.setPlace(updatedPlace, forceLocation: true, fromGps: false, enableSave: true)
                    strongSelf.placeSuggestedSelected.value = updatedPlace
                } else {
                    strongSelf.viewControllerDelegate?.vmShowAutoFadingMessage(R.Strings.changeLocationErrorUpdatingLocationMessage) {
                        strongSelf.updateMapToPreviousKnownPlace()
                    }
                }
            }
        } else {
            setPlace(place, forceLocation: true, fromGps: false, enableSave: true)
            placeSuggestedSelected.value = place
        }
    }

    private func resultsForSearchText(_ textToSearch: String, autoSelectFirst: Bool) {
        predictiveResults = []
        delegate?.vmUpdateSearchTableWithResults([])
        locationRepository.retrieveLocationSuggestions(addressString: textToSearch, currentLocation: locationManager.currentLocation) { [weak self] result in
            if autoSelectFirst {
                if let error = result.error {
                    let errorMsg = error == .notFound ?
                        R.Strings.changeLocationErrorUnknownLocationMessage(textToSearch) :
                        R.Strings.changeLocationErrorSearchLocationMessage
                    self?.delegate?.vmDidFailToFindLocationWithError(errorMsg)
                } else if let place = result.value?.first {
                    self?.setPlace(place, forceLocation: true, fromGps: false, enableSave: true)
                }
            } else {
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
    
    private func initPlace(_ initialPlace: Place?, distanceRadius: Int?) {
            if let place = initialPlace, let location = place.location {
                locationRepository.retrievePostalAddress(location: location) { [weak self] result in
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
    }

    
    private func setPlace(_ place: Place, forceLocation: Bool, fromGps: Bool, enableSave: Bool) {
        currentPlace = place
        usingGPSLocation = fromGps
        setLocationEnabled.value = enableSave
        DispatchQueue.main.async {
            self.updateInfoText()
            self.placeLocation.value = self.currentPlace
        }
    }
    
    private func updateMapToPreviousKnownPlace() {
        setLocationEnabled.value = false
        placeLocation.value = currentPlace
        locationToFetch.value = (currentPlace.location?.coordinates2DfromLocation(), fromGps: false)
    }
    
    private func updateInfoText() {
        placeInfoText.value = currentPlace.fullText(showAddress: true)
    }
    
    
    func setViewControllerDelegate(viewControllerModelDelegate: LGSearchMapViewControllerModelDelegate) {
        viewControllerDelegate = viewControllerModelDelegate
    }
}
