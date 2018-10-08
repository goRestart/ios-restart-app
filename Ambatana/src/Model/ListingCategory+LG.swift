import LGCoreKit
import LGComponents

extension ListingCategory {
    
    var name: String {
        switch(self) {
        case .unassigned:
            return R.Strings.categoriesUnassigned
        case .electronics:
            return R.Strings.categoriesElectronics
        case .motorsAndAccessories:
            return R.Strings.categoriesCarsAndMotors
        case .sportsLeisureAndGames:
            return R.Strings.categoriesSportsLeisureAndGames
        case .homeAndGarden:
            return R.Strings.categoriesHomeAndGarden
        case .moviesBooksAndMusic:
            return R.Strings.categoriesMoviesBooksAndMusic
        case .fashionAndAccesories:
            return R.Strings.categoriesFashionAndAccessories
        case .babyAndChild:
            return R.Strings.categoriesBabyAndChild
        case .other:
            return R.Strings.categoriesOther
        case .cars:
            return R.Strings.categoriesCar
        case .realEstate:
            return R.Strings.categoriesRealEstate
        case .services:
            return FeatureFlags.sharedInstance.jobsAndServicesEnabled.isActive ? R.Strings.categoriesJobsServices : R.Strings.categoriesServices
        }
    }
    
    var nameInFeed : String {
        switch(self) {
        case .unassigned:
            return ""
        case .electronics:
            return R.Strings.categoriesInFeedElectronics
        case .motorsAndAccessories:
            return R.Strings.categoriesInFeedMotors
        case .sportsLeisureAndGames:
            return R.Strings.categoriesInFeedSportsLeisureGames
        case .homeAndGarden:
            return R.Strings.categoriesInFeedHome
        case .moviesBooksAndMusic:
            return R.Strings.categoriesInFeedBooksMovies
        case .fashionAndAccesories:
            return R.Strings.categoriesInFeedFashion
        case .babyAndChild:
            return R.Strings.categoriesInFeedBabyChild
        case .other:
            return R.Strings.categoriesInFeedOthers
        case .cars:
            return R.Strings.categoriesInFeedCars
        case .realEstate:
            return R.Strings.categoriesInFeedRealEstate
        case .services:
            return R.Strings.categoriesInFeedServices
        }
    }
    
    var imageInFeed: UIImage? {
        switch (self) {
        case .unassigned:
            return nil
        case .electronics:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.techFeed.image
        case .motorsAndAccessories:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.motorsFeed.image
        case .sportsLeisureAndGames:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.leisureFeed.image
        case .homeAndGarden:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.homeFeed.image
        case .moviesBooksAndMusic:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.entretainmentFeed.image
        case .fashionAndAccesories:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.fashionFeed.image
        case .babyAndChild:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.childFeed.image
        case .other:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.othersFeed.image
        case .cars:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.carsFeed.image
        case .realEstate:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.housingFeed.image
        case .services:
            return R.Asset.IconsButtons.CategoriesHeaderIcons.servicesFeed.image
        }
    }
    
    var image: UIImage? {
        switch (self) {
        case .unassigned:
            return nil
        case .electronics:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesElectronicsInactive.image
        case .motorsAndAccessories:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesMotorsInactive.image
        case .sportsLeisureAndGames:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesSportsInactive.image
        case .homeAndGarden:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesHomesInactive.image
        case .moviesBooksAndMusic:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesMusicInactive.image
        case .fashionAndAccesories:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesFashionInactive.image
        case .babyAndChild:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesBabiesInactive.image
        case .other:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesOthersInactive.image
        case .cars:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesCarsInactive.image
        case .realEstate:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesRealestateInactive.image
        case .services:
            return R.Asset.IconsButtons.FiltersCategoriesIcons.categoriesServicesInactive.image
        }
    }
    
    var imageTag: UIImage? {
        switch (self) {
        case .unassigned:
            return nil
        case .electronics:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesElectronicsTag.image
        case .motorsAndAccessories:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesMotorsTag.image
        case .sportsLeisureAndGames:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesSportsTag.image
        case .homeAndGarden:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesHomesTag.image
        case .moviesBooksAndMusic:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesMusicTag.image
        case .fashionAndAccesories:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesFashionTag.image
        case .babyAndChild:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesBabiesTag.image
        case .other:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesOthersTag.image
        case .cars:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesCarsTag.image
        case .realEstate:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesHousingTag.image
        case .services:
            return R.Asset.IconsButtons.FiltersTagCategories.categoriesServicesTag.image
        }
    }

    static func categoriesFromString(_ categories: String) -> [ListingCategory] {
        return categories.components(separatedBy: ",").compactMap {
            guard let intValue = Int(String(describing: $0)) else { return nil }
            return ListingCategory(rawValue: intValue)
        }
    }
    
