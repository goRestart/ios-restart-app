//
//  CategoriesViewModel.swift
//  LetGo
//
//  Created by Dídac on 22/10/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import UIKit

protocol CategoriesViewModelDelegate: class {
    func vmDidUpdate()
}

class CategoriesViewModel: BaseViewModel {

    private let categoryRepository: CategoryRepository
    private let featureFlags: FeatureFlaggeable
    private var categories: [FilterCategoryItem]

    var numOfCategories : Int {
        return self.categories.count
    }

    weak var delegate: CategoriesViewModelDelegate?

    
    override convenience init() {
        self.init(categoryRepository: Core.categoryRepository, categories: [], featureFlags: FeatureFlags.sharedInstance)
    }

    required init(categoryRepository: CategoryRepository, categories: [FilterCategoryItem], featureFlags: FeatureFlaggeable) {
        self.categoryRepository = categoryRepository
        self.categories = categories
        self.featureFlags = featureFlags
        super.init()
    }
    
    /**
        Retrieves the list of categories
    */
    
    func retrieveCategories() {
        categoryRepository.index(filterVisible: true) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let categories = result.value else { return }
            strongSelf.categories = strongSelf.buildFullCategoryItemsWithCategories(categories)
            strongSelf.delegate?.vmDidUpdate()
        }
    }

    private func buildFullCategoryItemsWithCategories(_ categories: [ListingCategory]) -> [FilterCategoryItem] {
        let filterCatItems: [FilterCategoryItem] = featureFlags.freePostingModeAllowed ? [.free] : []
        let builtCategories = categories.map { FilterCategoryItem(category: $0) }
        return filterCatItems + builtCategories
    }

    /**
        Returns a product category.
        
        :param:  index index of the category to return
        :return: A product category.
    */

    func categoryAtIndex(_ index: Int) -> FilterCategoryItem? {
        if index < numOfCategories {
            return categories[index]
        }
        return nil
    }
    
    private func filtersForCategoryAtIndex(_ index: Int) -> ProductFilters? {
        if index < numOfCategories {
            //Access from categories should be the exact same behavior as access filters and select that category
            var productFilters = ProductFilters()
            let category = categories[index]
            switch category {
            case .free:
                productFilters.priceRange = .freePrice
            case .category(let cat):
                productFilters.toggleCategory(cat)
            }
            return productFilters
        }
        return nil
    }
    
    func didSelectItemAtIndex(_ index: Int) {
//        guard let productFilters = filtersForCategoryAtIndex(index) else { return }
        //Use a navigator to apply filters (related with: https://ambatana.atlassian.net/browse/ABIOS-2271)
    }
}
