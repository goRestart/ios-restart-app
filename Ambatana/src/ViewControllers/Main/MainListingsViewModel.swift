//
//  MainListingsViewModel.swift
//  letgo
//
//  Created by AHL on 3/5/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import CoreLocation
import LGCoreKit
import Result
import RxSwift
import GoogleMobileAds
import MoPub

protocol MainListingsViewModelDelegate: BaseViewModelDelegate {
    func vmDidSearch()
    func vmShowTags(primaryTags: [FilterTag], secondaryTags: [FilterTag])
    func vmFiltersChanged()
}

protocol MainListingsAdsDelegate: class {
    func rootViewControllerForAds() -> UIViewController
}

struct MainListingsHeader: OptionSet {
    let rawValue : Int
    init(rawValue:Int){ self.rawValue = rawValue}

    static let PushPermissions  = MainListingsHeader(rawValue:1)
    static let SellButton = MainListingsHeader(rawValue:2)
    static let CategoriesCollectionBanner = MainListingsHeader(rawValue:4)
    static let RealEstateBanner = MainListingsHeader(rawValue:8)
}

struct SuggestiveSearchInfo {
    let suggestiveSearches: [SuggestiveSearch]
    let sourceText: String
    
    var count: Int {
        return suggestiveSearches.count
    }
    
    static func empty() -> SuggestiveSearchInfo {
        return SuggestiveSearchInfo(suggestiveSearches: [],
                                    sourceText: "")
    }
}

final class MainListingsViewModel: BaseViewModel {
    
    static let adInFeedInitialPosition = 3
    static let adsInFeedRatio = 20
    
    // > Input
    var searchString: String? {
        return searchType?.text
    }
    var clearTextOnSearch: Bool {
        guard let searchType = searchType else { return false }
        switch searchType {
        case .collection:
            return true
        case .user, .trending, .suggestive, .lastSearch:
            return false
        }
    }
    var interestingListingIDs: Set<String> = Set<String>() {
        didSet {
            let empty = [String: InterestedState]()
            let dict: [String: InterestedState] = interestingListingIDs.reduce(empty) {
                (dict, identifier) -> [String: InterestedState] in
                var dict = dict
                dict[identifier] = .seeConversation
                return dict
            }
            listViewModel.listingInterestState = dict
        }
    }
    private let interestingUndoTimeout: TimeInterval = 5
    private let chatWrapper: ChatWrapper

    let mostSearchedItemsCellPosition: Int = 6
    let bannerCellPosition: Int = 8
    let suggestedSearchesLimit: Int = 10
    var filters: ListingFilters
    var queryString: String?
    

    var hasFilters: Bool {
        return !filters.isDefault()
    }

    var isTaxonomiesAndTaxonomyChildrenInFeedEnabled: Bool {
        return featureFlags.taxonomiesAndTaxonomyChildrenInFeed.isActive
    }
    var isMostSearchedItemsEnabled: Bool {
        return featureFlags.mostSearchedDemandedItems.isActive
    }
    
    var defaultBubbleText: String {
        let distance = filters.distanceRadius ?? 0
        let type = filters.distanceType
        return bubbleTextGenerator.bubbleInfoText(forDistance: distance, type: type, distanceRadius: filters.distanceRadius, place: filters.place)
    }
    
    var taxonomies: [Taxonomy] = []
    var taxonomyChildren: [TaxonomyChild] = []

    let infoBubbleVisible = Variable<Bool>(false)
    let infoBubbleText = Variable<String>(LGLocalizedString.productPopularNearYou)
    let errorMessage = Variable<String?>(nil)
    
    private static let firstVersionNumber = 1

    var primaryTags: [FilterTag] {
        
        var resultTags : [FilterTag] = []
        for prodCat in filters.selectedCategories {
            resultTags.append(.category(prodCat))
        }
        
        if isTaxonomiesAndTaxonomyChildrenInFeedEnabled, let taxonomy = filters.selectedTaxonomy {
            resultTags.append(.taxonomy(taxonomy))
        }
        if let taxonomyChild = filters.selectedTaxonomyChildren.last {
            resultTags.append(.taxonomyChild(taxonomyChild))
        }

        if filters.selectedWithin != ListingTimeCriteria.defaultOption {
            resultTags.append(.within(filters.selectedWithin))
        }
        if let selectedOrdering = filters.selectedOrdering, selectedOrdering != ListingSortCriteria.defaultOption {
            resultTags.append(.orderBy(selectedOrdering))
        }

        switch filters.priceRange {
        case .freePrice:
            resultTags.append(.freeStuff)
        case let .priceRange(min, max):
            if min != nil || max != nil {
                var currency: Currency? = nil
                if let countryCode = locationManager.currentLocation?.countryCode {
                    currency = currencyHelper.currencyWithCountryCode(countryCode)
                }
                resultTags.append(.priceRange(from: filters.priceRange.min, to: filters.priceRange.max, currency: currency))
            }
        }

        if filters.selectedCategories.contains(.cars) || filters.selectedTaxonomyChildren.containsCarsTaxonomy {
            if let makeId = filters.carMakeId, let makeName = filters.carMakeName {
                resultTags.append(.make(id: makeId.value, name: makeName.localizedUppercase))
                if let modelId = filters.carModelId, let modelName = filters.carModelName {
                    resultTags.append(.model(id: modelId.value, name: modelName.localizedUppercase))
                }
            }
            if filters.carYearStart != nil || filters.carYearEnd != nil {
                resultTags.append(.yearsRange(from: filters.carYearStart?.value, to: filters.carYearEnd?.value))
            }

            if featureFlags.filterSearchCarSellerType.isActive {
                let carSellerFilterMultiSelection = featureFlags.filterSearchCarSellerType.isMultiselection
                let containsBothFilters = filters.carSellerTypes.containsBothCarSellerTypes
                let carSellerTypeTags: [FilterTag] = filters.carSellerTypes
                    .filter { carSellerFilterMultiSelection || ($0.isProfessional && !containsBothFilters) }
                    .map { .carSellerType(type: $0, name: $0.title(feature: featureFlags.filterSearchCarSellerType)) }
                
                resultTags.append(contentsOf: carSellerTypeTags)
            }
        }
        
        if filters.selectedCategories.contains(.realEstate) {
            if let propertyType = filters.realEstatePropertyType {
                resultTags.append(.realEstatePropertyType(propertyType))
            }
            
            filters.realEstateOfferTypes.forEach { resultTags.append(.realEstateOfferType($0)) }
        
            if let numberOfBedrooms = filters.realEstateNumberOfBedrooms {
                resultTags.append(.realEstateNumberOfBedrooms(numberOfBedrooms))
            }
            if let numberOfBathrooms = filters.realEstateNumberOfBathrooms {
                resultTags.append(.realEstateNumberOfBathrooms(numberOfBathrooms))
            }
            if let numberOfRooms = filters.realEstateNumberOfRooms {
                resultTags.append(.realEstateNumberOfRooms(numberOfRooms))
            }
            if filters.realEstateSizeRange.min != nil || filters.realEstateSizeRange.max != nil {
                resultTags.append(.sizeSquareMetersRange(from: filters.realEstateSizeRange.min, to: filters.realEstateSizeRange.max))
            }
        }

        return resultTags
    }
    
    var secondaryTags: [FilterTag] {
        var resultTags: [FilterTag] = []
        
        if let taxonomyChildren = filters.selectedTaxonomy?.children, filters.selectedTaxonomyChildren.count <= 0 {
            for secondaryTaxonomyChild in taxonomyChildren {
                resultTags.append(.secondaryTaxonomyChild(secondaryTaxonomyChild))
            }
        }
        
        return resultTags
    }

    var shouldShowInviteButton: Bool {
        return navigator?.canOpenAppInvite() ?? false
    }
    
    private var carSelectedWithFilters: Bool {
        guard filters.selectedCategories.contains(.cars) || filters.selectedTaxonomyChildren.containsCarsTaxonomy else { return false }
        return filters.hasAnyCarAttributes
    }
    
