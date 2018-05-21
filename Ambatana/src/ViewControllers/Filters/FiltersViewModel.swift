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
            return category.image
        case .free:
            return UIImage(named: "categories_free_inactive")
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
    func vmForcePriceFix()
    func vmForceSizeFix()
}

protocol FiltersViewModelDataDelegate: class {
    func viewModelDidUpdateFilters(_ viewModel: FiltersViewModel, filters: ListingFilters)
}

class FiltersViewModel: BaseViewModel {
    
    weak var delegate: FiltersViewModelDelegate?
    weak var dataDelegate: FiltersViewModelDataDelegate?
    weak var navigator: FiltersNavigator?

    var sections: [FilterSection]

    var place: Place? {
        get {
            return productFilter.place
        }
        set {
            productFilter.place = newValue
        }
    }
    
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
    
    private var categoryRepository: CategoryRepository
    private var categories: [FilterCategoryItem]

    var currentCarMakeName: String? {
        return productFilter.carMakeName
    }
    var currentCarModelName: String? {
        return productFilter.carModelName
    }
    
    var currentPropertyTypeName: String? {
        return productFilter.realEstatePropertyType?.localizedString
    }
    
    var currentNumberOfBathroomsName: String? {
        return productFilter.realEstateNumberOfBathrooms?.summaryLocalizedString
    }
    
    var currentNumberOfBedroomsName: String? {
        return productFilter.realEstateNumberOfBedrooms?.summaryLocalizedString
    }
    
    var currentNumberOfRoomsName: String? {
        return productFilter.realEstateNumberOfRooms?.localizedString
    }
    
    var modelCellEnabled: Bool {
        return currentCarMakeName != nil
    }
    var carYearStart: Int? {
        get {
            return productFilter.carYearStart?.value
        }
        set {
            guard let newValue = newValue else {
                productFilter.carYearStart = nil
                return
            }
            productFilter.carYearStart = RetrieveListingParam<Int>(value: newValue, isNegated: false)
        }
    }

    var carYearEnd: Int? {
        get {
            return productFilter.carYearEnd?.value
        }
        set {
            guard let newValue = newValue else {
                productFilter.carYearEnd = nil
                return
            }
            productFilter.carYearEnd = RetrieveListingParam<Int>(value: newValue, isNegated: false)
        }
    }

    var numOfCategories : Int {
        // we add an extra empty cell if the num of categories is odds
        return isOddNumCategories ? self.categories.count+1 : self.categories.count
    }

    var isOddNumCategories: Bool {
        return self.categories.count%2 == 1
    }

    var isPriceCellEnabled: Bool {
        return featureFlags.taxonomiesAndTaxonomyChildrenInFeed.isActive || !productFilter.priceRange.free
    }

    var isCarsInfoCellEnabled: Bool {
        let isTaxonomyCars = productFilter.selectedTaxonomyChildren.contains(where: { $0.isCarsTaxonomy } )
        return productFilter.selectedCategories.contains(.cars) || isTaxonomyCars
    }
    
    var isRealEstateInfoCellEnabled: Bool {
        return productFilter.selectedCategories.contains(.realEstate)
    }

    var numOfWithinTimes : Int {
        return self.withinTimes.count
    }
    private var withinTimes : [ListingTimeCriteria]
    
    var offerTypeOptionsCount : Int {
        return self.offerTypeOptions.count
    }
    private var offerTypeOptions : [RealEstateOfferType]
    
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
    
    private var minSize: Int? {
        return productFilter.realEstateSizeRange.min
    }
    private var maxSize: Int? {
        return productFilter.realEstateSizeRange.max
    }
    
    fileprivate var priceRangeAvailable: Bool {
        return productFilter.priceRange != .freePrice
    }

    var minPriceString: String? {
        guard let minPrice = minPrice else { return nil }
        return String(minPrice)
    }
    var maxPriceString: String? {
        guard let maxPrice = maxPrice else { return nil }
        return String(maxPrice)
    }
    
    var minSizeString: String? {
        guard let minSize = minSize else { return nil }
        return String(minSize)
    }
    var maxSizeString: String? {
        guard let maxSize = maxSize else { return nil }
        return String(maxSize)
    }
    
    var isFreeActive: Bool {
        return productFilter.priceRange.free
    }
    
    var isTaxonomiesAndTaxonomyChildrenInFeedEnabled: Bool {
        return featureFlags.taxonomiesAndTaxonomyChildrenInFeed.isActive
    }
    
