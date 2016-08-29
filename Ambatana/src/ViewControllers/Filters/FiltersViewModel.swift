//
//  FiltersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit

protocol FiltersViewModelDelegate: BaseViewModelDelegate {
    func vmDidUpdate()
    func vmOpenLocation(locationViewModel: EditLocationViewModel)
    func vmForcePriceFix()
}

protocol FiltersViewModelDataDelegate: class {
    
    func viewModelDidUpdateFilters(viewModel: FiltersViewModel, filters: ProductFilters)
    
}

class FiltersViewModel: BaseViewModel {
    
    //Model delegate
    weak var delegate: FiltersViewModelDelegate?
    
    //DataDelegate
    weak var dataDelegate : FiltersViewModelDataDelegate?

    //Location vars
    var place: Place? {
        get {
            return productFilter.place
        }
        set {
            productFilter.place = newValue
        }
    }
    
    //Distance vars
    var currentDistanceRadius : Int {
        get {
            return productFilter.distanceRadius ?? 0
        }
        set {
            productFilter.distanceRadius = newValue > 0 ? newValue : nil
        }
    }
    
    var distanceType : DistanceType {
        return productFilter.distanceType
    }
      
    //Category vars
    private var categoryRepository: CategoryRepository
    private var categories: [ProductCategory]
    
    var numOfCategories : Int {
        return self.categories.count
    }
    
    //Within vars
    var numOfWithinTimes : Int {
        return self.withinTimes.count
    }
    private var withinTimes : [ProductTimeCriteria]
    
    //SortOptions vars
    var numOfSortOptions : Int {
        return self.sortOptions.count
    }
    private var sortOptions : [ProductSortCriteria]

    private var minPrice: Int? {
        didSet {
            validatePriceRange()
        }
    }
    private var maxPrice: Int? {
        didSet {
            validatePriceRange()
        }
    }
    
    private var productFilter : ProductFilters
    
    
    override convenience init() {
        self.init(currentFilters: ProductFilters())
    }
    
    convenience init(currentFilters: ProductFilters) {
        self.init(categoryRepository: Core.categoryRepository, categories: [],
            withinTimes: ProductTimeCriteria.allValues(), sortOptions: ProductSortCriteria.allValues(),
            currentFilters: currentFilters)
    }
    
    required init(categoryRepository: CategoryRepository, categories: [ProductCategory],
                  withinTimes: [ProductTimeCriteria], sortOptions: [ProductSortCriteria], currentFilters: ProductFilters) {
        self.categoryRepository = categoryRepository
        self.categories = categories
        self.withinTimes = withinTimes
        self.sortOptions = sortOptions
        self.productFilter = currentFilters
        self.minPrice = currentFilters.minPrice
        self.maxPrice = currentFilters.maxPrice
        super.init()
    }
    
    // MARK: - Actions

    func locationButtonPressed() {
        let locationVM = EditLocationViewModel(mode: .SelectLocation, initialPlace: place)
        locationVM.locationDelegate = self
        delegate?.vmOpenLocation(locationVM)
    }
    
    func resetFilters() {
        self.productFilter = ProductFilters()
        delegate?.vmDidUpdate()
    }
    
    func saveFilters() {
        
        // Tracking
        
        var categories : [String] = []
        
        for category in productFilter.selectedCategories {
            categories.append(String(category.rawValue))
        }
        
        let trackingEvent = TrackerEvent.filterComplete(productFilter.filterCoordinates,
                                                        distanceRadius: productFilter.distanceRadius,
                                                        distanceUnit: productFilter.distanceType,
                                                        categories: productFilter.selectedCategories,
                                                        sortBy: productFilter.selectedOrdering,
                                                        postedWithin: productFilter.selectedWithin,
                                                        priceFrom: productFilter.minPrice,
                                                        priceTo: productFilter.maxPrice)
        TrackerProxy.sharedInstance.trackEvent(trackingEvent)
        
        dataDelegate?.viewModelDidUpdateFilters(self, filters: productFilter)
    }
    
    // MARK: Categories
    
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
    
    func selectCategoryAtIndex(index: Int) {
        guard index < numOfCategories else { return }
        
        productFilter.toggleCategory(categories[index])
        self.delegate?.vmDidUpdate()
    }
    
    func categoryTextAtIndex(index: Int) -> String? {
        guard index < numOfCategories else { return nil }
        
        return categories[index].name
    }
    
    func categoryIconAtIndex(index: Int) -> UIImage? {
        guard index < numOfCategories else { return nil }
        
        let category = categories[index]
        return category.imageSmallInactive?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }
    
    func categoryColorAtIndex(index: Int) -> UIColor {
        guard index < numOfCategories else { return UIColor.blackText }
        
        let category = categories[index]
        return productFilter.hasSelectedCategory(category) ? UIColor.redText : UIColor.blackText
    }

    func categorySelectedAtIndex(index: Int) -> Bool {
        guard index < numOfCategories else { return false }
        return productFilter.selectedCategories.contains(categories[index])
    }
    
    // MARK: Within
    func selectWithinTimeAtIndex(index: Int) {
        guard index < numOfWithinTimes else { return }
        
        productFilter.selectedWithin = withinTimes[index]
        self.delegate?.vmDidUpdate()
    }
    
    func withinTimeNameAtIndex(index: Int) -> String? {
        guard index < numOfWithinTimes else { return nil }
        
        return withinTimes[index].name
    }
    
    func withinTimeSelectedAtIndex(index: Int) -> Bool {
        guard index < numOfWithinTimes else { return false }
        
        return withinTimes[index] == productFilter.selectedWithin
    }
    
    // MARK: Filter by
    
    func selectSortOptionAtIndex(index: Int) {
        guard index < numOfSortOptions else { return }

        let selected = sortOptions[index]
        if productFilter.selectedOrdering == selected {
            productFilter.selectedOrdering = nil
        } else {
            productFilter.selectedOrdering = selected
        }
        self.delegate?.vmDidUpdate()
    }

    func sortOptionTextAtIndex(index: Int) -> String? {
        guard index < numOfSortOptions else { return nil }
        
        return sortOptions[index].name
    }
    
    func sortOptionSelectedAtIndex(index: Int) -> Bool {
        guard index < numOfSortOptions else { return false }
        guard let selectedOrdering = productFilter.selectedOrdering else { return false }
        return sortOptions[index] == selectedOrdering
    }

    // MARK: Price

    func setMinPrice(value: String?) {
        guard let value = value else {
            minPrice = nil
            return
        }
        minPrice = Int(value)
        productFilter.minPrice = minPrice
    }

    func setMaxPrice(value: String?) {
        guard let value = value else {
            maxPrice = nil
            return
        }
        maxPrice = Int(value)
        productFilter.maxPrice = maxPrice
    }

    func priceAtIndex(index: Int) -> String? {
        guard index < 2 else { return nil }
        switch index {
        case 0:
            guard let minPrice = minPrice else { return nil }
            return String(minPrice)
        case 1:
            guard let maxPrice = maxPrice else { return nil }
            return String(maxPrice)
        default:
            return nil
        }
    }

    private func validatePriceRange() {
        // if one is empty, is OK
        guard let minPrice = minPrice else { return }
        guard let maxPrice = maxPrice else { return }
        guard minPrice > maxPrice else { return }
        delegate?.vmShowAutoFadingMessage(LGLocalizedString.filtersPriceWrongRangeError, completion: { [weak self] in
            self?.delegate?.vmForcePriceFix()
        })
    }
}


// MARK: - EditUserLocationDelegate

extension FiltersViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(place: Place) {
        productFilter.place = place
        delegate?.vmDidUpdate()
    }
}