    func postingCategory(with featureFlags: FeatureFlaggeable) -> PostCategory {
        switch self {
        case .realEstate:
            return .realEstate
        case .cars:
            return .car
        case .motorsAndAccessories:
            return .motorsAndAccessories
        case .services:
            return .services
        case .babyAndChild, .electronics, .fashionAndAccesories, .homeAndGarden, .moviesBooksAndMusic, .other,
             .sportsLeisureAndGames, .unassigned:
            return .otherItems(listingCategory: nil)
        }
    }
    
    var mapAccuracy: Double {
        switch self {
        case .realEstate:
            return SharedConstants.largestRegionRadius
        case .cars,.motorsAndAccessories,.babyAndChild, .electronics, .fashionAndAccesories, .homeAndGarden,
             .moviesBooksAndMusic, .other, .sportsLeisureAndGames, .unassigned, .services:
            return SharedConstants.nonAccurateRegionRadius
        }
    }
}

extension ListingCategory {
    static func visibleValuesInFeed(servicesIncluded: Bool,
                                    realEstateIncluded: Bool,
                                    servicesHighlighted: Bool) -> [ListingCategory] {

        var categories: [ListingCategory] = [.electronics, .homeAndGarden,
                                             .sportsLeisureAndGames, .motorsAndAccessories,
                                             .fashionAndAccesories, .babyAndChild,
                                             .moviesBooksAndMusic]
        if servicesIncluded {
            servicesHighlighted ? categories.insert(.services, at: 0) : categories.append(.services)
        }

        if realEstateIncluded {
            categories.insert(.realEstate, at: 0)
        }
        categories.insert(.cars, at: 0)
        categories.append(.other)

        return categories
    }

    var isProfessionalCategory: Bool {
        return self == .realEstate || self == .cars || self == .services
    }

    func sortWeight(featureFlags: FeatureFlaggeable) -> Int {
        switch self {
        case .cars:
            return 100
        case .motorsAndAccessories:
            return 80
        case .services:
            return 70
        case .realEstate:
            return 60
        case .unassigned:
            return 0    // Usually at bottom
        default:
            return 10
        }
    }

    func index(listingRepository: ListingRepository) -> ((RetrieveListingParams, ListingsCompletion?) -> ()) {
        switch self {
        case .realEstate:
            return listingRepository.indexRealEstate
        case .cars:
            return listingRepository.indexCars
        case .services:
            return listingRepository.indexServices
        case .babyAndChild, .electronics, .fashionAndAccesories, .homeAndGarden, .motorsAndAccessories,
             .moviesBooksAndMusic, .other, .sportsLeisureAndGames,
             .unassigned:
            return listingRepository.index
        }
    }
}

extension ListingCategory: CustomStringConvertible {
    private enum Descriptor {
        static let unassigned = "unassigned"
        static let electronics = "electronics"
        static let motorsAndAccessories = "motorsAndAccessories"
        static let sportsLeisureAndGames = "sportsLeisureAndGames"
        static let homeAndGarden = "homeAndGarden"
        static let moviesBooksAndMusic = "moviesBooksAndMusic"
        static let fashionAndAccesories = "fashionAndAccesories"
        static let babyAndChild = "babyAndChild"
        static let other = "other"
        static let cars = "cars"
        static let realEstate = "realEstate"
        static let services = "services"
    }
    public var description: String {
        switch self {
        case .unassigned: return "unassigned"
        case .electronics: return "electronics"
        case .motorsAndAccessories: return "motorsAndAccessories"
        case .sportsLeisureAndGames:return "sportsLeisureAndGames"
        case .homeAndGarden: return "homeAndGarden"
        case .moviesBooksAndMusic: return "moviesBooksAndMusic"
        case .fashionAndAccesories: return "fashionAndAccesories"
        case .babyAndChild: return "babyAndChild"
        case .other: return "other"
        case .cars: return "cars"
        case .realEstate: return "realEstate"
        case .services: return "services"
        }
    }

    init?(description: String) {
        if description == Descriptor.unassigned {
            self = .unassigned
        } else if description == Descriptor.electronics {
            self = .electronics
        } else if description == Descriptor.motorsAndAccessories {
            self = .motorsAndAccessories
        } else if description == Descriptor.sportsLeisureAndGames {
            self = .sportsLeisureAndGames
        } else if description == Descriptor.homeAndGarden {
            self = .homeAndGarden
        } else if description == Descriptor.moviesBooksAndMusic {
            self = .moviesBooksAndMusic
        } else if description == Descriptor.fashionAndAccesories {
            self = .fashionAndAccesories
        } else if description == Descriptor.babyAndChild {
            self = .babyAndChild
        } else if description == Descriptor.other {
            self = .other
        } else if description == Descriptor.cars {
            self = .cars
        } else if description == Descriptor.realEstate {
            self = .realEstate
        } else if description == Descriptor.services {
            self = .services
        }
        return nil
    }
}

extension Array where Element == ListingCategory {
    func filteringBy(_ categories: [ListingCategory]) -> [Element] {
        return self.filter { !categories.contains($0) }
    }
}

extension Array where Element == ListingCategory {
    var trackValue: String {
        return self.map { String($0.rawValue) }
            .joined(separator: ",")
    }
}