    var currentTaxonomySelected: Taxonomy? {
        return productFilter.selectedTaxonomy
    }
    
    var currentTaxonomyChildSelected: TaxonomyChild? {
        return productFilter.selectedTaxonomyChildren.last
    }
    
    var currentCategoryNameSelected: String? {
        if let taxonomyChild = productFilter.selectedTaxonomyChildren.last {
            return taxonomyChild.name
        } else if let taxonomy = productFilter.selectedTaxonomy {
            return taxonomy.name
        } else {
            return nil
        }
    }
    
    var filterRealEstateSections: [FilterRealEstateSection] {
        return FilterRealEstateSection.allValues(postingFlowType: postingFlowType)
    }
    
    var carSections: [FilterCarSection] {
        guard featureFlags.searchCarsIntoNewBackend.isActive,
            featureFlags.filterSearchCarSellerType.isActive else {
            return FilterCarSection.all.filter { return !$0.isCarSellerTypeSection }
        }
        return FilterCarSection.all
    }
    
    var filterCarSellerSelectedSections: [FilterCarSection] = []
    
    var postingFlowType: PostingFlowType {
        guard let location = productFilter.place else { return featureFlags.postingFlowType }
        guard let countryCode = location.postalAddress?.countryCode, let country = CountryCode(rawValue: countryCode.localizedLowercase) else { return featureFlags.postingFlowType }
        return country == .turkey ? .turkish : .standard
    }

    fileprivate var productFilter : ListingFilters
    
    private let featureFlags: FeatureFlaggeable
    private let carsInfoRepository: CarsInfoRepository

    override convenience init() {
        self.init(currentFilters: ListingFilters())
    }
    
    convenience init(currentFilters: ListingFilters) {
        self.init(categoryRepository: Core.categoryRepository,
                  categories: [],
                  withinTimes: ListingTimeCriteria.allValues(),
                  sortOptions: ListingSortCriteria.allValues(),
                  offerTypeOptions: RealEstateOfferType.allValues,
                  currentFilters: currentFilters,
                  featureFlags: FeatureFlags.sharedInstance,
                  carsInfoRepository: Core.carsInfoRepository)
    }
    
    required init(categoryRepository: CategoryRepository,
                  categories: [FilterCategoryItem],
                  withinTimes: [ListingTimeCriteria],
                  sortOptions: [ListingSortCriteria],
                  offerTypeOptions: [RealEstateOfferType],
                  currentFilters: ListingFilters,
                  featureFlags: FeatureFlaggeable,
                  carsInfoRepository: CarsInfoRepository) {
        self.categoryRepository = categoryRepository
        self.categories = categories
        self.withinTimes = withinTimes
        self.sortOptions = sortOptions
        self.offerTypeOptions = offerTypeOptions
        self.productFilter = currentFilters
        self.sections = []
        self.featureFlags = featureFlags
        self.carsInfoRepository = carsInfoRepository
        super.init()
        self.sections = generateSections()
        updateCarSelectedSections()
    }

    // MARK: - Actions

    fileprivate func generateSections() -> [FilterSection] {
        let updatedSections = FilterSection.allValues(priceAsLast: !featureFlags.taxonomiesAndTaxonomyChildrenInFeed.isActive)

        return updatedSections.filter { $0 != .price ||  isPriceCellEnabled }
            .filter {$0 != .carsInfo ||  isCarsInfoCellEnabled }
            .filter {!$0.isRealEstateSection || isRealEstateInfoCellEnabled }
    }
    
    private func updateCarSelectedSections() {
        filterCarSellerSelectedSections = productFilter.carSellerTypes.filterCarSectionsFor(feature: featureFlags.filterSearchCarSellerType)
    }

    func locationButtonPressed() {
        let locationVM = EditLocationViewModel(mode: .editFilterLocation,
                                               initialPlace: place,
                                               distanceRadius: productFilter.distanceRadius)
        locationVM.locationDelegate = self
        navigator?.openEditLocation(withViewModel: locationVM)
    }
    
    func categoriesButtonPressed() {
        let taxonomiesVM = TaxonomiesViewModel(taxonomies: categoryRepository.indexTaxonomies(), taxonomySelected: currentTaxonomySelected, taxonomyChildSelected: currentTaxonomyChildSelected, source: .filter)
        taxonomiesVM.taxonomiesDelegate = self
        navigator?.openTaxonomyList(withViewModel: taxonomiesVM)
    }

