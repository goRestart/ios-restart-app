
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
    private let taxonomiesOnboardingCache: TaxonomiesDAO?
    private let locationManager: LocationManager


    init(dataSource: TaxonomiesDataSource, taxonomiesCache: TaxonomiesDAO, taxonomiesOnboardingCache: TaxonomiesDAO, locationManager: LocationManager) {
        self.dataSource = dataSource
        self.taxonomiesCache = taxonomiesCache
        self.taxonomiesOnboardingCache = taxonomiesOnboardingCache
        self.locationManager = locationManager
    }

    func index(filterVisible filtered: Bool, completion: CategoriesCompletion?) {
        completion?(CategoriesResult(value: ListingCategory.visibleValues(filtered: filtered)))
    }

    func indexTaxonomies() -> [Taxonomy] {
        return taxonomiesCache.taxonomies
    }
    
    func indexOnboardingTaxonomies() -> [Taxonomy] {
        return taxonomiesOnboardingCache?.taxonomies ?? []
    }

    func retrieveTaxonomyChildren(withIds ids: [Int]) -> [TaxonomyChild] {
        let taxonomyChildren = taxonomiesOnboardingCache?.taxonomies.flatMap { $0.children } ?? []
        return taxonomyChildren.filter { ids.contains($0.id) }
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
    
    func refreshTaxonomiesOnboardingCache() {
        let countryCode = locationManager.currentLocation?.postalAddress?.countryCode ?? LGCategoryRepository.defaultCountryCode
        let locale = Locale.current
        dataSource.indexOnboarding(countryCode: countryCode, locale: locale) { [weak self] result in
            if let value = result.value, !value.isEmpty {
                self?.taxonomiesOnboardingCache?.save(taxonomies: value)
            }
        }
    }
}
