//
//  RetrieveListingParams+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 13/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension RetrieveListingParams {
    
    mutating func populate(with filters: ListingFilters?,
                           featureFlags: FeatureFlaggeable) {
        categoryIds = filters?.selectedCategories.compactMap { $0.rawValue }
        let idCategoriesFromTaxonomies = filters?.selectedTaxonomyChildren.getIds(withType: .category)
        categoryIds?.append(contentsOf: idCategoriesFromTaxonomies ?? [])
        superKeywordIds = filters?.selectedTaxonomyChildren.getIds(withType: .superKeyword)
        
        if let selectedTaxonomyChild = filters?.selectedTaxonomyChildren.first {
            switch selectedTaxonomyChild.type {
            case .category:
                categoryIds = [selectedTaxonomyChild.id]
            case .superKeyword:
                superKeywordIds = [selectedTaxonomyChild.id]
            }
        } else if let selectedTaxonomy = filters?.selectedTaxonomy {
            categoryIds = selectedTaxonomy.children.getIds(withType: .category)
            superKeywordIds = selectedTaxonomy.children.getIds(withType: .superKeyword)
        }
        
        timeCriteria = filters?.selectedWithin.listingTimeCriteria
        sortCriteria = filters?.selectedOrdering
        distanceRadius = filters?.distanceRadius
        distanceType = filters?.distanceType
        
        if let priceRange = filters?.priceRange {
            switch priceRange {
            case .freePrice:
                freePrice = true
            case let .priceRange(min, max):
                minPrice = min
                maxPrice = max
            }
        }
        
        applyVerticalFilters(with: filters?.verticalFilters,
                             featureFlags: featureFlags)
    }
    
    mutating func applyVerticalFilters(with verticalFilters: VerticalFilters?,
                                       featureFlags: FeatureFlaggeable) {
        guard let verticalFilters = verticalFilters else { return }
        
        userTypes = verticalFilters.cars.sellerTypes
        makeId = verticalFilters.cars.makeId
        modelId = verticalFilters.cars.modelId
        startYear = verticalFilters.cars.yearStart
        endYear = verticalFilters.cars.yearEnd
        bodyType = verticalFilters.cars.bodyTypes
        fuelType = verticalFilters.cars.fuelTypes
        transmision = verticalFilters.cars.transmissionTypes
        drivetrain = verticalFilters.cars.driveTrainTypes
        
        startMileage = verticalFilters.cars.mileageStart
        endMileage = verticalFilters.cars.mileageEnd
        startNumberOfSeats = verticalFilters.cars.numberOfSeatsStart
        endNumberOfSeats = verticalFilters.cars.numberOfSeatsEnd
        mileageType = verticalFilters.cars.mileageType
        
        if let typeId = verticalFilters.services.type?.id {
            typeIds = [typeId]
        }
        
        if featureFlags.servicesUnifiedFilterScreen.isActive {
            if let selectedServiceSubtypeCount = verticalFilters.services.subtypes?.count,
                let serviceSubtypesCount = verticalFilters.services.type?.subTypes.count,
                selectedServiceSubtypeCount < serviceSubtypesCount {
                subtypeIds = verticalFilters.services.subtypes?.map( { $0.id } )
            } else {
                subtypeIds = nil
            }
        } else {
            subtypeIds = verticalFilters.services.subtypes?.map( { $0.id } )
        }
    
        if let propertyTypeValue = verticalFilters.realEstate.propertyType?.rawValue {
            propertyType = propertyTypeValue
        }
        
        offerType = verticalFilters.realEstate.offerTypes.map( { $0.rawValue })
        numberOfBedrooms = verticalFilters.realEstate.numberOfBedrooms?.rawValue ?? verticalFilters.realEstate.numberOfRooms?.numberOfBedrooms
        numberOfBathrooms = verticalFilters.realEstate.numberOfBathrooms?.rawValue
        numberOfLivingRooms = verticalFilters.realEstate.numberOfRooms?.numberOfLivingRooms
        
        sizeSquareMetersFrom = verticalFilters.realEstate.sizeRange.min
        sizeSquareMetersTo = verticalFilters.realEstate.sizeRange.max
    }
    
}
