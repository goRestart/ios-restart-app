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

enum FilterCategoryItem: Equatable {
    case category(category: ListingCategory)
    case free

    init(category: ListingCategory) {
        self = .category(category: category)
    }

    var name: String {
        switch self {
        case let .category(category: category):
            return category.name
        case .free:
            return LGLocalizedString.categoriesFree
        }
    }

    var icon: UIImage? {
        switch self {
        case let .category(category: category):
            return category.imageSmallInactive
        case .free:
            return UIImage(named: "categories_free_inactive")
        }
    }

    var image: UIImage? {
        switch self {
        case let .category(category: category):
            return category.image
        case .free:
            return UIImage(named: "categories_free")
        }
    }
}

func ==(a: FilterCategoryItem, b: FilterCategoryItem) -> Bool {
    switch (a, b) {
    case (.category(let catA), .category(let catB)) where catA.rawValue == catB.rawValue: return true
    case (.free, .free): return true
    default: return false
    }
}

protocol FiltersViewModelDelegate: BaseViewModelDelegate {
    func vmDidUpdate()
    func vmOpenLocation(_ locationViewModel: EditLocationViewModel)
    func vmForcePriceFix()
}

protocol FiltersViewModelDataDelegate: class {
    
    func viewModelDidUpdateFilters(_ viewModel: FiltersViewModel, filters: ProductFilters)
    
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
    private var withinTimes : [ListingTimeCriteria]
    
    //SortOptions vars
    var numOfSortOptions : Int {
        return self.sortOptions.count
    }
    private var sortOptions : [ListingSortCriteria]

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

    fileprivate var productFilter : ProductFilters
    
    private let featureFlags: FeatureFlaggeable
    
    override convenience init() {
        self.init(currentFilters: ProductFilters())
    }
    
    convenience init(currentFilters: ProductFilters) {
        self.init(categoryRepository: Core.categoryRepository, categories: [],
            withinTimes: ListingTimeCriteria.allValues(), sortOptions: ListingSortCriteria.allValues(),
            currentFilters: currentFilters, featureFlags: FeatureFlags.sharedInstance)
    }
    
    required init(categoryRepository: CategoryRepository, categories: [FilterCategoryItem],
                  withinTimes: [ListingTimeCriteria], sortOptions: [ListingSortCriteria], currentFilters: ProductFilters,
        featureFlags: FeatureFlaggeable) {
        self.categoryRepository = categoryRepository
        self.categories = categories
        self.withinTimes = withinTimes
        self.sortOptions = sortOptions
        self.productFilter = currentFilters
        self.sections = []
        self.featureFlags = featureFlags
        super.init()
        self.sections = generateSections()
    }

    // MARK: - Actions

    private func generateSections() -> [FilterSection] {
        var updatedSections = FilterSection.allValues
        guard let idx = updatedSections.index(of: FilterSection.price), priceCellsDisabled else { return updatedSections }
        updatedSections.remove(at: idx)
        return updatedSections
    }