    private var realEstateSelectedWithFilters: Bool {
        guard filters.selectedCategories.contains(.realEstate) else { return false }
        return filters.hasAnyRealEstateAttributes
    }
    
    fileprivate var shouldShowNoExactMatchesDisclaimer: Bool {
        guard realEstateSelectedWithFilters || carSelectedWithFilters else { return false }
        return true
    }

    private var shouldShowCollections: Bool {
        return keyValueStorage[.lastSuggestiveSearches].count >= minimumSearchesSavedToShowCollection && filters.noFilterCategoryApplied
    }
    
    let mainListingsHeader = Variable<MainListingsHeader>([])
    let filterTitle = Variable<String?>(nil)
    let filterDescription = Variable<String?>(nil)

    // Manager & repositories
    fileprivate let sessionManager: SessionManager
    fileprivate let myUserRepository: MyUserRepository
    fileprivate let searchRepository: SearchRepository
    fileprivate let listingRepository: ListingRepository
    fileprivate let monetizationRepository: MonetizationRepository
    fileprivate let locationManager: LocationManager
    fileprivate let currencyHelper: CurrencyHelper
    fileprivate let bubbleTextGenerator: DistanceBubbleTextGenerator
    fileprivate let categoryRepository: CategoryRepository

    fileprivate let tracker: Tracker
    fileprivate let searchType: SearchType? // The initial search
    fileprivate var collections: [CollectionCellType] {
        guard shouldShowCollections else { return [] }
        return [.selectedForYou]
    }
    fileprivate let keyValueStorage: KeyValueStorage
    fileprivate let featureFlags: FeatureFlaggeable
    
    // > Delegate
    weak var delegate: MainListingsViewModelDelegate?
    weak var adsDelegate: MainListingsAdsDelegate?

    // > Navigator
    weak var navigator: MainTabNavigator?
    
    // List VM
    let listViewModel: ListingListViewModel
    fileprivate var listingListRequester: ListingListMultiRequester
    var currentActiveFilters: ListingFilters? {
        return filters
    }
    var userActiveFilters: ListingFilters? {
        return filters
    }
    fileprivate var shouldRetryLoad = false
    fileprivate var lastReceivedLocation: LGLocation?
    fileprivate var bubbleDistance: Float = 1
    fileprivate var lastAdPosition: Int = 0
    fileprivate var previousPagesAdsOffset: Int = 0

    // Search tracking state
    fileprivate var shouldTrackSearch = false

    // Suggestion searches
    let minimumSearchesSavedToShowCollection = 3
    let lastSearchesSavedMaximum = 10
    let lastSearchesShowMaximum = 3
    let trendingSearches = Variable<[String]>([])
    let suggestiveSearchInfo = Variable<SuggestiveSearchInfo>(SuggestiveSearchInfo.empty())
    let lastSearches = Variable<[LocalSuggestiveSearch]>([])
    let searchText = Variable<String?>(nil)
    
    func numberOfItems(type: SearchSuggestionType) -> Int {
        switch type {
        case .suggestive:
            return suggestiveSearchInfo.value.count
        case .lastSearch:
            return lastSearches.value.count
        case .trending:
            return trendingSearches.value.count
        }
    }
    
    // App share
    fileprivate var myUserId: String? {
        return myUserRepository.myUser?.objectId
    }
    fileprivate var myUserName: String? {
        return myUserRepository.myUser?.name
    }
    
    private var isRealEstateSearch: Bool {
        return filters.selectedCategories == [.realEstate]
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    
    // MARK: - Lifecycle
    
    init(sessionManager: SessionManager, myUserRepository: MyUserRepository, searchRepository: SearchRepository,
         listingRepository: ListingRepository, monetizationRepository: MonetizationRepository, categoryRepository: CategoryRepository,
         locationManager: LocationManager, currencyHelper: CurrencyHelper, tracker: Tracker,
         searchType: SearchType? = nil, filters: ListingFilters, keyValueStorage: KeyValueStorage,
         featureFlags: FeatureFlaggeable, bubbleTextGenerator: DistanceBubbleTextGenerator, chatWrapper: ChatWrapper) {
        
        self.sessionManager = sessionManager
        self.myUserRepository = myUserRepository
        self.searchRepository = searchRepository
        self.listingRepository = listingRepository
        self.monetizationRepository = monetizationRepository
        self.categoryRepository = categoryRepository
        self.locationManager = locationManager
        self.currencyHelper = currencyHelper
        self.tracker = tracker
        self.searchType = searchType
        self.filters = filters
        self.queryString = searchType?.query
        self.keyValueStorage = keyValueStorage
        self.featureFlags = featureFlags
        self.bubbleTextGenerator = bubbleTextGenerator
        self.chatWrapper = chatWrapper
        let show3Columns = DeviceFamily.current.isWiderOrEqualThan(.iPhone6Plus)
        let columns = show3Columns ? 3 : 2
        let itemsPerPage = show3Columns ? Constants.numListingsPerPageBig : Constants.numListingsPerPageDefault
        self.listingListRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                        queryString: searchType?.query,
                                                                                        itemsPerPage: itemsPerPage,
                                                                                        carSearchActive: featureFlags.searchCarsIntoNewBackend.isActive)
        self.listViewModel = ListingListViewModel(requester: self.listingListRequester, listings: nil,
                                                  numberOfColumns: columns, tracker: tracker)
        self.listViewModel.listingListFixedInset = show3Columns ? 6 : 10

        if let search = searchType, let query = search.query, !search.isCollection && !query.isEmpty {
            self.shouldTrackSearch = true
        }
        
        super.init()

        self.listViewModel.listingCellDelegate = self
        
        setup()
    }
    
    convenience init(searchType: SearchType? = nil, filters: ListingFilters) {
        let sessionManager = Core.sessionManager
        let myUserRepository = Core.myUserRepository
        let searchRepository = Core.searchRepository
        let listingRepository = Core.listingRepository
        let monetizationRepository = Core.monetizationRepository
        let categoryRepository = Core.categoryRepository
        let locationManager = Core.locationManager
        let currencyHelper = Core.currencyHelper
        let tracker = TrackerProxy.sharedInstance
        let keyValueStorage = KeyValueStorage.sharedInstance
        let featureFlags = FeatureFlags.sharedInstance
        let bubbleTextGenerator = DistanceBubbleTextGenerator()
        self.init(sessionManager: sessionManager,
                  myUserRepository: myUserRepository,
                  searchRepository: searchRepository,
                  listingRepository: listingRepository,
                  monetizationRepository: monetizationRepository,
                  categoryRepository: categoryRepository,
                  locationManager: locationManager,
                  currencyHelper: currencyHelper,
                  tracker: tracker,
                  searchType: searchType,
                  filters: filters,
                  keyValueStorage: keyValueStorage,
                  featureFlags: featureFlags,
                  bubbleTextGenerator: bubbleTextGenerator,
                  chatWrapper: LGChatWrapper())
    }
    
