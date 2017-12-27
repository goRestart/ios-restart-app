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
    
    init(realEstateEnabled: Bool) {
        self.categoriesAvailable = realEstateEnabled ? [.unassigned, .realEstate, .motorsAndAccessories, .cars] : [.unassigned, .motorsAndAccessories, .cars]
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