    func makeButtonPressed() {
        let vm = CarAttributeSelectionViewModel(carsMakes: carsInfoRepository.retrieveCarsMakes(),
                                                selectedMake: productFilter.carMakeId?.value,
                                                style: .filter)
        vm.carAttributeSelectionDelegate = self
        navigator?.openCarAttributeSelection(withViewModel: vm)
    }

    func modelButtonPressed() {
        guard let makeId = productFilter.carMakeId?.value else { return }
        let carsModelsForMakeList = carsInfoRepository.retrieveCarsModelsFormake(makeId: makeId)
        let vm = CarAttributeSelectionViewModel(carsModels: carsModelsForMakeList,
                                                selectedModel: productFilter.carModelId?.value,
                                                style: .filter)
        vm.carAttributeSelectionDelegate = self
        navigator?.openCarAttributeSelection(withViewModel: vm)
    }
    
    func propertyTypeButtonPressed() {
        let attributeValues = RealEstatePropertyType.allValues(postingFlowType: postingFlowType)
        let values = attributeValues.map { $0.localizedString }
        let vm = ListingAttributePickerViewModel(
            title: LGLocalizedString.realEstateTypePropertyTitle,
            attributes: values,
            selectedAttribute: productFilter.realEstatePropertyType?.rawValue
        ) { [weak self] selectedIndex in
            if let selectedIndex = selectedIndex {
                self?.productFilter.realEstatePropertyType = attributeValues[selectedIndex]
            } else {
                self?.productFilter.realEstatePropertyType = nil
            }
            self?.delegate?.vmDidUpdate()
        }
        navigator?.openListingAttributePicker(viewModel: vm)
    }
    
    func numberOfBedroomsPressed() {
        let attributeValues = NumberOfBedrooms.allValues
        let values = attributeValues.map { $0.localizedString }
        let vm = ListingAttributePickerViewModel(
            title: LGLocalizedString.realEstateBedroomsTitle,
            attributes: values,
            selectedAttribute: productFilter.realEstateNumberOfBedrooms?.localizedString
        ) { [weak self] selectedIndex in
            if let selectedIndex = selectedIndex {
                self?.productFilter.realEstateNumberOfBedrooms = attributeValues[selectedIndex]
            } else {
                self?.productFilter.realEstateNumberOfBedrooms = nil
            }
            self?.delegate?.vmDidUpdate()
        }
        navigator?.openListingAttributePicker(viewModel: vm)
    }
    
    func numberOfRoomsPressed() {
        let attributeValues = NumberOfRooms.allValues
        let values = attributeValues.map { $0.localizedString }
        let vm = ListingAttributePickerViewModel(
            title: LGLocalizedString.realEstateRoomsTitle,
            attributes: values,
            selectedAttribute: productFilter.realEstateNumberOfRooms?.localizedString
        ) { [weak self] selectedIndex in
            if let selectedIndex = selectedIndex {
                self?.productFilter.realEstateNumberOfRooms = attributeValues[selectedIndex]
            } else {
                self?.productFilter.realEstateNumberOfRooms = nil
            }
            self?.delegate?.vmDidUpdate()
        }
        navigator?.openListingAttributePicker(viewModel: vm)
    }
    
    func numberOfBathroomsPressed() {
        let attributeValues = NumberOfBathrooms.allValues
        let values = attributeValues.map { $0.localizedString }
        let vm = ListingAttributePickerViewModel(
            title: LGLocalizedString.realEstateBathroomsTitle,
            attributes: values,
            selectedAttribute: productFilter.realEstateNumberOfBathrooms?.localizedString
        ) { [weak self] selectedIndex in
            if let selectedIndex = selectedIndex {
                self?.productFilter.realEstateNumberOfBathrooms = attributeValues[selectedIndex]
            } else {
                self?.productFilter.realEstateNumberOfBathrooms = nil
            }
            self?.delegate?.vmDidUpdate()
        }
        navigator?.openListingAttributePicker(viewModel: vm)
    }
    
    func resetFilters() {
        productFilter = ListingFilters()
        sections = generateSections()
        updateCarSelectedSections()
        delegate?.vmDidUpdate()
    }

    func close() {
        navigator?.closeFilters()
    }

    func validateFilters() -> Bool {
        guard validatePriceRange else {
            delegate?.vmShowAutoFadingMessage(LGLocalizedString.filtersPriceWrongRangeError, completion: { [weak self] in
                self?.delegate?.vmForcePriceFix()
                })
            return false
        }
        guard validateSizeRange else {
            delegate?.vmShowAutoFadingMessage(LGLocalizedString.filtersSizeWrongRangeError, completion: { [weak self] in
                self?.delegate?.vmForceSizeFix()
            })
            return false
        }
        return true
    }