    convenience init(searchType: SearchType? = nil, tabNavigator: TabNavigator?) {
        let filters = ListingFilters()
        self.init(searchType: searchType, filters: filters)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didBecomeActive(_ firstTime: Bool) {
        super.didBecomeActive(firstTime)
        interestingListingIDs = keyValueStorage.interestingListingIDs
        updatePermissionsWarning()
        taxonomyChildren = filterSuperKeywordsHighlighted(taxonomies: getTaxonomyChildren())
        updateCategoriesHeader()
        updateRealEstateBanner()
        if isTaxonomiesAndTaxonomyChildrenInFeedEnabled {
            taxonomies = getTaxonomies()
        }
        if firstTime {
            setupRx()
        }
        if let currentLocation = locationManager.currentLocation {
            retrieveProductsIfNeededWithNewLocation(currentLocation)
            retrieveLastUserSearch()
            retrieveTrendingSearches()
        }
    }

    
    // MARK: - Public methods
    
    /**
        Search action.
    */
    func search(_ query: String) {
        guard !query.isEmpty else { return }
    
        delegate?.vmDidSearch()
        navigator?.openMainListings(withSearchType: .user(query: query), listingFilters: filters)
    }

    func showFilters() {
        navigator?.openFilters(withListingFilters: filters, filtersVMDataDelegate: self)
        tracker.trackEvent(TrackerEvent.filterStart())
    }

    /**
        Called when search button is pressed.
    */
    func searchBegan() {
        tracker.trackEvent(TrackerEvent.searchStart(myUserRepository.myUser))
    }
    
    /**
        Called when a filter gets removed
    */
    func updateFiltersFromTags(_ tags: [FilterTag], removedTag: FilterTag?) {
        var categories: [FilterCategoryItem] = []
        var taxonomyChild: TaxonomyChild? = nil
        var taxonomy: Taxonomy? = nil
        var secondaryTaxonomyChild: TaxonomyChild? = nil
        var orderBy = ListingSortCriteria.defaultOption
        var within = ListingTimeCriteria.defaultOption
        var minPrice: Int? = nil
        var maxPrice: Int? = nil
        var free: Bool = false
        var carSellerTypes: [CarSellerType] = []
        var makeId: String? = nil
        var makeName: String? = nil
        var modelId: String? = nil
        var modelName: String? = nil
        var carYearStart: Int? = nil
        var carYearEnd: Int? = nil
        var realEstatePropertyType: RealEstatePropertyType? = nil
        var realEstateOfferTypes: [RealEstateOfferType] = []
        var realEstateNumberOfBedrooms: NumberOfBedrooms? = nil
        var realEstateNumberOfBathrooms: NumberOfBathrooms? = nil
        var realEstateNumberOfRooms: NumberOfRooms? = nil
        var realEstateSizeSquareMetersMin: Int? = nil
        var realEstateSizeSquareMetersMax: Int? = nil

        for filterTag in tags {
            switch filterTag {
            case .location:
                break
            case .category(let prodCategory):
                categories.append(FilterCategoryItem(category: prodCategory))
            case .taxonomyChild(let taxonomyChildSelected):
                taxonomyChild = taxonomyChildSelected
            case .taxonomy(let taxonomySelected):
                taxonomy = taxonomySelected
            case .secondaryTaxonomyChild(let secondaryTaxonomySelected):
                secondaryTaxonomyChild = secondaryTaxonomySelected
            case .orderBy(let prodSortOption):
                orderBy = prodSortOption
            case .within(let prodTimeOption):
                within = prodTimeOption
            case .priceRange(let minPriceOption, let maxPriceOption, _):
                minPrice = minPriceOption
                maxPrice = maxPriceOption
            case .freeStuff:
                free = true
            case .distance:
                break
            case .carSellerType(let type, _):
                carSellerTypes.append(type)
            case .make(let id, let name):
                makeId = id
                makeName = name
            case .model(let id, let name):
                modelId = id
                modelName = name
            case .yearsRange(let startYear, let endYear):
                carYearStart = startYear
                carYearEnd = endYear
            case .realEstatePropertyType(let propertyType):
                realEstatePropertyType = propertyType
            case .realEstateOfferType(let offerType):
                realEstateOfferTypes.append(offerType)
            case .realEstateNumberOfBedrooms(let numberOfBedrooms):
                realEstateNumberOfBedrooms = numberOfBedrooms
            case .realEstateNumberOfBathrooms(let numberOfBathrooms):
                realEstateNumberOfBathrooms = numberOfBathrooms
            case .realEstateNumberOfRooms(let numberOfRooms):
                realEstateNumberOfRooms = numberOfRooms
            case .sizeSquareMetersRange(let minSize, let maxSize):
                realEstateSizeSquareMetersMin = minSize
                realEstateSizeSquareMetersMax = maxSize
            }
        }

        filters.selectedCategories = categories.flatMap{ filterCategoryItem in
            switch filterCategoryItem {
            case .free:
                return nil
            case .category(let cat):
                return cat
            }
        }
        
        if let taxonomyValue = taxonomy {
            filters.selectedTaxonomy = taxonomyValue
        } else {
            filters.selectedTaxonomy = nil
        }
        
        if let secondaryTaxonomyChildValue = secondaryTaxonomyChild,
            filters.selectedTaxonomy != nil {
            filters.selectedTaxonomyChildren = [secondaryTaxonomyChildValue]
        } else if let taxonomyChildValue = taxonomyChild,
            filters.selectedTaxonomy != nil {
            filters.selectedTaxonomyChildren = [taxonomyChildValue]
        } else {
            filters.selectedTaxonomyChildren = []
        }
        
        if let removedTag = removedTag, removedTag.isTaxonomy {
            filters.selectedTaxonomyChildren = []
        }
    
        filters.selectedOrdering = orderBy
        filters.selectedWithin = within
        if free {
            filters.priceRange = .freePrice
        } else {
            filters.priceRange = .priceRange(min: minPrice, max: maxPrice)
        }

        filters.carSellerTypes = carSellerTypes
        
        if let makeId = makeId {
            filters.carMakeId = RetrieveListingParam<String>(value: makeId, isNegated: false)
        } else {
            filters.carMakeId = nil
        }
        filters.carMakeName = makeName

        if let modelId = modelId {
            filters.carModelId = RetrieveListingParam<String>(value: modelId, isNegated: false)
        } else {
            filters.carModelId = nil
        }
        filters.carModelName = modelName

        if let startYear = carYearStart {
            filters.carYearStart = RetrieveListingParam<Int>(value: startYear, isNegated: false)
        } else {
            filters.carYearStart = nil
        }

        if let endYear = carYearEnd {
            filters.carYearEnd = RetrieveListingParam<Int>(value: endYear, isNegated: false)
        } else {
            filters.carYearEnd = nil
        }
        
        filters.realEstatePropertyType = realEstatePropertyType
        filters.realEstateOfferTypes = realEstateOfferTypes
        filters.realEstateNumberOfBedrooms = realEstateNumberOfBedrooms
        filters.realEstateNumberOfBathrooms = realEstateNumberOfBathrooms
        
        filters.realEstateNumberOfRooms = realEstateNumberOfRooms
        filters.realEstateSizeRange = SizeRange(min: realEstateSizeSquareMetersMin, max: realEstateSizeSquareMetersMax)
        
        updateCategoriesHeader()
        updateRealEstateBanner()
        updateListView()
    }
    
    func applyFilters(_ categoryHeaderInfo: CategoryHeaderInfo) {
        tracker.trackEvent(TrackerEvent.filterCategoryHeaderSelected(position: categoryHeaderInfo.position,
                                                                     name: categoryHeaderInfo.name))
        delegate?.vmShowTags(primaryTags: primaryTags, secondaryTags: secondaryTags)
        updateCategoriesHeader()
        updateRealEstateBanner()
        updateListView()
    }
    
    func updateFiltersFromHeaderCategories(_ categoryHeaderInfo: CategoryHeaderInfo) {
        switch categoryHeaderInfo.categoryHeaderElement {
        case .listingCategory(let listingCategory):
            filters.selectedCategories = [listingCategory]
        case .superKeyword(let taxonomyChild):
            filters.selectedTaxonomyChildren = [taxonomyChild]
        case .superKeywordGroup(let taxonomy):
            filters.selectedTaxonomy = taxonomy
        case .showMore:
            tracker.trackEvent(TrackerEvent.filterCategoryHeaderSelected(position: categoryHeaderInfo.position,
                                                                         name: categoryHeaderInfo.name))
            return // do not update any filters
        case .mostSearchedItems:
            return
        }
        applyFilters(categoryHeaderInfo)
    }

    func bubbleTapped() {
        let initialPlace = filters.place ?? Place(postalAddress: locationManager.currentLocation?.postalAddress,
                                                  location: locationManager.currentLocation?.location)
        navigator?.openLocationSelection(initialPlace: initialPlace, 
                                         distanceRadius: filters.distanceRadius,
                                         locationDelegate: self)
    }

    func updateSelectedTaxonomyChildren(taxonomyChildren: [TaxonomyChild]) {
        filters.selectedTaxonomyChildren = taxonomyChildren
        updateCategoriesHeader()
        updateRealEstateBanner()
        updateListView()
    }
    
    func showRealEstateTutorial() {
        guard !keyValueStorage[.realEstateTutorialShown] && featureFlags.realEstateTutorial.isActive else { return }
        guard let pages = LGTutorialPage.makeRealEstateTutorial(typeOfOnboarding: featureFlags.realEstateTutorial) else {
            return
        }
        keyValueStorage[.realEstateTutorialShown] = true
        navigator?.openRealEstateOnboarding(pages: pages, origin: .filterBubble, tutorialType: .realEstate)
    }
    
    
    // MARK: - Private methods

    private func setup() {
        setupProductList()
        setupSessionAndLocation()
        setupPermissionsNotification()
        infoBubbleText.value = defaultBubbleText
    }
   
    private func setupRx() {
        listViewModel.isListingListEmpty.asObservable().bind { [weak self] _ in
            self?.updateCategoriesHeader()
            self?.updateRealEstateBanner()
        }.disposed(by: disposeBag) 
    }
    
    /**
        Returns a view model for search.
    
        - returns: A view model for search.
    */
    private func viewModelForSearch(_ searchType: SearchType) -> MainListingsViewModel {
        return MainListingsViewModel(searchType: searchType, filters: filters)
    }
    
    fileprivate func updateListView() {
        
        if filters.selectedOrdering == ListingSortCriteria.defaultOption {
            infoBubbleText.value = defaultBubbleText
        }

        let currentItemsPerPage = listingListRequester.itemsPerPage

        listingListRequester = FilterListingListRequesterFactory.generateRequester(withFilters: filters,
                                                                                   queryString: queryString,
                                                                                   itemsPerPage: currentItemsPerPage,
                                                                                   carSearchActive: featureFlags.searchCarsIntoNewBackend.isActive)

        listViewModel.listingListRequester = listingListRequester

        infoBubbleVisible.value = false
        errorMessage.value = nil
        listViewModel.resetUI()
        listViewModel.refresh()
    }

    // MARK: - Taxonomies
    
    fileprivate func getTaxonomies() -> [Taxonomy] {
        return categoryRepository.indexTaxonomies()
    }
    
    private func getTaxonomyChildren() -> [TaxonomyChild] {
        return getTaxonomies().flatMap { $0.children }
    }
    
    private func filterSuperKeywordsHighlighted(taxonomies: [TaxonomyChild]) ->  [TaxonomyChild] {
        let highlightedTaxonomies: [TaxonomyChild] = taxonomies.filter { $0.highlightOrder != nil }
        let sortedArray = highlightedTaxonomies.sorted(by: {
            guard let firstValue = $0.highlightOrder, let secondValue = $1.highlightOrder else { return false }
            return firstValue < secondValue
        })
        return sortedArray
    }
    
    var categoryHeaderElements: [CategoryHeaderElement] {
        var categoryHeaderElements: [CategoryHeaderElement] = []
        if isTaxonomiesAndTaxonomyChildrenInFeedEnabled {
            categoryHeaderElements.append(contentsOf: taxonomies.map { CategoryHeaderElement.superKeywordGroup($0) })
        } else {
            categoryHeaderElements.append(contentsOf: ListingCategory.visibleValuesInFeed(servicesIncluded: featureFlags.servicesCategoryEnabled.isActive,
                                                                                          realEstateIncluded: featureFlags.realEstateEnabled.isActive)
                .map { CategoryHeaderElement.listingCategory($0) })
        }
        return categoryHeaderElements
    }
    
    var categoryHeaderHighlighted: CategoryHeaderElement {
        if featureFlags.realEstateEnabled.isActive {
            return CategoryHeaderElement.listingCategory(.realEstate)
        } else {
            return CategoryHeaderElement.listingCategory(.cars)
        }
    }
}


// MARK: - FiltersViewModelDataDelegate

extension MainListingsViewModel: FiltersViewModelDataDelegate {

