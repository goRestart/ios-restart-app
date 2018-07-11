//
//  FilterTagFeedPresenter.swift
//  LetGo
//
//  Created by Haiyan Ma on 27/04/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

protocol FilterTagFeedPresentable: class {
    var primaryTags: [FilterTag] { get }
    var secondaryTags: [FilterTag] { get }
}

extension FilterTagFeedPresenter: FeedPresenter {
    
    static var feedClass: AnyClass {
        return FilterTagFeedHeaderCell.self
    }
    
    var height: CGFloat {
        return FilterTagFeedHeaderCell.collectionViewHeight
    }
}

final class FilterTagFeedPresenter: FilterTagFeedPresentable {
    
    private let locationManager: LocationManager
    private let currencyHelper: CurrencyHelper
    private let featureFlags: FeatureFlaggeable
    
    private var filters: ListingFilters
    
    init(filters: ListingFilters,
         locationManager: LocationManager,
         currencyHelper: CurrencyHelper,
         featureFlags: FeatureFlaggeable) {
        self.filters = filters
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.featureFlags = featureFlags
    }
    
    convenience init(filters: ListingFilters) {
        let locationManager = Core.locationManager
        let currentcyHelper = Core.currencyHelper
        let featureFlags = FeatureFlags.sharedInstance
        let filters = filters.updating(selectedCategories: [ListingCategory.cars, ListingCategory.babyAndChild, .electronics, .fashionAndAccesories, .homeAndGarden]) // FIXME: Delete this line after being able to filter by selecting categories
        self.init(filters: filters,
                  locationManager: locationManager,
                  currencyHelper: currentcyHelper,
                  featureFlags: featureFlags)

    }
    
    var primaryTags: [FilterTag] {
        var resultTags : [FilterTag] = []
        
        filters.selectedCategories.forEach { resultTags.append(.category($0)) }
        
        if let taxonomyChild = filters.selectedTaxonomyChildren.last {
            resultTags.append(.taxonomyChild(taxonomyChild))
        }
        
        if filters.selectedWithin != ListingTimeCriteria.defaultOption {
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
            if let makeId = filters.carMakeId, let makeName = filters.carMakeName {
                resultTags.append(.make(id: makeId, name: makeName.localizedUppercase))
                if let modelId = filters.carModelId, let modelName = filters.carModelName {
                    resultTags.append(.model(id: modelId, name: modelName.localizedUppercase))
                }
            }
            if filters.carYearStart != nil || filters.carYearEnd != nil {
                resultTags.append(.yearsRange(from: filters.carYearStart, to: filters.carYearEnd))
            }
            
            let carSellerTypeTags = filters.carSellerTypes.map { FilterTag.carSellerType(type: $0, name: $0.title) }
            resultTags.append(contentsOf: carSellerTypeTags)
        }
        if filters.selectedCategories.contains(.realEstate) {
            if let propertyType = filters.realEstatePropertyType {
                resultTags.append(.realEstatePropertyType(propertyType))
            }
            
            filters.realEstateOfferTypes.forEach { resultTags.append(.realEstateOfferType($0)) }
            
            if let numberOfBedrooms = filters.realEstateNumberOfBedrooms {
                resultTags.append(.realEstateNumberOfBedrooms(numberOfBedrooms))
            }
            if let numberOfBathrooms = filters.realEstateNumberOfBathrooms {
                resultTags.append(.realEstateNumberOfBathrooms(numberOfBathrooms))
            }
            if let numberOfRooms = filters.realEstateNumberOfRooms {
                resultTags.append(.realEstateNumberOfRooms(numberOfRooms))
            }
            if filters.realEstateSizeRange.min != nil || filters.realEstateSizeRange.max != nil {
                resultTags.append(.sizeSquareMetersRange(from: filters.realEstateSizeRange.min, to: filters.realEstateSizeRange.max))
            }
        }
        
        return resultTags
    }
    
    var secondaryTags: [FilterTag] {
        var resultTags: [FilterTag] = []
        if let taxonomyChildren = filters.selectedTaxonomy?.children,
            filters.selectedTaxonomyChildren.count <= 0 {
            taxonomyChildren.forEach { resultTags.append(.secondaryTaxonomyChild($0)) }
        }
        return resultTags
    }
}



