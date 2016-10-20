//
//  FiltersViewModel.swift
//  LetGo
//
//  Created by Eli Kohen on 09/11/15.
//  Copyright © 2015 Ambatana. All rights reserved.
//

import UIKit
import LGCoreKit
import RxSwift

public enum FilterCategoryItem: Equatable {
    case Category(category: ProductCategory)
    case Free

    init(category: ProductCategory) {
        self = .Category(category: category)
    }

    var name: String {
        switch self {
        case let .Category(category: category):
            return category.name
        case .Free:
            return LGLocalizedString.categoriesFree
        }
    }

    var icon: UIImage? {
        switch self {
        case let .Category(category: category):
            return category.imageSmallInactive
        case .Free:
            return UIImage(named: "categories_free_inactive")
        }
    }

    var image: UIImage? {
        switch self {
        case let .Category(category: category):
            return category.image
        case .Free:
            return UIImage(named: "categories_free")
        }
    }
}

public func ==(a: FilterCategoryItem, b: FilterCategoryItem) -> Bool {
    switch (a, b) {
    case (.Category(let catA), .Category(let catB)) where catA.rawValue == catB.rawValue: return true
    case (.Free, .Free): return true
    default: return false
    }
}

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

    // Sections
    var sections: [FilterSection]

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
    private var categories: [FilterCategoryItem]

    var numOfCategories : Int {
        // we add an extra empty cell if the num of categories is odds
        return isOddNumCategories ? self.categories.count+1 : self.categories.count
    }

    var isOddNumCategories: Bool {
        return self.categories.count%2 == 1
    }

    var priceCellsDisabled: Bool {
        return self.productFilter.priceRange.free
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
        return productFilter.priceRange.min
    }
    private var maxPrice: Int? {
        return productFilter.priceRange.max
    }

    var minPriceString: String? {
        guard let minPrice = minPrice else { return nil }
        return String(minPrice)
    }
    var maxPriceString: String? {
        guard let maxPrice = maxPrice else { return nil }
        return String(maxPrice)
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
    
    required init(categoryRepository: CategoryRepository, categories: [FilterCategoryItem],
                  withinTimes: [ProductTimeCriteria], sortOptions: [ProductSortCriteria], currentFilters: ProductFilters) {
        self.categoryRepository = categoryRepository
        self.categories = categories
        self.withinTimes = withinTimes
        self.sortOptions = sortOptions
        self.productFilter = currentFilters
        self.sections = []
        super.init()
        self.sections = generateSections()
    }

    // MARK: - Actions

    private func generateSections() -> [FilterSection] {
        var updatedSections = FilterSection.allValues()
        guard let idx = updatedSections.indexOf(FilterSection.Price) where priceCellsDisabled else { return updatedSections }
        updatedSections.removeAtIndex(idx)
        return updatedSections
    }

    func locationButtonPressed() {
        let locationVM = EditLocationViewModel(mode: .SelectLocation, initialPlace: place)
        locationVM.locationDelegate = self
        delegate?.vmOpenLocation(locationVM)
    }
    
    func resetFilters() {
        self.productFilter = ProductFilters()
        delegate?.vmDidUpdate()
    }

    func validateFilters() -> Bool {
        guard validatePriceRange() else {
            delegate?.vmShowAutoFadingMessage(LGLocalizedString.filtersPriceWrongRangeError, completion: { [weak self] in
                self?.delegate?.vmForcePriceFix()
                })
            return false
        }
        return true
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
                                                        categories: categories,
                                                        sortBy: productFilter.selectedOrdering,
                                                        postedWithin: productFilter.selectedWithin,
                                                        priceRange: productFilter.priceRange)
        TrackerProxy.sharedInstance.trackEvent(trackingEvent)
        
        dataDelegate?.viewModelDidUpdateFilters(self, filters: productFilter)
    }
    
    // MARK: Categories
    
    /**
    Retrieves the list of categories
    */
    func retrieveCategories() {
        categoryRepository.index(filterVisible: true) { [weak self] result in
            guard let strongSelf = self else { return }
            guard let categories = result.value else { return }
            strongSelf.categories = strongSelf.buildFilterCategoryItemsWithCategories(categories)
            strongSelf.delegate?.vmDidUpdate()
        }
    }

    private func buildFilterCategoryItemsWithCategories(categories: [ProductCategory]) -> [FilterCategoryItem] {
        let filterCatItems: [FilterCategoryItem] = FeatureFlags.freePostingMode.enabled ? [.Free] : []
        let builtCategories = categories.map { FilterCategoryItem(category: $0) }
        return filterCatItems + builtCategories
    }

    func selectCategoryAtIndex(index: Int) {
        guard isValidCategory(index) else { return }
        let category = categories[index]
        switch category {
        case .Free:
            switch productFilter.priceRange {
            case .FreePrice:
                productFilter.priceRange = .PriceRange(min: nil, max: nil)
            case .PriceRange:
                productFilter.priceRange = .FreePrice
            }
            sections = generateSections()
        case .Category(let cat):
            productFilter.toggleCategory(cat)
        }
        self.delegate?.vmDidUpdate()
    }
    
    func categoryTextAtIndex(index: Int) -> String? {
        guard isValidCategory(index) else { return nil }
        return categories[index].name
    }
    
    func categoryIconAtIndex(index: Int) -> UIImage? {
        guard isValidCategory(index) else { return nil }

        let category = categories[index]
        return category.icon?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    }
    
    func categoryColorAtIndex(index: Int) -> UIColor {
        guard isValidCategory(index) else { return UIColor.blackText }
        let category = categories[index]
        switch category {
        case .Free:
            return productFilter.priceRange.free ? UIColor.redText : UIColor.blackText
        case .Category(let cat):
            return productFilter.hasSelectedCategory(cat) ? UIColor.redText : UIColor.blackText
        }
    }

    func categorySelectedAtIndex(index: Int) -> Bool {
        guard isValidCategory(index) else { return false }
        let category = categories[index]
        switch category {
        case .Free:
            return productFilter.priceRange.free
        case .Category(let cat):
            return productFilter.selectedCategories.contains(cat)
        }
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
        guard let value = value where !productFilter.priceRange.free else { return }
        productFilter.priceRange = .PriceRange(min: Int(value), max: maxPrice)
    }

    func setMaxPrice(value: String?) {
        guard let value = value where !productFilter.priceRange.free else { return }
        productFilter.priceRange = .PriceRange(min: minPrice, max: Int(value))
    }

    private func validatePriceRange() -> Bool {
        // if one is empty, is OK
        guard let minPrice = minPrice else { return true }
        guard let maxPrice = maxPrice else { return true }
        guard minPrice > maxPrice else { return true }

        return false
    }

    private func isValidCategory(index: Int) -> Bool {
        // index is in range and avoid the extra blank cell in case num categories is odd
        return index < numOfCategories && !(isOddNumCategories && index == numOfCategories-1)
    }
}


// MARK: - EditUserLocationDelegate

extension FiltersViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(place: Place) {
        productFilter.place = place
        delegate?.vmDidUpdate()
    }
}