    func viewModelDidUpdateFilters(_ viewModel: FiltersViewModel, filters: ListingFilters) {
        self.filters = filters
        delegate?.vmShowTags(primaryTags: primaryTags, secondaryTags: secondaryTags)
        updateListView()
    }
}


// MARK: - ListingListView

extension MainListingsViewModel: ListingListViewModelDataDelegate, ListingListViewCellsDelegate {

    func setupProductList() {
        listViewModel.dataDelegate = self

        listingRepository.events.bind { [weak self] event in
            switch event {
            case let .update(listing):
                self?.listViewModel.update(listing: listing)
            case let .create(listing):
                self?.listViewModel.prepend(listing: listing)
            case let .delete(listingId):
                self?.listViewModel.delete(listingId: listingId)
            case .favorite, .unFavorite, .sold, .unSold:
                break
            }
        }.disposed(by: disposeBag)
        
        monetizationRepository.events.bind { [weak self] event in
            switch event {
            case .freeBump, .pricedBump:
                self?.listViewModel.refresh()
            }
            }.disposed(by: disposeBag)
    }

    // MARK: > ListingListViewCellsDelegate

    func visibleTopCellWithIndex(_ index: Int, whileScrollingDown scrollingDown: Bool) {

        // set title for cell at index if necessary
        filterTitle.value = listViewModel.titleForIndex(index: index)

        guard let sortCriteria = filters.selectedOrdering else { return }

        switch (sortCriteria) {
        case .distance:
            guard let topListing = listViewModel.listingAtIndex(index) else { return }
            guard let requesterDistance = listingListRequester.distanceFromListingCoordinates(topListing.location) else { return }
            let distance = Float(requesterDistance)

            // instance var max distance or MIN distance to avoid updating the label everytime
            if (scrollingDown && distance > bubbleDistance) || (!scrollingDown && distance < bubbleDistance) ||
                listViewModel.refreshing {
                bubbleDistance = distance
            }
            infoBubbleText.value = bubbleTextGenerator.bubbleInfoText(forDistance: max(1,Int(round(bubbleDistance))),
                                                                      type: DistanceType.systemDistanceType(),
                                                                      distanceRadius: filters.distanceRadius,
                                                                      place: filters.place)
        case .creation:
            infoBubbleText.value = defaultBubbleText
        case .priceAsc, .priceDesc:
            break
        }
    }

    // MARK: > ListingListViewModelDataDelegate

    func listingListVM(_ viewModel: ListingListViewModel, didSucceedRetrievingListingsPage page: UInt,
                       withResultsCount resultsCount: Int, hasListings: Bool) {

        trackRequestSuccess(page: page, resultsCount: resultsCount, hasListings: hasListings)
        // Only save the string when there is products and we are not searching a collection
        if let search = searchType, hasListings {
            updateLastSearchStored(lastSearch: search)
        }
        
        if shouldRetryLoad {
            shouldRetryLoad = false
            listViewModel.retrieveListings()
            return
        }

        if listingListRequester.multiIsFirstPage  {
            filterDescription.value = !hasListings && shouldShowNoExactMatchesDisclaimer ? LGLocalizedString.filterResultsCarsNoMatches : nil
        }

        if !hasListings {
            if listingListRequester.multiIsLastPage {
                let errImage: UIImage?
                let errTitle: String?
                let errBody: String?
                
                
                // Search
                if queryString != nil || hasFilters {
                    errImage = UIImage(named: "err_search_no_products")
                    errTitle = isRealEstateSearch ? LGLocalizedString.realEstateEmptyStateSearchTitle : LGLocalizedString.productSearchNoProductsTitle
                    errBody = isRealEstateSearch ? LGLocalizedString.realEstateEmptyStateSearchSubtitle : LGLocalizedString.productSearchNoProductsBody
                } else {
                    // Listing
                    errImage = UIImage(named: "err_list_no_products")
                    errTitle = LGLocalizedString.productListNoProductsTitle
                    errBody = LGLocalizedString.productListNoProductsBody
                }

                let emptyViewModel = LGEmptyViewModel(icon: errImage, title: errTitle, body: errBody, buttonTitle: nil,
                                                      action: nil, secondaryButtonTitle: nil, secondaryAction: nil,
                                                      emptyReason: nil, errorCode: nil)
                listViewModel.setEmptyState(emptyViewModel)
                filterDescription.value = nil
                filterTitle.value = nil
            } else {
                listViewModel.retrieveListingsNextPage()
            }
        }

        errorMessage.value = nil
        infoBubbleVisible.value = hasListings && filters.infoBubblePresent
        if(page == 0) {
            bubbleDistance = 1
        }
    }

