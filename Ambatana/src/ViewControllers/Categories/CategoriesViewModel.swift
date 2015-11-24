//
//  CategoriesViewModel.swift
//  LetGo
//
//  Created by Dídac on 22/10/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import LGCoreKit
import UIKit

public protocol CategoriesViewModelDelegate: class {
    
    func viewModelDidUpdate(viewModel: CategoriesViewModel)
    

}
public class CategoriesViewModel: BaseViewModel {

    private var categoriesManager: CategoriesManager
    private var categories: [ProductCategory]

    public var numOfCategories : Int {
        return self.categories.count
    }
    public weak var delegate: CategoriesViewModelDelegate?

    
    public override convenience init() {
        self.init(categoriesManager: CategoriesManager.sharedInstance, categories: [])
    }

    public required init(categoriesManager: CategoriesManager, categories: [ProductCategory]) {
        self.categoriesManager = categoriesManager
        self.categories = categories
        super.init()
    }
    
    /**
        Retrieves the list of categories
    */
    
    public func retrieveCategories() {
        
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

    public func categoryAtIndex(index: Int) -> ProductCategory? {
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
    public func productsViewModelForCategoryAtIndex(index: Int) -> MainProductsViewModel? {
        if index < numOfCategories {
            //Access from categories should be the exact same behavior as access filters and select that category
            var productFilters = ProductFilters()
            productFilters.toggleCategory(categories[index])
            
            return MainProductsViewModel(filters: productFilters)
        }
        return nil
    }
    
}
