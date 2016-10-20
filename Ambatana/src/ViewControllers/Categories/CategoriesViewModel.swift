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
    private var categories: [FilterCategoryItem]

    var numOfCategories : Int {
        return self.categories.count
    }

    weak var delegate: CategoriesViewModelDelegate?
    weak var tabNavigator: TabNavigator?

    
    override convenience init() {
        self.init(categoryRepository: Core.categoryRepository, categories: [])
    }

    required init(categoryRepository: CategoryRepository, categories: [FilterCategoryItem]) {
        self.categoryRepository = categoryRepository
        self.categories = categories
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

    private func buildFullCategoryItemsWithCategories(categories: [ProductCategory]) -> [FilterCategoryItem] {
        let filterCatItems: [FilterCategoryItem] = FeatureFlags.freePostingMode.enabled ? [.Free] : []
        let builtCategories = categories.map { FilterCategoryItem(category: $0) }
        return filterCatItems + builtCategories
    }

    /**
        Returns a product category.
        
        :param:  index index of the category to return
        :return: A product category.
    */

    func categoryAtIndex(index: Int) -> FilterCategoryItem? {
        if index < numOfCategories {
            return categories[index]
        }
        return nil
    }
    
    /**
        Returns a view model for category.
    
        :param:  index index of the category of the products to show
        :return: A view model for category.
    */
    func productsViewModelForCategoryAtIndex(index: Int) -> MainProductsViewModel? {
        if index < numOfCategories {
            //Access from categories should be the exact same behavior as access filters and select that category
            var productFilters = ProductFilters()
            let category = categories[index]
            switch category {
            case .Free:
                productFilters.selectedFree = !productFilters.selectedFree
            case .Category(let cat):
                productFilters.toggleCategory(cat)
            }
            return MainProductsViewModel(filters: productFilters, tabNavigator: tabNavigator)
        }
        return nil
    }
}