    func listingListMV(_ viewModel: ListingListViewModel, didFailRetrievingListingsPage page: UInt,
                              hasListings hasProducts: Bool, error: RepositoryError) {
        if shouldRetryLoad {
            shouldRetryLoad = false
            listViewModel.retrieveListings()
            return
        }

        if page == 0 && !hasProducts {
            if let emptyViewModel = LGEmptyViewModel.map(from: error, action: { [weak viewModel] in viewModel?.refresh() }) {
                listViewModel.setErrorState(emptyViewModel)
            }
        }

        var errorString: String? = nil
        if hasProducts && page > 0 {
            switch error {
            case .network:
                errorString = LGLocalizedString.toastNoNetwork
            case .internalError, .notFound, .forbidden, .tooManyRequests, .userNotVerified, .serverError, .wsChatError:
                errorString = LGLocalizedString.toastErrorInternal
            case .unauthorized:
                errorString = nil
            }
        }
        errorMessage.value = errorString
        infoBubbleVisible.value = hasProducts && filters.infoBubblePresent
    }

    func listingListVM(_ viewModel: ListingListViewModel, didSelectItemAtIndex index: Int,
                       thumbnailImage: UIImage?, originFrame: CGRect?) {
        
        guard let listing = viewModel.listingAtIndex(index) else { return }
        let cellModels = viewModel.objects
        let showRelated = searchType == nil && !hasFilters
        let data = ListingDetailData.listingList(listing: listing, cellModels: cellModels,
                                                 requester: listingListRequester, thumbnailImage: thumbnailImage,
                                                 originFrame: originFrame, showRelated: showRelated, index: index)
        navigator?.openListing(data, source: listingVisitSource, actionOnFirstAppear: .nonexistent)
    }

    func vmProcessReceivedListingPage(_ listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        var totalListings = listings
        totalListings = addMostSearchedItems(to: totalListings)
        totalListings = addCollections(to: totalListings, page: page)
        totalListings = addRealEstatePromoItem(to: totalListings)
        let myUserCreationDate: Date? = myUserRepository.myUser?.creationDate
        if featureFlags.showAdsInFeedWithRatio.isActive ||
            featureFlags.feedAdsProviderForUS.shouldShowAdsInFeedForUser(createdIn: myUserCreationDate) ||
            featureFlags.feedAdsProviderForTR.shouldShowAdsInFeedForUser(createdIn: myUserCreationDate) {
                totalListings = addAds(to: totalListings, page: page)
        }
        return totalListings
    }

    func vmDidSelectCollection(_ type: CollectionCellType){
        tracker.trackEvent(TrackerEvent.exploreCollection(type.rawValue))
        let query = queryForCollection(type)
        delegate?.vmDidSearch()
        navigator?.openMainListings(withSearchType: .collection(type: type, query: query), listingFilters: filters)
    }
    
    func vmDidSelectMostSearchedItems() {
        navigator?.openMostSearchedItems(source: .mostSearchedCard, enableSearch: true)
    }

    func vmUserDidTapInvite() {
        navigator?.openAppInvite(myUserId: myUserId, myUserName: myUserName)
    }
    
    func vmDidSelectSellBanner(_ type: String) {}

    private func addCollections(to listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        guard searchType == nil else { return listings }
        guard listings.count > bannerCellPosition else { return listings }
        var cellModels = listings
        if !collections.isEmpty && featureFlags.collectionsAllowedFor(countryCode: listingListRequester.countryCode) {
            let collectionType = collections[Int(page) % collections.count]
            let collectionModel = ListingCellModel.collectionCell(type: collectionType)
            cellModels.insert(collectionModel, at: bannerCellPosition)
        }
        return cellModels
    }

    private func addAds(to listings: [ListingCellModel], page: UInt) -> [ListingCellModel] {
        if page == 0 {
            lastAdPosition = MainListingsViewModel.adInFeedInitialPosition
            previousPagesAdsOffset = 0
        }
        guard let adsDelegate = adsDelegate else { return listings }
        let adsActive = featureFlags.showAdsInFeedWithRatio.isActive ||
            featureFlags.feedAdsProviderForUS.shouldShowAdsInFeed ||
            featureFlags.feedAdsProviderForTR.shouldShowAdsInFeed
        var cellModels = listings

        var canInsertAds = true

        guard adsActive else { return listings }
        while canInsertAds {

            let adPositionInPage = lastAdPosition-previousPagesAdsOffset
            guard let adRelativePosition = adPositionRelativeToPage(page: page,
                                                                  itemsInPage: cellModels.count,
                                                                  pageSize: listingListRequester.itemsPerPage,
                                                                  adPosition: adPositionInPage) else { break }
            var adsCellModel: ListingCellModel
            
            if featureFlags.feedAdsProviderForUS.shouldShowMoPubAds || featureFlags.feedAdsProviderForTR.shouldShowMoPubAds {
                guard let adUnit = featureFlags.feedMoPubAdUnitId else { return listings }
                let settings = MPStaticNativeAdRendererSettings()
                var configurations = Array<MPNativeAdRendererConfiguration>()
                settings.renderingViewClass = MoPubNativeView.self
                let config = MPStaticNativeAdRenderer.rendererConfiguration(with: settings)
                configurations.append(config!)
                let nativeAdRequest = MPNativeAdRequest.init(adUnitIdentifier: adUnit,
                                                             rendererConfigurations: configurations)
                let adData = AdvertisementMoPubData(adUnitId: adUnit,
                                                    rootViewController: adsDelegate.rootViewControllerForAds(),
                                                    adPosition: lastAdPosition,
                                                    bannerHeight: LGUIKitConstants.advertisementCellMoPubHeight,
                                                    showAdsInFeedWithRatio: featureFlags.showAdsInFeedWithRatio,
                                                    adRequested: false,
                                                    categories: filters.selectedCategories,
                                                    nativeAdRequest: nativeAdRequest,
                                                    moPubNativeAd: nil,
                                                    moPubView: MoPubBlankStateView())
                adsCellModel = ListingCellModel.mopubAdvertisement(data: adData)
                
            } else {
                guard let feedAdUnitId = featureFlags.feedDFPAdUnitId else { return listings }
                let request = DFPRequest()
                var customTargetingValue = ""
                
                if featureFlags.showAdsInFeedWithRatio.isActive {
                    customTargetingValue = featureFlags.showAdsInFeedWithRatio.customTargetingValueFor(position: lastAdPosition)
                } else if featureFlags.noAdsInFeedForNewUsers.shouldShowAdsInFeed {
                    customTargetingValue = featureFlags.noAdsInFeedForNewUsers.customTargetingValueFor(position: lastAdPosition)
                }
                request.customTargeting = [Constants.adInFeedCustomTargetingKey: customTargetingValue]
                
                let adData = AdvertisementDFPData(adUnitId: feedAdUnitId,
                                                  rootViewController: adsDelegate.rootViewControllerForAds(),
                                                  adPosition: lastAdPosition,
                                                  bannerHeight: LGUIKitConstants.advertisementCellPlaceholderHeight,
                                                  showAdsInFeedWithRatio: featureFlags.showAdsInFeedWithRatio,
                                                  adRequested: false,
                                                  categories: filters.selectedCategories,
                                                  adRequest: request,
                                                  bannerView: nil)
                adsCellModel = ListingCellModel.dfpAdvertisement(data: adData)
            }
  
            cellModels.insert(adsCellModel, at: adRelativePosition)

            lastAdPosition = adAbsolutePosition()
            canInsertAds = adRelativePosition < cellModels.count
        }
        previousPagesAdsOffset += (cellModels.count - listings.count + collections.count)
        previousPagesAdsOffset += isMostSearchedItemsEnabled ? 1 : 0
        return cellModels
    }
    
