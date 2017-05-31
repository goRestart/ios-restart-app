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

protocol LocationFromZipCodeViewModelDelegate: BaseViewModelDelegate { }

class LocationFromZipCodeViewModel: BaseViewModel {

    private let locationManager: LocationManager
    private let searchService: CLSearchLocationSuggestionsService
    private let postalAddressService: PostalAddressRetrievalService

    weak var locationDelegate: EditLocationDelegate?

    let zipCode = Variable<String?>(nil)
    let fullAddress = Variable<String?>(nil)

    let setLocationButtonVisible = Variable<Bool>(false)
    let setLocationButtonEnabled = Variable<Bool>(false)
    let fullAddressVisible = Variable<Bool>(false)
    let isResolvingAddress = Variable<Bool>(false)

    fileprivate var initialPlace: Place?
    fileprivate var newPlace: Place?

    var countryCode: CountryCode = .usa

    weak var navigator: EditLocationFiltersNavigator?
    weak var delegate: LocationFromZipCodeViewModelDelegate?

    private let disposeBag = DisposeBag()


    convenience init(initialPlace: Place?) {
        self.init(initialPlace: initialPlace,
                  locationManager: Core.locationManager,
                  searchService: CLSearchLocationSuggestionsService(),
                  postalAddressService: CLPostalAddressRetrievalService())
    }

    init(initialPlace: Place?,
         locationManager: LocationManager,
         searchService: CLSearchLocationSuggestionsService,
         postalAddressService: PostalAddressRetrievalService) {
        self.locationManager = locationManager
        self.searchService = searchService
        self.postalAddressService = postalAddressService
        if let cCode = locationManager.currentLocation?.countryCode {
            self.countryCode = CountryCode(string: cCode) ?? .usa
        }
        super.init()
        setupRx()

        if let initialPlace = initialPlace {
            self.fullAddress.value = self.fullAddressString(forPlace: initialPlace)
        }
    }

    func setupRx() {
        zipCode.asObservable().bindNext { [weak self] zip in
            guard let strongSelf = self else { return }
            guard let zip = zip else { return }
            if strongSelf.countryCode.isValidZipCode(zipCode: zip) {
                strongSelf.updateAddressFromZipCode()
            }
        }.addDisposableTo(disposeBag)

        fullAddress.asObservable().bindNext { [weak self] address in
            guard let _ = address else { return }
            self?.fullAddressVisible.value = true
            self?.setLocationButtonEnabled.value = true
        }.addDisposableTo(disposeBag)
    }

    func editingStart() {
        setLocationButtonVisible.value = true
    }

    func updateAddressFromCurrentLocation() {

        zipCode.value = ""
        setLocationButtonVisible.value = true

        guard let location = locationManager.currentAutoLocation?.location else { return }

        fullAddressVisible.value = false
        isResolvingAddress.value = true

        postalAddressService.retrieveAddressForLocation(location) { [weak self] result in
            self?.isResolvingAddress.value = false
            if let place = result.value {
                self?.newPlace = place
                self?.fullAddress.value = self?.fullAddressString(forPlace: place)
            } else if let error = result.error {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeLocationZipNotFoundErrorMessage, completion: nil)
                logMessage(.error, type: [.location], message: "PostalAddress Service: Retrieve Address For Location error: \(error)")
            }
        }
    }

    func updateAddressFromZipCode() {
        guard let zip = zipCode.value, countryCode.isValidZipCode(zipCode: zip) else { return }

        fullAddressVisible.value = false
        isResolvingAddress.value = true

        searchService.retrieveAddressForLocation(zip) { [weak self] result in
            self?.isResolvingAddress.value = false
            if let value = result.value, !value.isEmpty {
                guard let place = value.first else { return }
                self?.newPlace = place
                self?.fullAddress.value = self?.fullAddressString(forPlace: place)
            } else if let error = result.error {
                self?.delegate?.vmShowAutoFadingMessage(LGLocalizedString.changeLocationZipNotFoundErrorMessage, completion: nil)
                logMessage(.error, type: [.location], message: "Search Service: Retrieve Address For Location error: \(error)")
            }
        }
    }

    func setNewLocation() {
        guard let place = newPlace else { return }
        locationDelegate?.editLocationDidSelectPlace(place)
        close()
    }

    func close() {
        navigator?.editLocationFromZipDidClose()
    }

    private func fullAddressString(forPlace place: Place) -> String? {
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
