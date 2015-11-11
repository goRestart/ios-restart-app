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

protocol FiltersViewModelDataDelegate: class {
    
    func viewModelDidUpdateFilters(viewModel: FiltersViewModel, filters: ProductFilters)
    
}

class FiltersViewModel: BaseViewModel {
    
    //Model delegate
    weak var delegate: FiltersViewModelDelegate?
    
    //DataDelegate
    weak var dataDelegate : FiltersViewModelDataDelegate?
    
    //Distance vars
    var currentDistanceKms : Int {
        get{
            return productFilter.distanceKms
        }
        set{
            productFilter.distanceKms = newValue
        }
    }
    
    var distanceType : DistanceType {
        return productFilter.distanceType
    }
    
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
    private var sortOptions : [ProductSortOption]
    
    private var productFilter : ProductFilters
    
    
    override convenience init() {
        self.init(currentFilters: ProductFilters())
    }
    
    convenience init(currentFilters: ProductFilters) {
        self.init(categoriesManager: CategoriesManager.sharedInstance, categories: [], sortOptions: ProductSortOption.allValues(), currentFilters: currentFilters)
    }
    
    required init(categoriesManager: CategoriesManager, categories: [ProductCategory], sortOptions: [ProductSortOption], currentFilters: ProductFilters) {
        self.categoriesManager = categoriesManager
        self.categories = categories
        self.sortOptions = sortOptions
        self.productFilter = currentFilters
        super.init()
    }
    
    // MARK: - Actions
    
    func resetFilters() {
        self.productFilter = ProductFilters()
        delegate?.viewModelDidUpdate(self)
    }
    
    func saveFilters() {
        dataDelegate?.viewModelDidUpdateFilters(self, filters: productFilter)
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
    
    func selectCategoryAtIndex(index: Int) {
        if index < numOfCategories {
            productFilter.toggleCategory(categories[index])
            self.delegate?.viewModelDidUpdate(self)
        }
    }
    
    func categoryTextAtIndex(index: Int) -> String? {
        if index < numOfCategories {
            return categories[index].name
        }
        return nil
    }
    
    func categoryIconAtIndex(index: Int) -> UIImage? {
        if index < numOfCategories {
            let category = categories[index]
            return category.imageSmallInactive?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        }
        return nil
    }
    
    func categoryColorAtIndex(index: Int) -> UIColor {
        if index < numOfCategories {
            let category = categories[index]
            if(productFilter.hasSelectedCategory(category)){
                return category.color
            }
        }
        return StyleHelper.standardTextColor
    }
    
    // MARK: Filter by
    
    func selectSortOptionAtIndex(index: Int) {
        if index < numOfSortOptions {
            productFilter.selectedOrdering = sortOptions[index]
            self.delegate?.viewModelDidUpdate(self)
        }
    }

    func sortOptionTextAtIndex(index: Int) -> String? {
        if index < numOfSortOptions {
            return sortOptions[index].name
        }
        return nil
    }
    
    func sortOptionSelectedAtIndex(index: Int) -> Bool {
        if index < numOfSortOptions {
            return sortOptions[index] == productFilter.selectedOrdering
        }
        return false

    }

}
