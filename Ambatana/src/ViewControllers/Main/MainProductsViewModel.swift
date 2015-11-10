//
//  ProductsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result

public protocol MainProductsViewModelDelegate: class {
    func mainProductsViewModel(viewModel: MainProductsViewModel, didSearchWithViewModel searchViewModel: MainProductsViewModel)
}

public class MainProductsViewModel: BaseViewModel {

    // Input
    public var category: ProductCategory?
    public var searchString: String?
    
    // Output
    public var title: AnyObject?
    public var hasSearchButton: Bool
    
    // > Delegate
    public weak var delegate: MainProductsViewModelDelegate?
    
    // MARK: - Lifecycle
    
    public init(category: ProductCategory? = nil, searchString: String? = nil) {
        self.category = category
        self.searchString = searchString
        if let cat = category {
            self.title = cat.name()
        } else {
            // Add search text field
            let titleTextField = LGNavBarSearchField(frame: CGRectMake(0, 5, UIScreen.mainScreen().bounds.width, 30))
            self.title = titleTextField
        }
        
//        self.title = category?.name() ?? UIImage(named: "navbar_logo")
        self.hasSearchButton = ( searchString == nil )
        super.init()
    }
    
    // MARK: - Public methods
    
    /**
        Search action.
    */
    public func search() {
        if let actualSearchString = searchString {
            if actualSearchString.characters.count > 0 {

                // Tracking
                TrackerProxy.sharedInstance.trackEvent(TrackerEvent.searchComplete(MyUserManager.sharedInstance.myUser(), searchQuery: searchString ?? ""))
                
                // Notify the delegate
                delegate?.mainProductsViewModel(self, didSearchWithViewModel: viewModelForSearch())
            }
        }
    }
    
    /**
        Called when search button is pressed.
    */
    public func searchButtonPressed() {
        // Tracking
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.searchStart(MyUserManager.sharedInstance.myUser()))
    }
    
    public func resignSearchTextFieldResponder() {
        if let searchFieldTitle = self.title as? LGNavBarSearchField {
            searchFieldTitle.text = ""
            searchFieldTitle.resignFirstResponder()
        }
    }
    
    // MARK: - Private methods
    
    /**
        Returns a view model for search.
    
        :return: A view model for search.
    */
    private func viewModelForSearch() -> MainProductsViewModel {
        return MainProductsViewModel(searchString: searchString)
    }
}
