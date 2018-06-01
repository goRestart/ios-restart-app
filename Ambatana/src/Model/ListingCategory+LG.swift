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
            return R.Strings.categoriesServices
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
            return UIImage(named: "tech_feed")
        case .motorsAndAccessories:
            return UIImage(named: "motors_feed")
        case .sportsLeisureAndGames:
            return UIImage(named: "leisure_feed")
        case .homeAndGarden:
            return UIImage(named: "home_feed")
        case .moviesBooksAndMusic:
            return UIImage(named: "entretainment_feed")
        case .fashionAndAccesories:
            return UIImage(named: "fashion_feed")
        case .babyAndChild:
            return UIImage(named: "child_feed")
        case .other:
            return UIImage(named: "others_feed")
        case .cars:
            return UIImage(named: "cars_feed")
        case .realEstate:
            return UIImage(named: "housing_feed")
        case .services:
            return UIImage(named: "services_feed")
        }
    }
    
    var image: UIImage? {
        switch (self) {
        case .unassigned:
            return nil
        case .electronics:
            return UIImage(named: "categories_electronics_inactive")
        case .motorsAndAccessories:
            return UIImage(named: "categories_motors_inactive")
        case .sportsLeisureAndGames:
            return UIImage(named: "categories_sports_inactive")
        case .homeAndGarden:
            return UIImage(named: "categories_homes_inactive")
        case .moviesBooksAndMusic:
            return UIImage(named: "categories_music_inactive")
        case .fashionAndAccesories:
            return UIImage(named: "categories_fashion_inactive")
        case .babyAndChild:
            return UIImage(named: "categories_babies_inactive")
        case .other:
            return UIImage(named: "categories_others_inactive")
        case .cars:
            return UIImage(named: "categories_cars_inactive")
        case .realEstate:
            return UIImage(named: "categories_realestate_inactive")
        case .services:
            return UIImage(named: "categories_services_inactive")
        }
    }
    
    var imageTag: UIImage? {
        switch (self) {
        case .unassigned:
            return nil
        case .electronics:
            return UIImage(named: "categories_electronics_tag")
        case .motorsAndAccessories:
            return UIImage(named: "categories_motors_tag")
        case .sportsLeisureAndGames:
            return UIImage(named: "categories_sports_tag")
        case .homeAndGarden:
            return UIImage(named: "categories_homes_tag")
        case .moviesBooksAndMusic:
            return UIImage(named: "categories_music_tag")
        case .fashionAndAccesories:
            return UIImage(named: "categories_fashion_tag")
        case .babyAndChild:
            return UIImage(named: "categories_babies_tag")
        case .other:
            return UIImage(named: "categories_others_tag")
        case .cars:
            return UIImage(named: "categories_cars_tag")
        case .realEstate:
            return UIImage(named: "categories_housing_tag")
        case .services:
            return UIImage(named: "categories_services_tag")
        }
    }

    static func categoriesFromString(_ categories: String) -> [ListingCategory] {
        return categories.components(separatedBy: ",").flatMap {
            guard let intValue = Int(String(describing: $0)) else { return nil }
            return ListingCategory(rawValue: intValue)
        }
    }
    
    var postCategory: PostCategory {
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
            return Constants.largestRegionRadius
        case .cars,.motorsAndAccessories,.babyAndChild, .electronics, .fashionAndAccesories, .homeAndGarden,
             .moviesBooksAndMusic, .other, .sportsLeisureAndGames, .unassigned, .services:
            return Constants.nonAccurateRegionRadius
        }
    }

}

extension Array where Element == ListingCategory {
    var trackValue: String {
        return self.map { String($0.rawValue) }
            .joined(separator: ",")
    }
}
