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
        
        if featureFlags.jobsAndServicesEnabled.isActive {
            // FIXME: Implement this in ABIOS-4741
        } else {
            // More info here: ABIOS-4795
            if let categoryIds = categoryIds,
                categoryIds.contains(where: { $0 == ListingCategory.services.rawValue }) {
                switch featureFlags.jobsAndServicesEnabled {
                case .baseline, .control:
                    serviceListingTypes = [ServiceListingType.service]
                case .active:
                    break
                }
            }
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
