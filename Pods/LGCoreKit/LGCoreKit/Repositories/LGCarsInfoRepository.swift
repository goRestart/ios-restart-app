//
//  LGCarsInfoRepository.swift
//  LGCoreKit
//
//  Created by Dídac on 21/03/17.
//  Copyright © 2017 Ambatana Inc. All rights reserved.
//

import Result
import RxSwift

final class LGCarsInfoRepository: CarsInfoRepository {

    private let dataSource: CarsInfoDataSource
    private let cache: CarsInfoDAO
    private let locationManager: LocationManager

    private var countryCode: String?

    private var disposeBag = DisposeBag()


    // MARK: - Lifecycle

    init(dataSource: CarsInfoDataSource, cache: CarsInfoDAO, locationManager: LocationManager) {
        self.dataSource = dataSource
        self.cache = cache
        self.locationManager = locationManager
        setupRx()
    }

    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        cache.loadFirstRunCacheIfNeeded(jsonURL: jsonURL)
    }

    func refreshCarsInfoFile() {
        countryCode = locationManager.currentLocation?.postalAddress?.countryCode
        dataSource.index(countryCode: countryCode) { [weak self] result in
            if let value = result.value {
                if !value.isEmpty {
                    self?.cache.save(carsInfo: value)
                }
            }
        }
    }

    func retrieveCarsMakes() -> [CarsMake] {
        return cache.carsMakesList
    }

    func retrieveCarsModelsFormake(makeId: String) -> [CarsModel] {
        return cache.modelsForMake(makeId: makeId)
    }

    func retrieveValidYears(withFirstYear firstYear: Int?, ascending: Bool) -> [Int] {
        let currentYear = Calendar.current.component(.year, from: Date())
        guard let actualFirstYear = firstYear else {
            let yearsList = Array(LGCoreKitConstants.carsFirstYear...currentYear)
            return ascending ? yearsList : yearsList.reversed()
        }
        // older cars than 1900? unlikely... :/
        var modelFirstYear = max(LGCoreKitConstants.carsFirstYear, actualFirstYear)
        // let's make sure the first year is smaller than the current year
        modelFirstYear = min(modelFirstYear, currentYear)
        let yearsList = Array(modelFirstYear...currentYear)
        return ascending ? yearsList : yearsList.reversed()
    }

    // Rx

    fileprivate func setupRx() {
        locationManager.locationEvents.filter { $0 == .locationUpdate }.subscribeNext { [weak self] _ in
            guard let locationCountryCode = self?.locationManager.currentLocation?.postalAddress?.countryCode,
                locationCountryCode != self?.countryCode else { return }
            self?.refreshCarsInfoFile()
        }.addDisposableTo(disposeBag)
    }
}
