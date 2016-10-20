//
//  ProductFilter.swift
//  LetGo
//
//  Created by Eli Kohen on 10/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit


public struct ProductFilters {
    
    var place: Place?
    var distanceRadius: Int?
    var distanceType: DistanceType
    var selectedCategories: [ProductCategory]
    var selectedWithin: ProductTimeCriteria
    var selectedOrdering: ProductSortCriteria?
    var filterCoordinates: LGLocationCoordinates2D? {
        return place?.location
    }
    var minPrice: Int?
    var maxPrice: Int?
    var selectedFree: Bool
        /*
        {
        didSet {
            if selectedFree {
                maxPrice = nil
                minPrice = nil
            }
        }
    }*/

    init() {
        self.init(
            place: nil,
            distanceRadius: Constants.distanceFilterDefault,
            distanceType: DistanceType.systemDistanceType(),
            selectedCategories: [],
            selectedWithin: ProductTimeCriteria.defaultOption,
            selectedOrdering: ProductSortCriteria.defaultOption,
            minPrice: nil,
            maxPrice: nil,
            selectedFree: false
        )
    }
    
    init(place: Place?, distanceRadius: Int, distanceType: DistanceType, selectedCategories: [ProductCategory],
         selectedWithin: ProductTimeCriteria, selectedOrdering: ProductSortCriteria?, minPrice: Int?, maxPrice: Int?,
         selectedFree: Bool){
        self.place = place
        self.distanceRadius = distanceRadius > 0 ? distanceRadius : nil
        self.distanceType = distanceType
        self.selectedCategories = selectedCategories
        self.selectedWithin = selectedWithin
        self.selectedOrdering = selectedOrdering
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.selectedFree = selectedFree
    }
    
    mutating func toggleCategory(category: ProductCategory) {
        if let categoryIndex = indexForCategory(category) {
            selectedCategories.removeAtIndex(categoryIndex)
        } else {
            selectedCategories.append(category)
        }
    }
    
    func hasSelectedCategory(category: ProductCategory) -> Bool {
        return indexForCategory(category) != nil
    }

    func isDefault() -> Bool {
        if let _ = place { return false } //Default is nil
        if let _ = distanceRadius { return false } //Default is nil
        if !selectedCategories.isEmpty { return false }
        if selectedWithin != ProductTimeCriteria.defaultOption { return false }
        if selectedOrdering != ProductSortCriteria.defaultOption { return false }
        if let _ = minPrice, let _ = maxPrice { return false } //Default is nil
        if selectedFree { return false }
        return true
    }
    
    private func indexForCategory(category: ProductCategory) -> Int? {
        for i in 0..<selectedCategories.count {
            if(selectedCategories[i] == category){
                return i
            }
        }
        return nil
    }
}