    func saveFilters() {
        TrackerProxy.sharedInstance.trackEvent(.filterComplete(productFilter,
                                                               carSellerType: trackCarSellerType,
                                                               freePostingModeAllowed: featureFlags.freePostingModeAllowed))
        dataDelegate?.viewModelDidUpdateFilters(self, filters: productFilter)
    }
    
    // MARK: Categories
    
    /**
    Retrieves the list of categories
    */
    func retrieveCategories() {
        categoryRepository.index(servicesIncluded: featureFlags.servicesCategoryEnabled.isActive,
                                 carsIncluded: false,
                                 realEstateIncluded: featureFlags.realEstateEnabled.isActive) { [weak self] result in
                                    
            guard let strongSelf = self else { return }
            guard let categories = result.value else { return }
            strongSelf.categories = strongSelf.buildFilterCategoryItemsWithCategories(categories)
            strongSelf.delegate?.vmDidUpdate()
        }
    }

    private func buildFilterCategoryItemsWithCategories(_ categories: [ListingCategory]) -> [FilterCategoryItem] {

        var filterCatItems: [FilterCategoryItem] = [.category(category: .cars)]
        if featureFlags.freePostingModeAllowed && !featureFlags.taxonomiesAndTaxonomyChildrenInFeed.isActive {
            filterCatItems.append(.free)
        }
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
        case .category(let cat):
            removeFiltersRelatedIfNeeded(category: cat)
            productFilter.toggleCategory(cat)
        }
        sections = generateSections()
        delegate?.vmDidUpdate()
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
    
