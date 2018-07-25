//
//  FilterTagBuilder.swift
//  LetGo
//
//  Created by Stephen Walsh on 11/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

struct FilterTagBuilder {
    
    private let filters: ListingFilters
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper
    private let featureFlags: FeatureFlaggeable
    
    init(filters: ListingFilters,
         locationManager: LocationManager = Core.locationManager,
         currencyHelper: CurrencyHelper = Core.currencyHelper,
         featureFlags: FeatureFlaggeable = FeatureFlags.sharedInstance) {
        self.filters = filters
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.featureFlags = featureFlags
    }
    
    var primaryTags: [FilterTag] {
        var resultTags: [FilterTag] = []
        
        for prodCat in filters.selectedCategories {
            resultTags.append(.category(prodCat))
        }
        
        if let taxonomyChild = filters.selectedTaxonomyChildren.last {
            resultTags.append(.taxonomyChild(taxonomyChild))
        }
        
        if filters.selectedWithin.listingTimeCriteria != ListingTimeFilter.defaultOption.listingTimeCriteria {
            resultTags.append(.within(filters.selectedWithin))
        }
        if let selectedOrdering = filters.selectedOrdering, selectedOrdering != ListingSortCriteria.defaultOption {
            resultTags.append(.orderBy(selectedOrdering))
        }
        
        switch filters.priceRange {
        case .freePrice:
            resultTags.append(.freeStuff)
        case let .priceRange(min, max):
            if min != nil || max != nil {
                var currency: Currency? = nil
                if let countryCode = locationManager.currentLocation?.countryCode {
                    currency = currencyHelper.currencyWithCountryCode(countryCode)
                }
                resultTags.append(.priceRange(from: filters.priceRange.min, to: filters.priceRange.max, currency: currency))
            }
        }
        
        if filters.selectedCategories.contains(.cars) || filters.selectedTaxonomyChildren.containsCarsTaxonomy {
            let carFilters = filters.verticalFilters.cars
            if let makeId = carFilters.makeId, let makeName = carFilters.makeName {
                resultTags.append(.make(id: makeId, name: makeName.localizedUppercase))
                if let modelId = carFilters.modelId, let modelName = carFilters.modelName {
                    resultTags.append(.model(id: modelId, name: modelName.localizedUppercase))
                }
            }
            if carFilters.yearStart != nil || carFilters.yearEnd != nil {
                resultTags.append(.yearsRange(from: carFilters.yearStart, to: carFilters.yearEnd))
            }
            
            let carSellerTypeTags = carFilters.sellerTypes.map({ FilterTag.carSellerType(type: $0, name: $0.title) })
            resultTags.append(contentsOf: carSellerTypeTags)
            
        }
        if filters.selectedCategories.contains(.realEstate) {
            let realEstateFilters = filters.verticalFilters.realEstate
            if let propertyType = realEstateFilters.propertyType {
                resultTags.append(.realEstatePropertyType(propertyType))
            }
            
            realEstateFilters.offerTypes.forEach { resultTags.append(.realEstateOfferType($0)) }
            
            if let numberOfBedrooms = realEstateFilters.numberOfBedrooms {
                resultTags.append(.realEstateNumberOfBedrooms(numberOfBedrooms))
            }
            if let numberOfBathrooms = realEstateFilters.numberOfBathrooms {
                resultTags.append(.realEstateNumberOfBathrooms(numberOfBathrooms))
            }
            if let numberOfRooms = realEstateFilters.numberOfRooms {
                resultTags.append(.realEstateNumberOfRooms(numberOfRooms))
            }
            
            if realEstateFilters.sizeRange.min != nil || realEstateFilters.sizeRange.max != nil {
                resultTags.append(.sizeSquareMetersRange(from: realEstateFilters.sizeRange.min,
                                                         to: realEstateFilters.sizeRange.max))
            }
        }
        
        return resultTags
    }
    
    var secondaryTags: [FilterTag] {
        var resultTags: [FilterTag] = []
        if let taxonomyChildren = filters.selectedTaxonomy?.children,
            filters.selectedTaxonomyChildren.count <= 0 {
            for secondaryTaxonomyChild in taxonomyChildren {
                resultTags.append(.secondaryTaxonomyChild(secondaryTaxonomyChild))
            }
        }
        return resultTags
    }
}
