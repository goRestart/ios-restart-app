import LGCoreKit
import LGComponents

protocol ExpandableCategorySelectionDelegate: class {
    func didPressCloseButton()
    func tapOutside()
    func didPressCategory(_ listingCategory: ListingCategory)
}

class ExpandableCategorySelectionViewModel: BaseViewModel {
    
    weak var delegate: ExpandableCategorySelectionDelegate?
    let categoriesAvailable: [ListingCategory]
    private(set) var newBadgeCategory: ListingCategory?
    private let featureFlags: FeatureFlaggeable
    
    // MARK: - View lifecycle
    
    init(featureFlags: FeatureFlaggeable) {
        self.featureFlags = featureFlags
        let realEstateEnabled = featureFlags.realEstateEnabled.isActive

        var categories: [ListingCategory] = []
        categories.append(.unassigned)
        categories.append(.motorsAndAccessories)
        categories.append(.cars)
        categories.append(.services)

        if realEstateEnabled {
            categories.append(.realEstate)
        }
        self.categoriesAvailable = categories.sorted(by: {
            $0.sortWeight(featureFlags: featureFlags) < $1.sortWeight(featureFlags: featureFlags)
        })
        self.newBadgeCategory = .services
        super.init()
    }
    
    func buttonTitle(forCategory category: ListingCategory) -> String? {
        
        switch category {
        case .unassigned:
            return R.Strings.categoriesUnassignedItems
        case .motorsAndAccessories, .cars, .homeAndGarden, .babyAndChild,
             .electronics, .fashionAndAccesories, .moviesBooksAndMusic, .other, .sportsLeisureAndGames:
            return category.name
        case .realEstate:
            return R.Strings.productPostSelectCategoryHousing
        case .services:
            if featureFlags.jobsAndServicesEnabled.isActive {
                return R.Strings.postingFlowJobsAndServicesCategoryButtonText
            }
            return category.name
        }
    }
    
    func buttonIcon(forCategory category: ListingCategory) -> UIImage? {
        
        switch category {
        case .unassigned:
            return R.Asset.IconsButtons.items.image
        case .cars:
            return R.Asset.IconsButtons.carIcon.image
        case .motorsAndAccessories:
            return R.Asset.IconsButtons.motorsAndAccesories.image
        case .realEstate:
            return R.Asset.IconsButtons.housingIcon.image
        case .services:
            return R.Asset.IconsButtons.servicesIcon.image
        case .homeAndGarden, .babyAndChild, .electronics, .fashionAndAccesories,
             .moviesBooksAndMusic, .other, .sportsLeisureAndGames:
            return category.image
        }
    }
    
    
    // MARK: - UI Actions
    
    func closeButtonAction() {
        delegate?.didPressCloseButton()
    }

    func tapOutside() {
        delegate?.tapOutside()
    }
    
    func pressCategoryAction(listingCategory: ListingCategory) {
        delegate?.didPressCategory(listingCategory)
    }
}