    private func addMostSearchedItems(to listings: [ListingCellModel]) -> [ListingCellModel] {
        guard searchType == nil else { return listings }
        guard listings.count > mostSearchedItemsCellPosition else { return listings }
        var cellModels = listings
        if isMostSearchedItemsEnabled {
            let mostSearchedItemsModel = ListingCellModel.mostSearchedItems(data: MostSearchedItemsCardData())
            cellModels.insert(mostSearchedItemsModel, at: mostSearchedItemsCellPosition)
        }
        return cellModels
    }
    
    private func addRealEstatePromoItem(to listings: [ListingCellModel]) -> [ListingCellModel] {
        guard featureFlags.realEstatePromoCell.isActive, isRealEstateSearch, !listings.isEmpty
            else { return listings }
        
        guard (!filters.hasAnyRealEstateAttributes && listingListRequester.multiIsFirstPage) ||
        (filters.hasAnyRealEstateAttributes && listingListRequester.isFirstPageInLastRequester) else { return listings }
        
        var cellModels = listings
        cellModels.insert(ListingCellModel.promo(data: PromoCellConfiguration.randomCellData,  delegate: self), at: 0)
        return cellModels
    }

    private func adAbsolutePosition() -> Int {
        var adPosition = 0
        if lastAdPosition == 0 {
            adPosition = MainListingsViewModel.adInFeedInitialPosition
        } else {
            adPosition = lastAdPosition + MainListingsViewModel.adsInFeedRatio
        }
        return adPosition
    }

    private func adPositionRelativeToPage(page: UInt, itemsInPage: Int, pageSize: Int, adPosition: Int) -> Int? {
        let pageInt = Int(page)
        let adRelativePosition = adPosition - (pageInt*pageSize)
        if 0..<itemsInPage ~= adRelativePosition {
            return adRelativePosition
        }
        return nil
    }
}


// MARK: - Session & Location handling

extension MainListingsViewModel {
    fileprivate func setupSessionAndLocation() {
        sessionManager.sessionEvents.bind { [weak self] _ in self?.sessionDidChange() }.disposed(by: disposeBag)
        locationManager.locationEvents.filter { $0 == .locationUpdate }.bind { [weak self] _ in
            self?.locationDidChange()
        }.disposed(by: disposeBag)
    }

    fileprivate func sessionDidChange() {
        guard listViewModel.canRetrieveListings else {
            shouldRetryLoad = true
            return
        }
        listViewModel.retrieveListings()
    }

    private func locationDidChange() {
        guard let newLocation = locationManager.currentLocation else { return }

        // Tracking: when a new location is received and has different type than previous one
        if lastReceivedLocation?.type != newLocation.type {
            let trackerEvent = TrackerEvent.location(locationType: newLocation.type,
                                                     locationServiceStatus: locationManager.locationServiceStatus,
                                                     typePage: .automatic,
                                                     zipCodeFilled: nil,
                                                     distanceRadius: filters.distanceRadius)
            tracker.trackEvent(trackerEvent)
        }
        
        
        // Retrieve products (should be place after tracking, as it updates lastReceivedLocation)
        retrieveProductsIfNeededWithNewLocation(newLocation)
        retrieveLastUserSearch()
        retrieveTrendingSearches()
    }

    fileprivate func retrieveProductsIfNeededWithNewLocation(_ newLocation: LGLocation) {

        var shouldUpdate = false
        if listViewModel.canRetrieveListings {
            if listViewModel.numberOfListings == 0 {
                // 👆🏾 If there are no products, then refresh
                shouldUpdate = true
            } else if newLocation.type == .manual || lastReceivedLocation?.type == .manual {
                //👆🏾 If new location is manual OR last location was manual, and location has changed then refresh"
                if let lastReceivedLocation = lastReceivedLocation, newLocation != lastReceivedLocation {
                    shouldUpdate = true
                }
            } else if lastReceivedLocation?.type != .sensor && newLocation.type == .sensor {
                // 👆🏾 If new location is not manual and we improved the location type to sensors
                shouldUpdate = true
            } else if let newCountryCode = newLocation.countryCode, lastReceivedLocation?.countryCode != newCountryCode {
                // in case list loaded with older country code and new location is retrieved with new country code"
                shouldUpdate = true
            }
        } else if listViewModel.numberOfListings == 0 {
            if lastReceivedLocation?.type != .sensor && newLocation.type == .sensor {
                // in case the user allows sensors while loading the product list with the iplookup parameters"
                shouldRetryLoad = true
            } else if let newCountryCode = newLocation.countryCode, lastReceivedLocation?.countryCode != newCountryCode {
                // in case the list is loading with older country code and new location is received with new country code
                shouldRetryLoad = true
            }
        }
        
        if shouldUpdate {
            infoBubbleText.value = defaultBubbleText
            listViewModel.retrieveListings()
        }

        // Track the received location
        lastReceivedLocation = newLocation
    }
}


// MARK: - Suggestions searches

extension MainListingsViewModel {
    
    func selected(type: SearchSuggestionType, row: Int) {
        switch type {
        case .suggestive:
            selectedSuggestiveSearchAtIndex(row)
        case .lastSearch:
            selectedLastSearchAtIndex(row)
        case .trending:
            selectedTrendingSearchAtIndex(row)
        }
    }

    func trendingSearchAtIndex(_ index: Int) -> String? {
        guard  0..<trendingSearches.value.count ~= index else { return nil }
        return trendingSearches.value[index]
    }
    
    func suggestiveSearchAtIndex(_ index: Int) -> (suggestiveSearch: SuggestiveSearch, sourceText: String)? {
        guard  0..<suggestiveSearchInfo.value.count ~= index else { return nil }
        return (suggestiveSearchInfo.value.suggestiveSearches[index], suggestiveSearchInfo.value.sourceText)
    }
    
    func lastSearchAtIndex(_ index: Int) -> SuggestiveSearch? {
        guard 0..<lastSearches.value.count ~= index else { return nil }
        return lastSearches.value[index].suggestiveSearch
    }

    private func selectedTrendingSearchAtIndex(_ index: Int) {
        guard let trendingSearch = trendingSearchAtIndex(index), !trendingSearch.isEmpty else { return }
        delegate?.vmDidSearch()
        navigator?.openMainListings(withSearchType: .trending(query: trendingSearch), listingFilters: filters)
    }
    
    private func selectedSuggestiveSearchAtIndex(_ index: Int) {
        guard let (suggestiveSearch, _) = suggestiveSearchAtIndex(index) else { return }
        delegate?.vmDidSearch()
        
        let newFilters: ListingFilters
        if let category = suggestiveSearch.category {
            newFilters = filters.updating(selectedCategories: [category])
        } else {
            newFilters = filters
        }
        navigator?.openMainListings(withSearchType: .suggestive(search: suggestiveSearch,
                                                                indexSelected: index),
                                    listingFilters: newFilters)
    }
    
    private func selectedLastSearchAtIndex(_ index: Int) {
        guard let lastSearch = lastSearchAtIndex(index), let name = lastSearch.name, !name.isEmpty else { return }
        delegate?.vmDidSearch()
        navigator?.openMainListings(withSearchType: .lastSearch(search: lastSearch),
                                    listingFilters: filters)
    }
    
    func cleanUpLastSearches() {
        keyValueStorage[.lastSuggestiveSearches] = []
        lastSearches.value = keyValueStorage[.lastSuggestiveSearches]
    }
    
