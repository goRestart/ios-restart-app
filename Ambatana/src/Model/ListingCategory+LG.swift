//
//  ListingCategory+LG.swift
//  LetGo
//
//  Created by Albert Hernández López on 29/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ListingCategory {
    
    var name : String {
        switch(self) {
        case .unassigned:
            return LGLocalizedString.categoriesUnassigned
        case .electronics:
            return LGLocalizedString.categoriesElectronics
        case .motorsAndAccessories:
            return LGLocalizedString.categoriesCarsAndMotors
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
        
    var image : UIImage? {
        switch (self) {
        case .unassigned:
            return nil
        case .electronics:
            return UIImage(named: "categories_electronics")
        case .motorsAndAccessories:
            return UIImage(named: "categories_motors")
        case .sportsLeisureAndGames:
            return UIImage(named: "categories_sports")
        case .homeAndGarden:
            return UIImage(named: "categories_homes")
        case .moviesBooksAndMusic:
            return UIImage(named: "categories_music")
        case .fashionAndAccesories:
            return UIImage(named: "categories_fashion")
        case .babyAndChild:
            return UIImage(named: "categories_babies")
        case .other:
            return UIImage(named: "categories_others")
        case .cars:
            return UIImage(named: "categories_cars")
        }
    }
    
    var imageSmallInactive : UIImage? {
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