    func categoryIconColorAtIndex(_ index: Int) -> UIColor {
        guard isValidCategory(index) else { return UIColor.blackText }
        let category = categories[index]
        switch category {
        case .free:
            return productFilter.priceRange.free ? UIColor.redText : UIColor.gray
        case .category(let cat):
            return productFilter.hasSelectedCategory(cat) ? UIColor.redText : UIColor.gray
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
        delegate?.vmDidUpdate()
    }
    
    func withinTimeNameAtIndex(_ index: Int) -> String? {
        guard index < numOfWithinTimes else { return nil }
        
        return withinTimes[index].name
    }
    
    func withinTimeSelectedAtIndex(_ index: Int) -> Bool {
        guard index < numOfWithinTimes else { return false }
        
        return withinTimes[index] == productFilter.selectedWithin
    }
    
    
    // MARK: Real Estate offer type
    
    func selectOfferTypeAtIndex(_ index: Int) {
        guard index < offerTypeOptionsCount else { return }
        if isOfferTypeSelectedAtIndex(index), let offerTypeIndexSelected =  productFilter.realEstateOfferTypes.index(of: offerTypeOptions[index]) {
            productFilter.realEstateOfferTypes.remove(at: offerTypeIndexSelected)
        } else {
            productFilter.realEstateOfferTypes.append(offerTypeOptions[index])
        }
        delegate?.vmDidUpdate()
    }
    
    func offerTypeNameAtIndex(_ index: Int) -> String? {
        guard index < offerTypeOptionsCount else { return nil }
        return offerTypeOptions[index].localizedString
    }
    
    func isOfferTypeSelectedAtIndex(_ index: Int) -> Bool {
        guard index < offerTypeOptionsCount else { return false }
        return productFilter.realEstateOfferTypes.index(of: offerTypeOptions[index]) != nil
    }
    
    // MARK: Car seller type
    
    func selectCarSeller(section: FilterCarSection) {

        if section.isCarSellerTypeSection {
            let carSectionsSelected = productFilter.carSellerTypes.carSectionsFrom(feature: featureFlags.filterSearchCarSellerType, filter: section)
            productFilter.carSellerTypes = carSectionsSelected
        }
        updateCarSelectedSections()
        delegate?.vmDidUpdate()
    }
    
    func isCarSellerTypeSelected(type: FilterCarSection) -> Bool {
        return filterCarSellerSelectedSections.contains(type)
    }
    
    func carCellTitle(section: FilterCarSection) -> String? {
        return section.title(feature: featureFlags.filterSearchCarSellerType)
    }
    
    // MARK: Sort by
    
    func selectSortOptionAtIndex(_ index: Int) {
        guard index < numOfSortOptions else { return }

        let selected = sortOptions[index]
        if productFilter.selectedOrdering == selected {
            productFilter.selectedOrdering = nil
        } else {
            productFilter.selectedOrdering = selected
        }
        delegate?.vmDidUpdate()
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

    var numberOfPriceRows: Int {
        return priceRangeAvailable ? 2 : 1
    }
    
    var numberOfRealEstateRows: Int {
        return postingFlowType == .standard ? 5 : 6
    }
    
    func setMinPrice(_ value: String?) {
        guard let value = value, !productFilter.priceRange.free else { return }
        productFilter.priceRange = .priceRange(min: Int(value), max: maxPrice)
    }

    func setMaxPrice(_ value: String?) {
        guard let value = value, !productFilter.priceRange.free else { return }
        productFilter.priceRange = .priceRange(min: minPrice, max: Int(value))
    }
    
    func setMinSize(_ value: String?) {
        guard let value = value else { return }
        productFilter.realEstateSizeRange = SizeRange(min: Int(value), max: maxSize)
    }
    
    func setMaxSize(_ value: String?) {
        guard let value = value else { return }
        productFilter.realEstateSizeRange = SizeRange(min: minSize, max: Int(value))
    }

    private var validatePriceRange: Bool {
        // if one is empty, is OK
        guard let minPrice = minPrice, let maxPrice = maxPrice else { return true }
        return minPrice < maxPrice
    }
    
    private var validateSizeRange: Bool {
        guard let minSize = minSize, let maxSize = maxSize else { return true }
        return minSize < maxSize
    }

    private func isValidCategory(_ index: Int) -> Bool {
        // index is in range and avoid the extra blank cell in case num categories is odd
        return index < numOfCategories && !(isOddNumCategories && index == numOfCategories-1)
    }
    
    private func removeFiltersRelatedIfNeeded(category: ListingCategory) {
        switch category {
        case .realEstate:
            productFilter = productFilter.resetingCarAttributes()
        case .cars:
            productFilter = productFilter.resetingRealEstateAttributes()
        case .babyAndChild, .electronics, .fashionAndAccesories, .homeAndGarden,
             .motorsAndAccessories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames, .unassigned, .services:
            productFilter = productFilter.resetingCarAttributes()
            productFilter = productFilter.resetingRealEstateAttributes()
        }
    }
}


// MARK: - EditUserLocationDelegate

extension FiltersViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {
        if productFilter.place?.postalAddress?.countryCode != place.postalAddress?.countryCode {
            productFilter = productFilter.resetingRealEstateAttributes()
        }
        productFilter.place = place
        productFilter.distanceRadius = distanceRadius
        delegate?.vmDidUpdate()
    }
}

extension FiltersViewModel: CarAttributeSelectionDelegate {
    func didSelectMake(makeId: String, makeName: String) {
        productFilter.carMakeId = RetrieveListingParam<String>(value: makeId, isNegated: false)
        productFilter.carMakeName = makeName
        productFilter.carModelId = nil
        productFilter.carModelName = nil
        delegate?.vmDidUpdate()
    }

    func didSelectModel(modelId: String, modelName: String) {
        productFilter.carModelId = RetrieveListingParam<String>(value: modelId, isNegated: false)
        productFilter.carModelName = modelName
        delegate?.vmDidUpdate()
    }

    func didSelectYear(year: Int) { }
}


// MARK: TaxonomiesDelegate

extension FiltersViewModel: TaxonomiesDelegate {
    func didSelect(taxonomy: Taxonomy) {
        productFilter.selectedTaxonomy = taxonomy
        productFilter.selectedTaxonomyChildren = []
        sections = generateSections()
        delegate?.vmDidUpdate()
    }
    
    func didSelect(taxonomyChild: TaxonomyChild) {
        productFilter.selectedTaxonomyChildren = [taxonomyChild]
        sections = generateSections()
        delegate?.vmDidUpdate()
    }
}


extension FiltersViewModel {
    var trackCarSellerType: String? {
        guard featureFlags.filterSearchCarSellerType.isActive else { return nil }
        return productFilter.carSellerTypes.trackValue
    }
}


// MARK: FilterFreeCellDelegate

extension FiltersViewModel: FilterFreeCellDelegate {
    func freeSwitchChanged(isOn: Bool) {
        productFilter.priceRange = isOn ? .freePrice : .priceRange(min: nil, max: nil)
        delegate?.vmDidUpdate()
    }
}
