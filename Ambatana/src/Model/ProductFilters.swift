//
//  ProductFilter.swift
//  LetGo
//
//  Created by Eli Kohen on 10/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit

public enum FilterCategoryItem: Equatable {
    case Category(category: ProductCategory)
    case Free

    init(category: ProductCategory) {
        self = .Category(category: category)
    }

    var name: String {
        switch self {
        case let .Category(category: category):
            return category.name
        case .Free:
            return LGLocalizedString.categoriesFree
        }
    }

    var icon: UIImage? {
        switch self {
        case let .Category(category: category):
            return category.imageSmallInactive
        case .Free:
            return UIImage(named: "categories_free_inactive")
        }
    }

    var image: UIImage? {
        switch self {
        case let .Category(category: category):
            return category.image
        case .Free:
            return UIImage(named: "categories_free")
        }
    }

    var filterCategoryId: Int? {
        switch self {
        case let .Category(category: category):
            return category.rawValue
        case .Free:
            return nil
        }
    }
}

public func ==(a: FilterCategoryItem, b: FilterCategoryItem) -> Bool {
    switch (a, b) {
    case (.Category(let catA), .Category(let catB)) where catA.rawValue == catB.rawValue: return true
    case (.Free,   .Free): return true
    default: return false
    }
}

public struct ProductFilters {
    
    var place: Place?
    var distanceRadius: Int?
    var distanceType: DistanceType
    var selectedCategories: [FilterCategoryItem]
    var selectedWithin: ProductTimeCriteria
    var selectedOrdering: ProductSortCriteria?
    var filterCoordinates: LGLocationCoordinates2D? {
        return place?.location
    }
    var minPrice: Int?
    var maxPrice: Int?
    var selectedFree: Bool

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
    
    init(place: Place?, distanceRadius: Int, distanceType: DistanceType, selectedCategories: [FilterCategoryItem],
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
    
    mutating func toggleCategory(category: FilterCategoryItem) {
        switch category {
        case .Free:
            selectedFree = !selectedFree
        case .Category:
            break
        }
        if let categoryIndex = indexForCategory(category) {
            selectedCategories.removeAtIndex(categoryIndex)
        } else {
            selectedCategories.append(category)
        }
    }
    
    func hasSelectedCategory(category: FilterCategoryItem) -> Bool {
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
    
    private func indexForCategory(category: FilterCategoryItem) -> Int? {
        for i in 0..<selectedCategories.count {
            if(selectedCategories[i] == category){
                return i
            }
        }
        return nil
    }
}