    func locationButtonPressed() {
        let locationVM = EditLocationViewModel(mode: .selectLocation, initialPlace: place)
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
        let trackingEvent = TrackerEvent.filterComplete(productFilter.filterCoordinates,
                                                        distanceRadius: productFilter.distanceRadius,
                                                        distanceUnit: productFilter.distanceType,
                                                        categories: productFilter.selectedCategories,
                                                        sortBy: productFilter.selectedOrdering,
                                                        postedWithin: productFilter.selectedWithin,
                                                        priceRange: productFilter.priceRange,
                                                        freePostingModeAllowed: featureFlags.freePostingModeAllowed)
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

    private func buildFilterCategoryItemsWithCategories(_ categories: [ListingCategory]) -> [FilterCategoryItem] {
        let filterCatItems: [FilterCategoryItem] = featureFlags.freePostingModeAllowed ? [.free] : []
        let builtCategories = categories.map { FilterCategoryItem(category: $0) }
        return filterCatItems + builtCategories
    }

    func selectCategoryAtIndex(_ index: Int) {
        guard isValidCategory(index) else { return }
        let category = categories[index]
        switch category {
        case .free:
            switch productFilter.priceRange {
            case .freePrice:
                productFilter.priceRange = .priceRange(min: nil, max: nil)
            case .priceRange:
                productFilter.priceRange = .freePrice
            }
            sections = generateSections()
        case .category(let cat):
            productFilter.toggleCategory(cat, carVerticalEnabled: featureFlags.carsVerticalEnabled)
        }
        self.delegate?.vmDidUpdate()
    }
    
    func categoryTextAtIndex(_ index: Int) -> String? {
        guard isValidCategory(index) else { return nil }
        return categories[index].name
    }
    
    func categoryIconAtIndex(_ index: Int) -> UIImage? {
        guard isValidCategory(index) else { return nil }

        let category = categories[index]
        return category.icon?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }
    
    func categoryColorAtIndex(_ index: Int) -> UIColor {
        guard isValidCategory(index) else { return UIColor.blackText }
        let category = categories[index]
        switch category {
        case .free:
            return productFilter.priceRange.free ? UIColor.redText : UIColor.blackText
        case .category(let cat):
            return productFilter.hasSelectedCategory(cat) ? UIColor.redText : UIColor.blackText
        }
    }

    func categorySelectedAtIndex(_ index: Int) -> Bool {
        guard isValidCategory(index) else { return false }
        let category = categories[index]
        switch category {
        case .free:
            return productFilter.priceRange.free
        case .category(let cat):
            return productFilter.selectedCategories.contains(cat)
        }
    }
    
    // MARK: Within
    func selectWithinTimeAtIndex(_ index: Int) {
        guard index < numOfWithinTimes else { return }
        
        productFilter.selectedWithin = withinTimes[index]
        self.delegate?.vmDidUpdate()
    }
    
    func withinTimeNameAtIndex(_ index: Int) -> String? {
        guard index < numOfWithinTimes else { return nil }
        
        return withinTimes[index].name
    }
    
    func withinTimeSelectedAtIndex(_ index: Int) -> Bool {
        guard index < numOfWithinTimes else { return false }
        
        return withinTimes[index] == productFilter.selectedWithin
    }
    
    // MARK: Filter by
    
    func selectSortOptionAtIndex(_ index: Int) {
        guard index < numOfSortOptions else { return }

        let selected = sortOptions[index]
        if productFilter.selectedOrdering == selected {
            productFilter.selectedOrdering = nil
        } else {
            productFilter.selectedOrdering = selected
        }
        self.delegate?.vmDidUpdate()
    }

    func sortOptionTextAtIndex(_ index: Int) -> String? {
        guard index < numOfSortOptions else { return nil }
        
        return sortOptions[index].name
    }
    
    func sortOptionSelectedAtIndex(_ index: Int) -> Bool {
        guard index < numOfSortOptions else { return false }
        guard let selectedOrdering = productFilter.selectedOrdering else { return false }
        return sortOptions[index] == selectedOrdering
    }

    // MARK: Price

    func setMinPrice(_ value: String?) {
        guard let value = value, !productFilter.priceRange.free else { return }
        productFilter.priceRange = .priceRange(min: Int(value), max: maxPrice)
    }

    func setMaxPrice(_ value: String?) {
        guard let value = value, !productFilter.priceRange.free else { return }
        productFilter.priceRange = .priceRange(min: minPrice, max: Int(value))
    }

    private func validatePriceRange() -> Bool {
        // if one is empty, is OK
        guard let minPrice = minPrice else { return true }
        guard let maxPrice = maxPrice else { return true }
        guard minPrice > maxPrice else { return true }

        return false
    }

    private func isValidCategory(_ index: Int) -> Bool {
        // index is in range and avoid the extra blank cell in case num categories is odd
        return index < numOfCategories && !(isOddNumCategories && index == numOfCategories-1)
    }
}


// MARK: - EditUserLocationDelegate

extension FiltersViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place) {
        productFilter.place = place
        delegate?.vmDidUpdate()
    }
}
