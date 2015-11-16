//
//  ProductFilter.swift
//  LetGo
//
//  Created by Eli Kohen on 10/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

struct ProductFilters {
    
    var distanceKms : Int
    var distanceType : DistanceType
    
    var selectedCategories : [ProductCategory]
    
    var selectedOrdering : ProductSortOption
    
    init(distanceKms: Int = Constants.distanceFilterDefault, distanceType: DistanceType = .Km, selectedCategories: [ProductCategory] = [], selectedOrdering: ProductSortOption = ProductSortOption.defaultOption){
        self.distanceKms = distanceKms
        self.distanceType = distanceType
        self.selectedCategories = selectedCategories
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
