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

    fileprivate var newPlace: Place?

    private let disposeBag = DisposeBag()


    convenience override init() {
        self.init(locationManager: Core.locationManager,
                  searchService: CLSearchLocationSuggestionsService(),
                  postalAddressService: CLPostalAddressRetrievalService())
    }

    init(locationManager: LocationManager,
         searchService: CLSearchLocationSuggestionsService,
         postalAddressService: PostalAddressRetrievalService) {
        self.locationManager = locationManager
        self.searchService = searchService
        self.postalAddressService = postalAddressService
        super.init()
        setupRx()
    }

    func setupRx() {
        zipCode.asObservable().bindNext { [weak self] zip in
            guard let strongSelf = self else { return }
            if strongSelf.isValidZip(zip: zip) {
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
        guard let location = locationManager.currentAutoLocation?.location else { return }

        fullAddressVisible.value = false
        isResolvingAddress.value = true

        postalAddressService.retrieveAddressForLocation(location) { [weak self] result in
            self?.isResolvingAddress.value = false
            if let place = result.value {
                self?.newPlace = place
                if let postalAddress = place.postalAddress, let _ = postalAddress.zipCode {
                    self?.fullAddress.value = postalAddress.zipCodeCityString
                } else if let name = place.name {
                    self?.fullAddress.value = name
                } else if let resumedData = place.placeResumedData {
                    self?.fullAddress.value = resumedData
                }
            }else {
                print(result.error)
            }
        }
    }

    func updateAddressFromZipCode() {
        guard let zip = zipCode.value, isValidZip(zip: zip) else { return }

        fullAddressVisible.value = false
        isResolvingAddress.value = true

        searchService.retrieveAddressForLocation(zip) { [weak self] result in
            self?.isResolvingAddress.value = false
            if let value = result.value, !value.isEmpty {
                guard let place = value.first else { return }
                self?.newPlace = place
                if let postalAddress = place.postalAddress, let _ = postalAddress.zipCode {
                    self?.fullAddress.value = postalAddress.zipCodeCityString
                } else if let name = place.name {
                    self?.fullAddress.value = name
                } else if let resumedData = place.placeResumedData {
                    self?.fullAddress.value = resumedData
                }
            } else {
                print(result.error)
            }
        }
    }

    func setNewLocation() {
        guard let place = newPlace else { return }
        locationDelegate?.editLocationDidSelectPlace(place)
    }

    private func isValidZip(zip: String?) -> Bool {
        guard let zip = zip else { return false }
        guard zip.characters.count == 5 else { return false }
        guard zip.isOnlyDigits else { return false }
        return true
    }
}
