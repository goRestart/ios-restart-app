//
//  LocationFromZipCodeViewModel.swift
//  LetGo
//
//  Created by Dídac on 23/05/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import Foundation
import LGCoreKit
import RxSwift
import RxSwiftExt

protocol LocationFromZipCodeViewModelDelegate: BaseViewModelDelegate { }

class LocationFromZipCodeViewModel: BaseViewModel {

    private let locationManager: LocationManager
    private let locationRepository: LocationRepository
    private let tracker: Tracker

    weak var locationDelegate: EditLocationDelegate?

    let zipCode = Variable<String?>(nil)
    let fullAddress = Variable<String?>(nil)

    let setLocationButtonVisible = Variable<Bool>(false)
    let setLocationButtonEnabled = Variable<Bool>(false)
    let setDigitsTipLabelVisible = Variable<Bool>(true)
    let fullAddressVisible = Variable<Bool>(false)
    let isResolvingAddress = Variable<Bool>(false)
    let isValidZipCode = Variable<Bool>(false)

    fileprivate let initialPlace = Variable<Place?>(nil)
    fileprivate let newPlace = Variable<Place?>(nil)
    fileprivate var distanceRadius: Int?

    fileprivate let countryCode = Variable<CountryCode>(.usa)

    var zipLenghtForCountry: Int {
        return countryCode.value.zipCodeLenght
    }

    weak var navigator: QuickLocationFiltersNavigator?
    weak var delegate: LocationFromZipCodeViewModelDelegate?

    private let disposeBag = DisposeBag()
    
    convenience init(initialPlace: Place?, distanceRadius: Int? = nil) {
        self.init(initialPlace: initialPlace,
                  distanceRadius: distanceRadius,
                  locationManager: Core.locationManager,
                  locationRepository: Core.locationRepository,
                  tracker: TrackerProxy.sharedInstance)
    }

    init(initialPlace: Place?,
         distanceRadius: Int?,
         locationManager: LocationManager,
         locationRepository: LocationRepository,
         tracker: Tracker) {
        self.locationManager = locationManager
        self.locationRepository = locationRepository
        self.tracker = tracker
        self.distanceRadius = distanceRadius
        if let cCode = locationManager.currentLocation?.countryCode {
            self.countryCode.value = CountryCode(string: cCode) ?? .usa
        }
        super.init()
        setupRx()

        self.initialPlace.value = initialPlace
    }

    func setupRx() {

        Observable.combineLatest(countryCode.asObservable(), zipCode.asObservable().unwrap().distinctUntilChanged()) { ($0, $1) }
            .map { (cCode, zip) -> Bool in
                return cCode.isValidZipCode(zipCode: zip)
            }
            .bindTo(isValidZipCode)
            .addDisposableTo(disposeBag)

        isValidZipCode.asObservable()
            .bindNext { _ in
                self.updateAddressFromZipCode()
            }
            .addDisposableTo(disposeBag)

        initialPlace.asObservable().asObservable().unwrap()
            .map { LocationFromZipCodeViewModel.fullAddressString(forPlace: $0) }
            .bindTo(fullAddress)
            .addDisposableTo(disposeBag)

        newPlace.asObservable().asObservable().unwrap()
            .map { LocationFromZipCodeViewModel.fullAddressString(forPlace: $0) }
            .bindTo(fullAddress)
            .addDisposableTo(disposeBag)

        let fullAddressNotNil = fullAddress.asObservable().map { $0 != nil }
        Observable.combineLatest(fullAddressNotNil, isResolvingAddress.asObservable()) { $0 && !$1 }
            .bindTo(fullAddressVisible)
            .addDisposableTo(disposeBag)

        let initialAddressString = initialPlace.asObservable().unwrap().map { LocationFromZipCodeViewModel.fullAddressString(forPlace: $0) }
        Observable.combineLatest(initialAddressString.asObservable(),
                                 fullAddress.asObservable().unwrap(),
                                 isValidZipCode.asObservable()) { ($0, $1, $2) }
            .map { (initialAddress, fullAddress, isValidZipCode) -> Bool in
                return initialAddress != fullAddress && isValidZipCode
            }
            .bindTo(setLocationButtonEnabled)
            .addDisposableTo(disposeBag)

        setLocationButtonEnabled.asObservable().map{ !$0 }.bindTo(setDigitsTipLabelVisible).addDisposableTo(disposeBag)
    }

    func editingStart() {
        setLocationButtonVisible.value = true
    }

    func updateAddressFromCurrentLocation() {

        zipCode.value = nil
        setLocationButtonVisible.value = true

        guard let location = locationManager.currentAutoLocation?.location else { return }

        isResolvingAddress.value = true

        locationRepository.retrieveAddressForLocation(location) { [weak self] result in
            self?.isResolvingAddress.value = false
            if let place = result.value {
                if let zipCode = place.postalAddress?.zipCode {
                    self?.zipCode.value = zipCode
                } else {
                    self?.newPlace.value = place
                }
            } else if let error = result.error {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeLocationZipNotFoundErrorMessage, completion: nil)
                logMessage(.error, type: [.location], message: "PostalAddress Service: Retrieve Address For Location error: \(error)")
            }
        }
    }

    func updateAddressFromZipCode() {
        guard let zip = zipCode.value, isValidZipCode.value else { return }

        isResolvingAddress.value = true

        locationRepository.retrieveAddressForLocation(zip) { [weak self] result in
            self?.isResolvingAddress.value = false
            if let value = result.value, !value.isEmpty {
                guard let place = value.first else { return }
                self?.newPlace.value = place
            } else if let error = result.error {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeLocationZipNotFoundErrorMessage, completion: nil)
                logMessage(.error, type: [.location], message: "Search Service: Retrieve Address For Location error: \(error)")
            }
        }
    }

    func setNewLocation() {
        guard let place = newPlace.value else { return }
        locationDelegate?.editLocationDidSelectPlace(place, distanceRadius: distanceRadius)
        
        let trackerEvent = TrackerEvent.location(locationType: locationManager.currentLocation?.type,
                                                 locationServiceStatus: locationManager.locationServiceStatus,
                                                 typePage: .feedBubble,
                                                 zipCodeFilled: zipCode.value != nil,
                                                 distanceRadius: nil)
        tracker.trackEvent(trackerEvent)
        
        close()
    }

    func close() {
        navigator?.closeQuickLocationFilters()
    }

    private static func fullAddressString(forPlace place: Place) -> String? {
        if let postalAddress = place.postalAddress, let _ = postalAddress.zipCode {
            return postalAddress.zipCodeCityString
        } else if let name = place.name {
            return name
        } else if let resumedData = place.placeResumedData {
            return resumedData
        }
        return nil
    }
}
