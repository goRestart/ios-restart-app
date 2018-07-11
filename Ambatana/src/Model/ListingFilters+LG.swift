//
//  ListingFilters+LG.swift
//  LetGo
//
//  Created by Tomas Cobo on 15/05/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import LGCoreKit

//  MARK: - Tracking

extension ListingFilters {
    var trackingParams: EventParameters {
        var params = EventParameters()
        
        // Filter Coordinates
        if let actualCoords = filterCoordinates {
            params[.filterLat] = actualCoords.latitude
            params[.filterLng] = actualCoords.longitude
        } else {
            params[.filterLat] = TrackerEvent.defaultValue
            params[.filterLng] = TrackerEvent.defaultValue
        }
        
        // Distance
        params[.filterDistanceRadius] = distanceRadius ?? TrackerEvent.defaultValue
        params[.filterDistanceUnit] = distanceType.rawValue
        
        // Categories
        params[.categoryId] = categoriesTrackValue
        
        // Sorting
        if let sortByParam = selectedOrdering?.trackValue {
            params[.filterSortBy] = sortByParam.rawValue
        }
        
        params[.filterPostedWithin] = selectedWithin.trackValue.rawValue

        params[.priceFrom] = hasMinFilters.rawValue
        params[.priceTo] = hasMaxFilters.rawValue

        var verticalFields: [String] = []
        
        let carParams = carTrackingParams()
        carParams.forEach { (key, value) in
            params[key] = value ?? TrackerEvent.notApply
            guard let _ = value else { return }
            verticalFields.append(key.rawValue)
        }
        
        if let propertyType = realEstatePropertyType?.rawValue {
            params[.propertyType] = String(propertyType)
            verticalFields.append(EventParameterName.propertyType.rawValue)
        } else {
            params[.propertyType] = TrackerEvent.notApply
        }
        let offerTypeValues = realEstateOfferTypes.compactMap({ offerType -> String? in
            return offerType.rawValue
        })
        if !offerTypeValues.isEmpty {
            params[.offerType] = offerTypeValues.joined(separator: ",")
            verticalFields.append(EventParameterName.offerType.rawValue)
        } else {
            params[.offerType] = TrackerEvent.notApply
        }
        
        if let bedrooms = realEstateNumberOfBedrooms?.rawValue {
            params[.bedrooms] = String(bedrooms)
            verticalFields.append(EventParameterName.bedrooms.rawValue)
        } else {
            params[.bedrooms] = TrackerEvent.notApply
        }
        
        if let bathrooms = realEstateNumberOfBathrooms?.rawValue {
            params[.bathrooms] = String(bathrooms)
            verticalFields.append(EventParameterName.bathrooms.rawValue)
        } else {
            params[.bathrooms] = TrackerEvent.notApply
        }
        
        if let sizeSqrMetersMin = realEstateSizeRange.min {
            params[.sizeSqrMetersMin] = String(sizeSqrMetersMin)
            verticalFields.append(EventParameterName.sizeSqrMetersMin.rawValue)
        } else {
            params[.sizeSqrMeters] = TrackerEvent.notApply
        }
        
        if let sizeSqrMetersMax = realEstateSizeRange.max {
            params[.sizeSqrMetersMax] = String(sizeSqrMetersMax)
            verticalFields.append(EventParameterName.sizeSqrMetersMax.rawValue)
        } else {
            params[.sizeSqrMetersMax] = TrackerEvent.notApply
        }
        
        if let rooms = realEstateNumberOfRooms {
            params[.rooms] = rooms.trackingString
            verticalFields.append(EventParameterName.rooms.rawValue)
        } else {
            params[.rooms] = TrackerEvent.notApply
        }
        
        if let serviceTypeId = servicesType?.id {
            params[.serviceType] = serviceTypeId
            verticalFields.append(EventParameterName.serviceType.rawValue)
        } else {
            params[.serviceType] = TrackerEvent.notApply
        }
        
        if let serviceSubtypes = servicesSubtypes?.trackingValue {
            params[.serviceSubtype] = serviceSubtypes
            verticalFields.append(EventParameterName.serviceSubtype.rawValue)
        } else {
            params[.serviceSubtype] = TrackerEvent.notApply
        }
        
        params[.verticalFields] = verticalFields.isEmpty ? TrackerEvent.notApply : verticalFields.joined(separator: ",")
        return params
    }
    
    func searchRelatedNeeded(carSearchActive: Bool) -> Bool {
        return isRealEstateWithFilters || isCarsWithFilters(carSearchActive:carSearchActive) || isServicesWithFilters
    }
    
    // MARK: - Private
    
    private var hasMinFilters: EventParameterBoolean {
        return priceRange.min != nil ? .trueParameter : .falseParameter
    }
    
    private var hasMaxFilters: EventParameterBoolean {
        return priceRange.max != nil ? .trueParameter : .falseParameter
    }
    
    private var isRealEstateWithFilters: Bool {
        return selectedCategories.contains(.realEstate) && hasAnyRealEstateAttributes
    }
    
    private func isCarsWithFilters(carSearchActive: Bool) -> Bool {
        return selectedCategories.contains(.cars) && hasAnyCarAttributes && carSearchActive
    }
    
    private var isServicesWithFilters: Bool {
        return selectedCategories.contains(.services) && hasAnyServicesAttributes
    }
    
    private var categoriesTrackValue: String {
        guard !selectedCategories.isEmpty else { return String(ListingCategory.unassigned.rawValue) }
        return selectedCategories
            .map { String($0.rawValue) }
            .joined(separator: ",")
    }
    
    func carTrackingParams() -> [(EventParameterName, Any?)] {
        let bodyTypes =  carBodyTypes.compactMap { $0.rawValue }.stringCommaSeparated
        let transmissions = carTransmissionTypes.compactMap { $0.rawValue }.stringCommaSeparated
        let fuelTypes = carFuelTypes.compactMap { $0.rawValue }.stringCommaSeparated
        let driveTrains = carDriveTrainTypes.compactMap { $0.rawValue }.stringCommaSeparated
        return [(.make, carMakeName),
                (.model, carModelName),
                (.yearStart, carYearStart?.value),
                (.yearEnd, carYearEnd?.value),
                (.mileageFrom, carMileageStart),
                (.mileageTo, carMileageEnd),
                (.bodyType, bodyTypes),
                (.transmission, transmissions),
                (.fuelType, fuelTypes),
                (.drivetrain, driveTrains),
                (.seatsFrom, carNumberOfSeatsStart),
                (.seatsTo, carNumberOfSeatsEnd)]
    }
    
}
