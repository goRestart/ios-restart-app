//
//  FiltersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol FiltersViewModelDelegate: class {
    
    func viewModelDidUpdate(viewModel: FiltersViewModel)
    
}

class FiltersViewModel: BaseViewModel {
    
    //Model delegate
    weak var delegate: FiltersViewModelDelegate?
    
    //Category vars
    private var categoriesManager: CategoriesManager
    private var categories: [ProductCategory]
    
    var numOfCategories : Int {
        return self.categories.count
    }
    
    //SortOptions vars
    var numOfSortOptions : Int {
        return self.sortOptions.count
    }
    private var sortOptions: [ProductSortOption]
    
    
    override convenience init() {
        self.init(categoriesManager: CategoriesManager.sharedInstance, categories: [], sortOptions: ProductSortOption.allValues())
    }
    
    required init(categoriesManager: CategoriesManager, categories: [ProductCategory], sortOptions: [ProductSortOption]) {
        self.categoriesManager = categoriesManager
        self.categories = categories
        self.sortOptions = sortOptions
        super.init()
    }
    
    // MARK: Categories
    
    /**
    Retrieves the list of categories
    */
    func retrieveCategories() {
        
        // Data
        let myCompletion: CategoriesRetrieveServiceCompletion = { (result: CategoriesRetrieveServiceResult) in
            if let categories = result.value {
                self.categories = categories
                self.delegate?.viewModelDidUpdate(self)
            }
        }
        categoriesManager.retrieveCategoriesWithCompletion(myCompletion)
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
    
    // MARK: Filter by
    /**
    Returns a product sort option.
    
    :param:  index index of the sortOption to return
    :return: A product sort option.
    */
    func sortOptionAtIndex(index: Int) -> ProductSortOption? {
        if index < numOfSortOptions {
            return sortOptions[index]
        }
        return nil
    }

}