    func retrieveLastUserSearch() {
        // We saved up to lastSearchesSavedMaximum(10) but we show only lastSearchesShowMaximum(3)
        var searchesToShow = [LocalSuggestiveSearch]()
        let allSearchesSaved = keyValueStorage[.lastSuggestiveSearches]
        if allSearchesSaved.count > lastSearchesShowMaximum {
            searchesToShow = Array(allSearchesSaved.suffix(lastSearchesShowMaximum))
        } else {
            searchesToShow = keyValueStorage[.lastSuggestiveSearches]
        }
        lastSearches.value = searchesToShow.reversed()
    }

    func retrieveTrendingSearches() {
        guard let currentCountryCode = locationManager.currentLocation?.countryCode else { return }

        searchRepository.index(countryCode: currentCountryCode) { [weak self] result in
            self?.trendingSearches.value = result.value ?? []
        }
    }
    
    func searchTextFieldDidUpdate(text: String) {
        let charactersCount = text.count
        if charactersCount > 0 {
            retrieveSuggestiveSearches(term: text)
        } else {
            cleanUpSuggestiveSearches()
        }
    }
    
    private func retrieveSuggestiveSearches(term: String) {
        guard let languageCode = Locale.current.languageCode else { return }
        
        let shouldIncludeCategories: Bool
        switch featureFlags.searchAutocomplete {
        case .baseline, .control:
            shouldIncludeCategories = false
        case .withCategories:
            shouldIncludeCategories = true
        }
        searchRepository.retrieveSuggestiveSearches(language: languageCode,
                                                    limit: Constants.listingsSearchSuggestionsMaxResults,
                                                    term: term,
                                                    shouldIncludeCategories: shouldIncludeCategories) { [weak self] result in
            // prevent showing results when deleting the search text
            guard let sourceText = self?.searchText.value else { return }
            self?.suggestiveSearchInfo.value = SuggestiveSearchInfo(suggestiveSearches: result.value ?? [],
                                                                    sourceText: sourceText)
        }
    }
    
    private func cleanUpSuggestiveSearches() {
        suggestiveSearchInfo.value = SuggestiveSearchInfo.empty()
    }
    
    fileprivate func updateLastSearchStored(lastSearch: SearchType) {
        guard let suggestiveSearch = getSuggestiveSearchFrom(searchType: lastSearch) else { return }
        // We save up to lastSearchesSavedMaximum items
        var searchesSaved = keyValueStorage[.lastSuggestiveSearches]
        // Check if already the search exists and if so then move the search to front.
        if let index = searchesSaved.index(of: suggestiveSearch) {
            searchesSaved.remove(at: index)
        }
        searchesSaved.append(suggestiveSearch)
        if searchesSaved.count > lastSearchesSavedMaximum {
            searchesSaved.removeFirst()
        }
        keyValueStorage[.lastSuggestiveSearches] = searchesSaved
        retrieveLastUserSearch()
    }
    
    fileprivate func getSuggestiveSearchFrom(searchType: SearchType) -> LocalSuggestiveSearch? {
        let suggestiveSearch: SuggestiveSearch?
        switch searchType {
        case let .user(query):
            suggestiveSearch = SuggestiveSearch.term(name: query)
        case let .trending(query):
            suggestiveSearch = SuggestiveSearch.term(name: query)
        case let .suggestive(search, _):
            suggestiveSearch = search
        case let .lastSearch(search):
            suggestiveSearch = search
        case .collection:
            suggestiveSearch = nil
        }
        if let suggestiveSearch = suggestiveSearch {
            return LocalSuggestiveSearch(suggestiveSearch: suggestiveSearch)
        } else {
            return nil
        }
    }
}

// MARK: Push Permissions

extension MainListingsViewModel {

    var showCategoriesCollectionBanner: Bool {
        return primaryTags.isEmpty && !listViewModel.isListingListEmpty.value
    }
    
    var showRealEstateBanner: Bool {
        return !listViewModel.isListingListEmpty.value && filters.selectedCategories == [.realEstate]
    }

    func pushPermissionsHeaderPressed() {
        openPushPermissionsAlert()
    }

    fileprivate func setupPermissionsNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(updatePermissionsWarning),
                         name: NSNotification.Name(rawValue: PushManager.Notification.DidRegisterUserNotificationSettings.rawValue), object: nil)
    }

    @objc fileprivate dynamic func updatePermissionsWarning() {
        var currentHeader = mainListingsHeader.value
        if UIApplication.shared.areRemoteNotificationsEnabled {
            currentHeader.remove(MainListingsHeader.PushPermissions)
        } else {
            currentHeader.insert(MainListingsHeader.PushPermissions)
        }
        guard mainListingsHeader.value != currentHeader else { return }
        mainListingsHeader.value = currentHeader
    }
    
    @objc fileprivate dynamic func updateRealEstateBanner() {
        if !featureFlags.realEstatePromoCell.isActive {
            var currentHeader = mainListingsHeader.value
            if showRealEstateBanner {
                currentHeader.insert(MainListingsHeader.RealEstateBanner)
            } else {
                currentHeader.remove(MainListingsHeader.RealEstateBanner)
            }
            guard mainListingsHeader.value != currentHeader else { return }
            mainListingsHeader.value = currentHeader
        }
    }
    
    @objc fileprivate dynamic func updateCategoriesHeader() {
        var currentHeader = mainListingsHeader.value
        if showCategoriesCollectionBanner {
            currentHeader.insert(MainListingsHeader.CategoriesCollectionBanner)
        } else {
            currentHeader.remove(MainListingsHeader.CategoriesCollectionBanner)
        }
        guard mainListingsHeader.value != currentHeader else { return }
        mainListingsHeader.value = currentHeader
    }

    private func openPushPermissionsAlert() {
        trackPushPermissionStart()
        let positive = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertOk, .standard),
                                action: { [weak self] in
                                    self?.trackPushPermissionComplete()
                                    LGPushPermissionsManager.sharedInstance.showPushPermissionsAlert(prePermissionType: .listingListBanner)
            },
                                accessibilityId: .userPushPermissionOK)
        let negative = UIAction(interface: .styledText(LGLocalizedString.profilePermissionsAlertCancel, .cancel),
                                action: { [weak self] in
                                    self?.trackPushPermissionCancel()
            },
                                accessibilityId: .userPushPermissionCancel)
        delegate?.vmShowAlertWithTitle(LGLocalizedString.profilePermissionsAlertTitle,
                                       text: LGLocalizedString.profilePermissionsAlertMessage,
                                       alertType: .iconAlert(icon: UIImage(named: "custom_permission_profile")),
                                       actions: [negative, positive])
    }
}


// MARK: - Filters & bubble

fileprivate extension ListingFilters {
    var infoBubblePresent: Bool {
        guard let selectedOrdering = selectedOrdering else { return true }
        switch (selectedOrdering) {
        case .distance, .creation:
            return true
        case .priceAsc, .priceDesc:
            return false
        }
    }
}


// MARK: - Queries for Collections

fileprivate extension MainListingsViewModel {
    func queryForCollection(_ type: CollectionCellType) -> String {
        var query: String
        switch type {
        case .selectedForYou:
            query = keyValueStorage[.lastSuggestiveSearches]
                .flatMap { $0.suggestiveSearch.name }
                .reversed()
                .joined(separator: " ")
                .clipMoreThan(wordCount: Constants.maxSelectedForYouQueryTerms)
        }
        return query
    }
}


// MARK: - Tracking

