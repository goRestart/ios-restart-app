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
    private var categories: [ProductCategory]

    var numOfCategories : Int {
        return self.categories.count
    }
    weak var delegate: CategoriesViewModelDelegate?
    weak var tabNavigator: TabNavigator?

    
    override convenience init() {
        self.init(categoryRepository: Core.categoryRepository, categories: [])
    }

    required init(categoryRepository: CategoryRepository, categories: [ProductCategory]) {
        self.categoryRepository = categoryRepository
        self.categories = categories
        super.init()
    }
    
    /**
        Retrieves the list of categories
    */
    
    func retrieveCategories() {
        categoryRepository.index(filterVisible: true) { [weak self] result in
            guard let categories = result.value else { return }
            self?.categories = categories
            self?.delegate?.vmDidUpdate()
        }
    }

    /**
        Returns a product category.
        
        :param:  index index of the category to return
        :return: A product category.
    */

    func categoryAtIndex(index: Int) -> ProductCategory? {
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
            productFilters.toggleCategory(categories[index])

            return MainProductsViewModel(filters: productFilters, tabNavigator: tabNavigator)
        }
        return nil
    }
}
