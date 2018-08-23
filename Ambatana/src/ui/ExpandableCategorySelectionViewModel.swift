import LGCoreKit
import LGComponents

extension ListingCategory {
    func sortWeight(featureFlags: FeatureFlaggeable) -> Int {
        switch self {
        case .cars:
            return 100
        case .motorsAndAccessories:
            return 80
        case .realEstate:
            return 60
        case .services:
            switch featureFlags.servicesCategoryOnSalchichasMenu {
            case .variantA:
                return 110  // Should appear above cars
            case .variantB:
                return 70   // Should appear below motors and accesories
            case .variantC:
                return 50   // Should appear below real estate
            default:
                return 10 // Not active, should never happen
            }
        case .unassigned:
            return 0    // Usually at bottom
        default:
            return 10
        }
    }
}

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
        let servicesEnabled = featureFlags.servicesCategoryOnSalchichasMenu.isActive
        let realEstateEnabled = featureFlags.realEstateEnabled.isActive

        var categories: [ListingCategory] = []
        categories.append(.unassigned)
        categories.append(.motorsAndAccessories)
        categories.append(.cars)

        if realEstateEnabled {
            categories.append(.realEstate)
        }
        if servicesEnabled {
            categories.append(.services)
        }
        self.categoriesAvailable = categories.sorted(by: {
            $0.sortWeight(featureFlags: featureFlags) < $1.sortWeight(featureFlags: featureFlags)
        })
        if servicesEnabled {
            self.newBadgeCategory = .services
        } else if featureFlags.realEstateEnabled.isActive {
            self.newBadgeCategory = .realEstate
        }
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
            return featureFlags.realEstateNewCopy.isActive ? R.Strings.productPostSelectCategoryRealEstate : R.Strings.productPostSelectCategoryHousing
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
