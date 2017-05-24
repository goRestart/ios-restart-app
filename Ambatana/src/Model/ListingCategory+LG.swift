//
//  ListingCategory+LG.swift
//  LetGo
//
//  Created by Albert Hernández López on 29/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingCategory {
    
    func getName(isCarsEnabled: Bool) -> String {
        switch(self) {
        case .unassigned:
            return LGLocalizedString.categoriesUnassigned
        case .electronics:
            return LGLocalizedString.categoriesElectronics
        case .motorsAndAccessories:
            return isCarsEnabled ? LGLocalizedString.categoriesCarsAndMotors : LGLocalizedString.categoriesOldCarsAndMotors
        case .sportsLeisureAndGames:
            return LGLocalizedString.categoriesSportsLeisureAndGames
        case .homeAndGarden:
            return LGLocalizedString.categoriesHomeAndGarden
        case .moviesBooksAndMusic:
            return LGLocalizedString.categoriesMoviesBooksAndMusic
        case .fashionAndAccesories:
            return LGLocalizedString.categoriesFashionAndAccessories
        case .babyAndChild:
            return LGLocalizedString.categoriesBabyAndChild
        case .other:
            return LGLocalizedString.categoriesOther
        case .cars:
            return LGLocalizedString.categoriesCar
        }
    }
    
    var nameInFeed : String {
        switch(self) {
        case .unassigned:
            return ""
        case .electronics:
            return LGLocalizedString.categoriesInfeedElectronics
        case .motorsAndAccessories:
            return LGLocalizedString.categoriesInfeedMotors
        case .sportsLeisureAndGames:
            return LGLocalizedString.categoriesInfeedSportsLeisureGames
        case .homeAndGarden:
            return LGLocalizedString.categoriesInfeedHome
        case .moviesBooksAndMusic:
            return LGLocalizedString.categoriesInfeedBooksMovies
        case .fashionAndAccesories:
            return LGLocalizedString.categoriesInfeedFashion
        case .babyAndChild:
            return LGLocalizedString.categoriesInfeedBabyChild
        case .other:
            return LGLocalizedString.categoriesInfeedOthers
        case .cars:
            return LGLocalizedString.categoriesInfeedCars
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
        }
    }
    
    var color : UIColor {
        switch (self) {
        case .unassigned:
            return UIColor.unassignedCategory
        case .electronics:
            return UIColor.electronicsCategory
        case .motorsAndAccessories:
            return UIColor.carsMotorsCategory
        case .sportsLeisureAndGames:
            return UIColor.sportsGamesCategory
        case .homeAndGarden:
            return UIColor.homeGardenCategory
        case .moviesBooksAndMusic:
            return UIColor.moviesBooksCategory
        case .fashionAndAccesories:
            return UIColor.fashionAccessoriesCategory
        case .babyAndChild:
            return UIColor.babyChildCategory
        case .other:
            return UIColor.otherCategory
        case .cars:
            return UIColor.carCategory
        }
    }

    static func categoriesFromString(_ categories: String) -> [ListingCategory] {
        return categories.components(separatedBy: ",").flatMap {
            guard let intValue = Int(String(describing: $0)) else { return nil }
            return ListingCategory(rawValue: intValue)
        }
    }
}
