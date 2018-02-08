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
        case (.listingCategory(let lListingCategory), .listingCategory(let rListingCategory)):
            return lListingCategory == rListingCategory
        case (.mostSearchedItems, .mostSearchedItems):
            return true
        default:
            return false
        }
    }
}

protocol ExpandableCategorySelectionDelegate: class {
    func didPressCloseButton()
    func didPressCategory(_ category: ExpandableCategory)
    func didPressTag(_ mostSearchedItem: LocalMostSearchedItem)
}

class ExpandableCategorySelectionViewModel: BaseViewModel {
    
    weak var delegate: ExpandableCategorySelectionDelegate?
    let categoriesAvailable: [ExpandableCategory]
    let tagsEnabled: Bool
    
    var mostSearchedItems: [LocalMostSearchedItem] {
        return LocalMostSearchedItem.allValues
    }
    var tags: [String] {
        return mostSearchedItems.map { $0.name }
    }
    
    
    // MARK: - View lifecycle
    
    init(realEstateEnabled: Bool, trendingButtonEnabled: Bool, tagsEnabled: Bool) {
        var categories: [ExpandableCategory] = [.listingCategory(listingCategory: .unassigned),
                                                .listingCategory(listingCategory: .motorsAndAccessories),
                                                .listingCategory(listingCategory: .cars)]
        if realEstateEnabled {
            let insertIndex = categories.count >= 1 ? 1 : 0
            categories.insert(.listingCategory(listingCategory: .realEstate), at: insertIndex)
        }
        if trendingButtonEnabled {
            categories.insert(.mostSearchedItems, at: 0)
        }
        self.categoriesAvailable = categories
        self.tagsEnabled = tagsEnabled
        super.init()
    }
    
    
    // MARK: - UI Actions
    
    func closeButtonAction() {
        delegate?.didPressCloseButton()
    }
    
    func pressCategoryAction(category: ExpandableCategory) {
        delegate?.didPressCategory(category)
    }
    
    func pressTagAtIndex(_ index: Int) {
        let mostSearchedItem = mostSearchedItems[index]
        delegate?.didPressTag(mostSearchedItem)
    }
}
