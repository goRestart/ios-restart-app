//
//  ExpandableCategorySelectionViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 01/09/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

enum ExpandableCategoryStyle {
    case redBackground
    case whiteBackground
}

enum ExpandableCategory: Equatable {
    case listingCategory(listingCategory: ListingCategory)
    case mostSearchedItems
    
    var listingCategory: ListingCategory? {
        switch self {
        case .listingCategory(let listingCategory):
            return listingCategory
        case .mostSearchedItems:
            return nil
        }
    }
    
    var style: ExpandableCategoryStyle {
        switch self {
        case .listingCategory(_):
            return .redBackground
        case .mostSearchedItems:
            return .whiteBackground
        }
    }
    
    static public func ==(lhs: ExpandableCategory, rhs: ExpandableCategory) -> Bool {
        switch (lhs, rhs) {
        case (.listingCategory, .listingCategory):
            return true
        case (.mostSearchedItems, .mostSearchedItems):
            return true
        default:
            return false
        }
    }
}

protocol ExpandableCategorySelectionDelegate: class {
    func didPressCloseButton()
    func didPress(category: ExpandableCategory)
}

class ExpandableCategorySelectionViewModel: BaseViewModel {
    
    weak var delegate: ExpandableCategorySelectionDelegate?
    let categoriesAvailable: [ExpandableCategory]
    
    // MARK: - View lifecycle
    
    init(realEstateEnabled: Bool, mostSearchedItemsEnabled: Bool) {
        var categories: [ExpandableCategory] = [.listingCategory(listingCategory: .unassigned),
                                                .listingCategory(listingCategory: .motorsAndAccessories),
                                                .listingCategory(listingCategory: .cars)]
        if realEstateEnabled {
            categories.insert(.listingCategory(listingCategory: .realEstate), at: categories.count-1)
        }
        if mostSearchedItemsEnabled {
            categories.insert(.mostSearchedItems, at: 0)
        }
        self.categoriesAvailable = categories
        super.init()
    }
    
    // Button actions: 
    
    func closeButtonAction() {
        delegate?.didPressCloseButton()
    }
    
    func pressCategoryAction(category: ExpandableCategory) {
        delegate?.didPress(category: category)
    }
}
