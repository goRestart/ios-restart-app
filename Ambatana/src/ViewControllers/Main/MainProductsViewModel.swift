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
    func mainProductsViewModel(viewModel: MainProductsViewModel, showFilterViewWithInfo: [String:AnyObject]?)
    func mainProductsViewModel(viewModel: MainProductsViewModel, showTags: [String]?)
}

public class MainProductsViewModel: BaseViewModel {

    // Input
    public var category: ProductCategory?
    public var searchString: String?
    
    // Output
    public var title: AnyObject?
    public var hasSearchButton: Bool
    
    // TODO: remove tmp var (used while developing the "show filters" logic)
    public var tags: [String] {
        didSet {
            delegate?.mainProductsViewModel(self, showTags: tags)
        }
    }
    
    
    // > Delegate
    public weak var delegate: MainProductsViewModelDelegate?
    
    // MARK: - Lifecycle
    
    public init(category: ProductCategory? = nil, searchString: String? = nil, tags: [String]? = nil) {
        self.category = category
        self.searchString = searchString

        self.title = category?.name
        
        self.tags = []
        
//        self.title = category?.name ?? UIImage(named: "navbar_logo")
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
    
    public func showFilters() {
        updateTagsFromFilters()
        
//        delegate?.mainProductsViewModel(self, showFilterViewWithInfo: [:])
    }
    
    /**
        Called when search button is pressed.
    */
    public func searchButtonPressed() {
        // Tracking
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.searchStart(MyUserManager.sharedInstance.myUser()))
    }
    
    public func updateTagsFromFilters(tags: [String]? = ["tag 5", "tag 8", "patata frita"]) {
        self.tags = tags!
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
