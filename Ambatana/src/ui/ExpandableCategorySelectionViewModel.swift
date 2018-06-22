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

extension ExpandableCategory {

    func sortWeight(featureFlags: FeatureFlaggeable) -> Int {
        switch self {
        case .listingCategory(let listingCategory):
            switch listingCategory {
            case .cars:
                return 100
            case .motorsAndAccessories:
                return 80
            case .realEstate:
                return 60
            case .services:
                switch featureFlags.servicesCategoryOnSalchichasMenu {
                case .variantA:
                    return 110  // Should appear above cars
                case .variantB:
                    return 70   // Should appear below motors and accesories
                case .variantC:
                    return 50   // Should appear below real estate
                default:
                    return 10 // Not active, should never happen
                }
            case .unassigned:
                return 0    // Usually at bottom
            default:
                return 10
            }
        case .mostSearchedItems:
            return -10
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
    private(set) var newBadgeCategory: ExpandableCategory?
    
    var mostSearchedItems: [LocalMostSearchedItem] {
        return LocalMostSearchedItem.allValues
    }
    var tags: [String] {
        return mostSearchedItems.map { $0.name }
    }
    
    // MARK: - View lifecycle
    
    init(featureFlags: FeatureFlaggeable) {

        let servicesEnabled = featureFlags.servicesCategoryOnSalchichasMenu.isActive
        let realEstateEnabled = featureFlags.realEstateEnabled.isActive
        let trendingButtonEnabled = featureFlags.mostSearchedDemandedItems == .trendingButtonExpandableMenu

        var categories: [ExpandableCategory] = []
        categories.append(.listingCategory(listingCategory: .unassigned))
        categories.append(.listingCategory(listingCategory: .motorsAndAccessories))
        categories.append(.listingCategory(listingCategory: .cars))

        if realEstateEnabled {
            categories.append(.listingCategory(listingCategory: .realEstate))
        }
        if servicesEnabled {
            categories.append(.listingCategory(listingCategory: .services))
        }
        if trendingButtonEnabled {
            categories.append(.mostSearchedItems)
        }
        self.categoriesAvailable = categories.sorted(by: {
            $0.sortWeight(featureFlags: featureFlags) < $1.sortWeight(featureFlags: featureFlags)
        })
        if servicesEnabled {
            self.newBadgeCategory = .listingCategory(listingCategory: .services)
        } else if featureFlags.realEstateEnabled.isActive {
            self.newBadgeCategory = .listingCategory(listingCategory: .realEstate)
        }
        self.tagsEnabled = featureFlags.mostSearchedDemandedItems == .subsetAboveExpandableMenu
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
