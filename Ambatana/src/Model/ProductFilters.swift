//
//  ProductFilter.swift
//  LetGo
//
//  Created by Eli Kohen on 10/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public struct ProductFilters {
    
    var distanceRadius : Int
    var distanceType : DistanceType
    
    var selectedCategories : [ProductCategory]
    
    var selectedWithin : ProductTimeCriteria
    
    var selectedOrdering : ProductSortCriteria
    
    var filterCoordinates : LGLocationCoordinates2D?
    
    init() {
        self.init(
            distanceRadius : Constants.distanceFilterDefault,
            distanceType: DistanceType.systemDistanceType(),
            selectedCategories: [],
            selectedWithin: ProductTimeCriteria.defaultOption,
            selectedOrdering: ProductSortCriteria.defaultOption
        )
    }
    
    init(distanceRadius: Int, distanceType: DistanceType, selectedCategories: [ProductCategory], selectedWithin: ProductTimeCriteria, selectedOrdering: ProductSortCriteria){
        self.distanceRadius = distanceRadius
        self.distanceType = distanceType
        self.selectedCategories = selectedCategories
        self.selectedWithin = selectedWithin
        self.selectedOrdering = selectedOrdering
    }
    
    mutating func toggleCategory(category: ProductCategory) {
        if let categoryIndex = indexForCategory(category) {
            selectedCategories.removeAtIndex(categoryIndex)
        }
        else {
            selectedCategories.append(category)
        }
    }
    
    func hasSelectedCategory(category: ProductCategory) -> Bool{
        
        return indexForCategory(category) != nil
        
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
