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

protocol MainProductsViewModelDelegate: class {
    func mainProductsViewModel(viewModel: MainProductsViewModel, didSearchWithViewModel searchViewModel: MainProductsViewModel)
    func mainProductsViewModel(viewModel: MainProductsViewModel, showFilterWithViewModel filtersVM: FiltersViewModel)
    func mainProductsViewModel(viewModel: MainProductsViewModel, showTags: [FilterTag])
}

public class MainProductsViewModel: BaseViewModel, FiltersViewModelDataDelegate {

    // Input
    public var category: ProductCategory?
    public var searchString: String?
    
    // Output
    public var title: AnyObject?
//    public var hasSearchButton: Bool
    
    public var tags: [FilterTag] {
        guard let theFilters = filters else {
            return []
        }
        
        var resultTags : [FilterTag] = []
        for prodCat in theFilters.selectedCategories {
            resultTags.append(.Category(prodCat))
        }
        
        if(theFilters.selectedOrdering != ProductSortCriteria.defaultOption) {
            resultTags.append(.OrderBy(theFilters.selectedOrdering))
        }
        return resultTags
    }
    
    var filters : ProductFilters?
    
    
    weak var mainProductListView : MainProductListView?
    
    
    // > Delegate
    weak var delegate: MainProductsViewModelDelegate?
    
    // MARK: - Lifecycle
    
    public init(category: ProductCategory? = nil, searchString: String? = nil, filters: ProductFilters? = nil) {
        self.category = category
        self.searchString = searchString
        self.filters = filters

        self.title = category?.name
        
//        self.title = category?.name ?? UIImage(named: "navbar_logo")
//        self.hasSearchButton = ( searchString == nil )
        super.init()
    }
    
    
    // MARK: FiltersViewModelDataDelegate
    
    func viewModelDidUpdateFilters(viewModel: FiltersViewModel, filters: ProductFilters) {
        self.filters = filters
        
        delegate?.mainProductsViewModel(self, showTags: self.tags)
        
        updateListView()
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
        
        let filtersVM = FiltersViewModel(currentFilters: filters ?? ProductFilters(distanceType: DistanceType.systemDistanceType()))
        filtersVM.dataDelegate = self
        
        delegate?.mainProductsViewModel(self, showFilterWithViewModel: filtersVM)

        // Tracking
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.filterStart())
    }
    
    /**
        Called when search button is pressed.
    */
    public func searchBegan() {
        // Tracking
        TrackerProxy.sharedInstance.trackEvent(TrackerEvent.searchStart(MyUserManager.sharedInstance.myUser()))
    }
    
    
    /**
        Called when a filter gets removed
    */
    public func updateFiltersFromTags(tags: [FilterTag]) {
        
        //Tags gan only be deleted so if there where tags means there was a filters object
        if filters == nil {
            return
        }
        
        var categories : [ProductCategory] = []
        var orderBy = ProductSortCriteria.defaultOption
        
        for filterTag in tags {
            switch filterTag {
            case .Category(let prodCategory):
                categories.append(prodCategory)
            case .OrderBy(let prodSortOption):
                orderBy = prodSortOption
            }
        }
        
        filters?.selectedCategories = categories
        filters?.selectedOrdering = orderBy
        
        updateListView()
    }
    
    
    // MARK: - Private methods
    
    /**
        Returns a view model for search.
    
        :return: A view model for search.
    */
    private func viewModelForSearch() -> MainProductsViewModel {
        return MainProductsViewModel(searchString: searchString, filters: filters)
    }
    
    private func updateListView() {
        mainProductListView?.categories = self.filters?.selectedCategories
        mainProductListView?.sortCriteria = self.filters?.selectedOrdering
        mainProductListView?.distanceRadius = self.filters?.distanceRadius
        mainProductListView?.distanceType = self.filters?.distanceType
        mainProductListView?.refresh()
    }
    
}
