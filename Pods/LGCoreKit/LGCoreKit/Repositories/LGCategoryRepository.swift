
//
//  LGCategoryRepository.swift
//  LGCoreKit
//
//  Created by Eli Kohen on 18/11/2016.
//  Copyright © 2016 Ambatana Inc. All rights reserved.
//


final class LGCategoryRepository: CategoryRepository {

    static private let defaultCountryCode = "us"

    private let dataSource: TaxonomiesDataSource
    private let taxonomiesCache: TaxonomiesDAO
    private let locationManager: LocationManager


    init(dataSource: TaxonomiesDataSource, taxonomiesCache: TaxonomiesDAO, locationManager: LocationManager) {
        self.dataSource = dataSource
        self.taxonomiesCache = taxonomiesCache
        self.locationManager = locationManager
    }

    func index(carsIncluded: Bool, realEstateIncluded: Bool, highlightRealEstate: Bool, completion: CategoriesCompletion?) {
        completion?(CategoriesResult(value: ListingCategory.visibleValues(carsIncluded: carsIncluded, realEstateIncluded: realEstateIncluded, highlightRealEstate: highlightRealEstate)))
    }

    func indexTaxonomies() -> [Taxonomy] {
        return taxonomiesCache.taxonomies
    }
    
    func loadFirstRunCacheIfNeeded(jsonURL: URL) {
        taxonomiesCache.loadFirstRunCacheIfNeeded(jsonURL: jsonURL)
    }

    func refreshTaxonomiesCache() {
        let countryCode = locationManager.currentLocation?.postalAddress?.countryCode ?? LGCategoryRepository.defaultCountryCode
        let locale = Locale.current
        dataSource.index(countryCode: countryCode, locale: locale) { [weak self] result in
            if let value = result.value, !value.isEmpty {
                self?.taxonomiesCache.save(taxonomies: value)
            }
        }
    }

}