fileprivate extension MainListingsViewModel {

    var listingVisitSource: EventParameterListingVisitSource {
        if let searchType = searchType {
            switch searchType {
            case .collection:
                return .collection
            case .user, .trending, .suggestive, .lastSearch:
                if !hasFilters {
                    return .search
                } else {
                    return .searchAndFilter
                }
            }
        }

        if hasFilters {
            if filters.selectedCategories.isEmpty {
                return .filter
            } else {
                return .category
            }
        }

        return .listingList
    }
    
    var feedSource: EventParameterFeedSource {
        if let search = searchType, search.isCollection {
            return .collection
        }
        if searchType == nil {
            if hasFilters {
                return .filter
            }
        } else {
            if hasFilters {
                return .searchAndFilter
            } else {
                return .search
            }
        }
        return .home
    }
    

    func trackRequestSuccess(page: UInt, resultsCount: Int, hasListings: Bool) {
        guard page == 0 else { return }
        let successParameter: EventParameterBoolean = hasListings ? .trueParameter : .falseParameter
        let trackerEvent = TrackerEvent.listingList(myUserRepository.myUser,
                                                    categories: filters.selectedCategories,
                                                    taxonomy: filters.selectedTaxonomyChildren.first,
                                                    searchQuery: queryString, resultsCount: resultsCount,
                                                    feedSource: feedSource, success: successParameter)
        tracker.trackEvent(trackerEvent)

        if let searchType = searchType, let searchQuery = searchType.query, shouldTrackSearch {
            shouldTrackSearch = false
            let successValue = hasListings ? EventParameterSearchCompleteSuccess.success : EventParameterSearchCompleteSuccess.fail
            tracker.trackEvent(TrackerEvent.searchComplete(myUserRepository.myUser, searchQuery: searchQuery,
                                                           isTrending: searchType.isTrending,
                                                           success: successValue, isLastSearch: searchType.isLastSearch,
                                                           isSuggestiveSearch: searchType.isSuggestive, suggestiveSearchIndex: searchType.indexSelected))
        }
    }

    func trackPushPermissionStart() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertStart(.push, typePage: .listingListBanner, alertType: .custom,
                                                             permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackPushPermissionComplete() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertComplete(.push, typePage: .listingListBanner, alertType: .custom,
                                                                permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }

    func trackPushPermissionCancel() {
        let goToSettings: EventParameterBoolean =
            LGPushPermissionsManager.sharedInstance.pushPermissionsSettingsMode ? .trueParameter : .notAvailable
        let trackerEvent = TrackerEvent.permissionAlertCancel(.push, typePage: .listingListBanner, alertType: .custom,
                                                              permissionGoToSettings: goToSettings)
        tracker.trackEvent(trackerEvent)
    }
}


extension MainListingsViewModel: EditLocationDelegate {
    func editLocationDidSelectPlace(_ place: Place, distanceRadius: Int?) {
        filters.place = place
        filters.distanceRadius = distanceRadius
        updateListView()
        delegate?.vmFiltersChanged()
    }
}


//MARK: CategoriesHeaderCollectionViewDelegate

extension MainListingsViewModel: CategoriesHeaderCollectionViewDelegate {
    func openTaxonomyList() {
        let vm = TaxonomiesViewModel(taxonomies: getTaxonomies(), taxonomySelected: nil, taxonomyChildSelected: nil, source: .listingList)
        vm.taxonomiesDelegate = self
        navigator?.openTaxonomyList(withViewModel: vm)
    }
    
    func openMostSearchedItems() {
        navigator?.openMostSearchedItems(source: .mostSearchedCategoryHeader, enableSearch: true)
    }
}


// MARK: TaxonomiesDelegate

extension MainListingsViewModel: TaxonomiesDelegate {
    func didSelect(taxonomy: Taxonomy) {
        filters.selectedTaxonomy = taxonomy
        filters.selectedTaxonomyChildren = []
        delegate?.vmShowTags(primaryTags: primaryTags, secondaryTags: secondaryTags)
        updateCategoriesHeader()
        updateRealEstateBanner()
        updateListView()
    }
    
    func didSelect(taxonomyChild: TaxonomyChild) {
        filters.selectedTaxonomyChildren = [taxonomyChild]
        delegate?.vmShowTags(primaryTags: primaryTags, secondaryTags: secondaryTags)
        updateCategoriesHeader()
        updateRealEstateBanner()
        updateListView()
    }
}

// MARK: ListingCellDelegate

extension MainListingsViewModel: ListingCellDelegate {
    func interestedActionFor(_ listing: Listing) {
        guard let identifier = listing.objectId else { return }
        if let state = listViewModel.listingInterestState[identifier],
            case .send(let enabled) = state, !enabled {
            return
        }
        markListingWithUndoableInterest(listing)
    }

    private func markListingWithUndoableInterest(_ listing: Listing) {
        guard let identifier = listing.objectId else { return }

        let action: () -> () = { [weak self] in
            guard let strSelf = self else { return }
            guard !strSelf.interestingListingIDs.contains(identifier) else {
                strSelf.navigator?.openChat(.listingAPI(listing: listing),
                                            source: .listingListFeatured,
                                            predefinedMessage: nil)
                return
            }

            strSelf.listViewModel.update(listing: listing, interestedState: .send(enabled: false))
            let (cancellable, timer) = LGTimer.cancellableWait(strSelf.interestingUndoTimeout)
            strSelf.showCancellableInterestedBubbleWith(duration: strSelf.interestingUndoTimeout) {
                cancellable.cancel()
            }
            timer.subscribe { [weak self] (event) in
                guard let strSelf = self else { return }
                guard event.error == nil else {
                    strSelf.sendInterestedMessage(forListing: listing, withID: identifier)
                    return
                }
                strSelf.undoInterestingMessageFor(listing: listing, withID: identifier)
                }.disposed(by: strSelf.disposeBag)
        }
        navigator?.openLoginIfNeeded(infoMessage: LGLocalizedString.chatLoginPopupText, then: action)
    }

    private func undoInterestingMessageFor(listing: Listing, withID identifier: String) {
        interestingListingIDs.remove(identifier)
        syncInterestingListings(interestingListingIDs)
        listViewModel.update(listing: listing, interestedState: .send(enabled: true))
    }

    private func syncInterestingListings(_ interestingListingIDs: Set<String>?) {
        guard let set = interestingListingIDs else { return }
        keyValueStorage.interestingListingIDs = set
    }

    private func sendInterestedMessage(forListing listing: Listing, withID identifier: String) {
        interestingListingIDs.update(with: identifier)
        syncInterestingListings(interestingListingIDs)
        chatWrapper.sendMessageFor(listing: listing,
                                   type: .quickAnswer(.interested),
                                   completion: nil)
        listViewModel.update(listing: listing, interestedState: .seeConversation)
    }

    private func showCancellableInterestedBubbleWith(duration: TimeInterval, then action: @escaping ()->()) {
        let message = LGLocalizedString.productInterestedBubbleMessage
        navigator?.showUndoBubble(withMessage: message, duration: duration, withAction: action)
    }

    func chatButtonPressedFor(listing: Listing) {
        navigator?.openChat(.listingAPI(listing: listing),
                            source: .listingListFeatured,
                            predefinedMessage: nil)
    }
    
    // Discarded listings are never shown in the main feed
    func editPressedForDiscarded(listing: Listing) {}
    
    // Discarded listings are never shown in the main feed
    func moreOptionsPressedForDiscarded(listing: Listing) {}
    
    func postNowButtonPressed(_ view: UIView) {
        navigator?.openSell(source: .realEstatePromo, postCategory: .realEstate)
    }
    
}

extension NoAdsInFeedForNewUsers {
    var ratio: Int {
        return shouldShowAdsInFeed ? 20 : 0
    }

    func customTargetingValueFor(position: Int) -> String {
        guard self.ratio != 0 else { return "" }
        let numberOfAd = ((position - MainListingsViewModel.adInFeedInitialPosition)/self.ratio) + 1
        return "var_c_pos_\(numberOfAd)"
    }
}

extension ShowAdsInFeedWithRatio {
    var ratio: Int {
        switch self {
        case .control, .baseline:
            return 0
        case .ten:
            return 10
        case .fifteen:
            return 15
        case .twenty:
            return 20
        }
    }

    func customTargetingValueFor(position: Int) -> String {
        guard self.ratio != 0 else { return "" }
        let numberOfAd = ((position - MainListingsViewModel.adInFeedInitialPosition)/self.ratio) + 1
        switch self {
        case .control, .baseline:
            return ""
        case .ten:
            return "var_a_pos_\(numberOfAd)"
        case .fifteen:
            return "var_b_pos_\(numberOfAd)"
        case .twenty:
            return "var_c_pos_\(numberOfAd)"
        }
    }
}
