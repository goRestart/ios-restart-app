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
            return FeatureFlags.sharedInstance.realEstateNewCopy.isActive ? R.Strings.categoriesRealEstateTitle : R.Strings.categoriesRealEstate
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
            return FeatureFlags.sharedInstance.realEstateNewCopy.isActive ? R.Strings.categoriesInFeedRealEstateTitle : R.Strings.categoriesInFeedRealEstate
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

extension Array where Element == ListingCategory {
    var trackValue: String {
        return self.map { String($0.rawValue) }
            .joined(separator: ",")
    }
}
