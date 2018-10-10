import LGCoreKit
import LGComponents

enum PostCategory: Equatable {
    case car
    case otherItems(listingCategory: ListingCategory?)
    case motorsAndAccessories
    case realEstate
    case services
    case jobs
    
    var listingCategory: ListingCategory {
        switch self {
        case .car:
            return .cars
        case .otherItems(let category):
            return category ?? .unassigned
        case .motorsAndAccessories:
            return .motorsAndAccessories
        case .realEstate:
            return .realEstate
        case .services, .jobs:
            return .services
        }
    }
    
    var numberOfSteps: CGFloat {
        switch self {
        case .car:
            return 3
        case .realEstate:
            return 5
        case .otherItems, .motorsAndAccessories, .services, .jobs:
            return 0
        }
    }
    
    var isServiceOrJob: Bool {
        switch self {
        case .services, .jobs: return true
        default: return false
        }
    }
    
    var isJobs: Bool {
        switch self {
        case .jobs: return true
        default: return false
        }
    }
    
    var hasAddingDetailsScreen: Bool {
        switch self {
        case .services, .jobs, .realEstate:
            return true
        default:
            return false
        }
    }
    
    func postCameraTitle(forFeatureFlags featureFlags: FeatureFlaggeable) -> String? {
        switch self {
        case .services:
            return R.Strings.postDetailsServicesCameraMessage
        case .jobs:
            return R.Strings.postDetailsJobsCameraMessage
        case .realEstate:
            return R.Strings.realEstateCameraViewRealEstateMessage
        case .otherItems, .motorsAndAccessories, .car:
            return nil
        }
    }
}

extension PostCategory: CustomStringConvertible {
    private enum Descriptor {
        static let car = "car"
        static let motorsAndAccessories = "motorsAndAccessories"
        static let realEstate = "realEstate"
        static let services = "services"
        static let otherItems = "otherItems"
        static let jobs = "jobs"
    }
    var description: String {
        switch self {
        case .car: return Descriptor.car
        case .otherItems(let category): return category?.description ?? ""
        case .motorsAndAccessories: return Descriptor.motorsAndAccessories
        case .realEstate: return Descriptor.realEstate
        case .services: return Descriptor.services
        case .jobs: return Descriptor.jobs
        }
    }
    
    init?(description: String?) {
        guard let description = description else { return nil }
        if description == Descriptor.car {
            self = .car
        } else if description == Descriptor.realEstate {
            self = .realEstate
        } else if description == Descriptor.motorsAndAccessories {
            self = .motorsAndAccessories
        } else if description == Descriptor.services {
            self = .services
        } else if description == Descriptor.jobs {
            self = .jobs
        } else if let category = ListingCategory.init(description: description) {
            self = .otherItems(listingCategory: category)
        }
        return nil
    }
}

func ==(lhs: PostCategory, rhs: PostCategory) -> Bool {
    switch (lhs, rhs) {
    case (.car, .car), (.motorsAndAccessories, .motorsAndAccessories), (.realEstate, .realEstate),
         (.services, .services), (.jobs, .jobs):
        return true
    case (.otherItems(_), .otherItems(_)):
        return true
    default:
        return false
    }
}


//  MARK: Expandable Menu

extension PostCategory {
    
    func sortWeight(featureFlags: FeatureFlaggeable) -> Int {
        switch self {
        case .car:
            return 100
        case .motorsAndAccessories:
            return 80
        case .realEstate:
            return 50
        case .services:
            return 70
        case .jobs:
            return 60
        case .otherItems:
            return 0    // Usually at bottom
        }
    }
    
    var menuName: String? {
        switch self {
        case .car: return R.Strings.categoriesCar
        case .otherItems: return R.Strings.categoriesUnassignedItems
        case .motorsAndAccessories: return R.Strings.categoriesCarsAndMotors
        case .realEstate: return R.Strings.productPostSelectCategoryHousing
        case .services: return R.Strings.categoriesServices
        case .jobs: return R.Strings.productPostSelectCategoryJobs
        }
    }
    
    var menuIcon: UIImage? {
        switch self {
        case .car: return R.Asset.IconsButtons.carIcon.image
        case .otherItems: return R.Asset.IconsButtons.items.image
        case .motorsAndAccessories: return R.Asset.IconsButtons.motorsAndAccesories.image
        case .realEstate: return R.Asset.IconsButtons.housingIcon.image
        case .services: return R.Asset.IconsButtons.servicesIcon.image
        case .jobs: return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesJobsInactive.image.tint(color: .white)
        }
    }
}

//  MARK: Builder

extension PostCategory {
    
    static func buildPostCategories(featureFlags: FeatureFlaggeable) -> [PostCategory] {
        var postCategories: [PostCategory] = [.car, .motorsAndAccessories, .otherItems(listingCategory: nil), .services]
        
        if featureFlags.realEstateEnabled.isActive { postCategories.append(.realEstate) }
        if featureFlags.jobsAndServicesEnabled.isActive { postCategories.append(.jobs) }
        
        return postCategories
    }
}
