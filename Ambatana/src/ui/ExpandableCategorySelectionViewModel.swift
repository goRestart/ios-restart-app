//
//  ExpandableCategorySelectionViewModel.swift
//  LetGo
//
//  Created by Juan Iglesias on 01/09/2017.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import LGCoreKit

protocol ExpandableCategorySelectionDelegate: class {
    func closeButtonDidPressed()
    func categoryButtonDidPressed(listingCategory: ListingCategory)
}

class ExpandableCategorySelectionViewModel: BaseViewModel {
    
    weak var delegate: ExpandableCategorySelectionDelegate?
    let categoriesAvailable: [ListingCategory]
    
    // MARK: - View lifecycle
    
    override init() {
        self.categoriesAvailable = [.unassigned, .motorsAndAccessories, .cars]
        super.init()
    }
    
    // Button actions: 
    
    func closeButtonDidPressed() {
        delegate?.closeButtonDidPressed()
    }
    
    func categoryButtonDidPressed(listingCategory: ListingCategory) {
        delegate?.categoryButtonDidPressed(listingCategory: listingCategory)
    }
}

extension ListingCategory {
    var title: String {
        switch self {
        case .unassigned:
            return LGLocalizedString.categoriesUnassignedItems
        case .motorsAndAccessories, .cars, .homeAndGarden, .babyAndChild, .electronics, .fashionAndAccesories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames:
            return name
        }
    }
    var icon: UIImage? {
        switch self {
        case .unassigned:
            return #imageLiteral(resourceName: "items")
        case .cars:
            return #imageLiteral(resourceName: "carIcon")
        case .motorsAndAccessories:
            return #imageLiteral(resourceName: "motorsAndAccesories")
        case .homeAndGarden, .babyAndChild, .electronics, .fashionAndAccesories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames:
            return image
        }
    }
}
