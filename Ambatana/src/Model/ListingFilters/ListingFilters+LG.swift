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
        
        verticalFilters.createTrackingParams().forEach { (key, value) in
            params[key] = value ?? TrackerEvent.notApply
            guard let _ = value else { return }
            verticalFields.append(key.rawValue)
        }

        params[.verticalFields] = verticalFields.isEmpty ? TrackerEvent.notApply : verticalFields.joined(separator: ",")
        return params
    }
    
    var isSearchRelatedNeeded: Bool {
        return isRealEstateWithFilters || isCarsWithFilters || isServicesWithFilters
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
    
    private var isCarsWithFilters: Bool {
        return selectedCategories.contains(.cars) && hasAnyCarAttributes
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
}
