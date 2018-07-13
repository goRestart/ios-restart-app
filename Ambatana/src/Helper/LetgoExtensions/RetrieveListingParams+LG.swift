//
//  RetrieveListingParams+LG.swift
//  LetGo
//
//  Created by Juan Iglesias on 13/12/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

extension RetrieveListingParams {
    
    mutating func populate(with filters: ListingFilters?) {
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
        
        timeCriteria = filters?.selectedWithin
        sortCriteria = filters?.selectedOrdering
        distanceRadius = filters?.distanceRadius
        distanceType = filters?.distanceType
        
        //  Car filters
        userTypes = filters?.carSellerTypes
        makeId = filters?.carMakeId
        modelId = filters?.carModelId
        startYear = filters?.carYearStart
        endYear = filters?.carYearEnd
        
        bodyType = filters?.carBodyTypes
        drivetrain = filters?.carDriveTrainTypes
        fuelType = filters?.carFuelTypes
        transmision = filters?.carTransmissionTypes
        startMileage = filters?.carMileageStart
        endMileage = filters?.carMileageEnd
        startNumberOfSeats = filters?.carNumberOfSeatsStart
        endNumberOfSeats = filters?.carNumberOfSeatsEnd
        mileageType = filters?.carMileageType
        
        if let propertyTypeValue = filters?.realEstatePropertyType?.rawValue {
            propertyType = propertyTypeValue
        }

        offerType = filters?.realEstateOfferTypes.compactMap { $0.rawValue }
        numberOfBedrooms = filters?.realEstateNumberOfBedrooms?.rawValue ?? filters?.realEstateNumberOfRooms?.numberOfBedrooms
        numberOfLivingRooms = filters?.realEstateNumberOfRooms?.numberOfLivingRooms
        numberOfBathrooms = filters?.realEstateNumberOfBathrooms?.rawValue
        
        sizeSquareMetersFrom = filters?.realEstateSizeRange.min
        sizeSquareMetersTo = filters?.realEstateSizeRange.max
        
        //  Services
        /*
         Currently, we only support single-select on the app side for typeId, but the API requires an
         array of typeIds. When we support Multiselect we can just update the filters servicesType parameter to
         an array
         */
        if let typeId = filters?.servicesType?.id {
            typeIds = [typeId]
        } else {
            typeIds = nil
        }
        subtypeIds = filters?.servicesSubtypes?.map( { $0.id } )

        if let priceRange = filters?.priceRange {
            switch priceRange {
            case .freePrice:
                freePrice = true
            case let .priceRange(min, max):
                minPrice = min
                maxPrice = max
            }
        }
    }

}
