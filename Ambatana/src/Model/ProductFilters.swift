//
//  ProductFilter.swift
//  LetGo
//
//  Created by Eli Kohen on 10/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

enum FilterPriceRange: Equatable {
    case freePrice
    case priceRange(min: Int?, max: Int?)

    var min: Int? {
        switch self {
        case .freePrice:
            return nil
        case let .priceRange(min: minPrice, max: _):
            return minPrice
        }
    }

    var max: Int? {
        switch self {
        case .freePrice:
            return nil
        case let .priceRange(min: _, max: maxPrice):
            return maxPrice
        }
    }

    var free: Bool {
        switch self {
        case .freePrice:
            return true
        case .priceRange:
            return false
        }
    }
}

func ==(a: FilterPriceRange, b: FilterPriceRange) -> Bool {
    switch (a, b) {
    case (let .priceRange(minA, maxA), let .priceRange(minB, maxB)) where minA == minB && maxA == maxB : return true
    case (.freePrice, .freePrice): return true
    default: return false
    }
}

struct ProductFilters {
    
    var place: Place?
    var distanceRadius: Int?
    var distanceType: DistanceType
    var selectedCategories: [ListingCategory]
    var selectedWithin: ListingTimeCriteria
    var selectedOrdering: ListingSortCriteria?
    var filterCoordinates: LGLocationCoordinates2D? {
        return place?.location
    }
    var priceRange: FilterPriceRange

    init() {
        self.init(
            place: nil,
            distanceRadius: Constants.distanceFilterDefault,
            distanceType: DistanceType.systemDistanceType(),
            selectedCategories: [],
            selectedWithin: ListingTimeCriteria.defaultOption,
            selectedOrdering: ListingSortCriteria.defaultOption,
            priceRange: .priceRange(min: nil, max: nil)
        )
    }
    
    init(place: Place?, distanceRadius: Int, distanceType: DistanceType, selectedCategories: [ListingCategory],
         selectedWithin: ListingTimeCriteria, selectedOrdering: ListingSortCriteria?, priceRange: FilterPriceRange){
        self.place = place
        self.distanceRadius = distanceRadius > 0 ? distanceRadius : nil
        self.distanceType = distanceType
        self.selectedCategories = selectedCategories
        self.selectedWithin = selectedWithin
        self.selectedOrdering = selectedOrdering
        self.priceRange = priceRange
    }
    
    mutating func toggleCategory(_ category: ListingCategory) {
        if let categoryIndex = indexForCategory(category) {
            selectedCategories.remove(at: categoryIndex)
        } else {
            selectedCategories.append(category)
        }
    }
    
    func hasSelectedCategory(_ category: ListingCategory) -> Bool {
        return indexForCategory(category) != nil
    }

    func isDefault() -> Bool {
        if let _ = place { return false } //Default is nil
        if let _ = distanceRadius { return false } //Default is nil
        if !selectedCategories.isEmpty { return false }
        if selectedWithin != ListingTimeCriteria.defaultOption { return false }
        if selectedOrdering != ListingSortCriteria.defaultOption { return false }
        if priceRange != .priceRange(min: nil, max: nil) { return false }
        return true
    }
    
    private func indexForCategory(_ category: ListingCategory) -> Int? {
        for i in 0..<selectedCategories.count {
            if(selectedCategories[i] == category){
                return i
            }
        }
        return nil
    }
}
