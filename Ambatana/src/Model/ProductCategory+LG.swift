//
//  ProductCategory+LG.swift
//  LetGo
//
//  Created by Albert Hernández López on 29/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ProductCategory {
    
    public var name : String {
        switch(self) {
        case .Unassigned:
            return LGLocalizedString.categoriesUnassigned
        case .Electronics:
            return LGLocalizedString.categoriesElectronics
        case .CarsAndMotors:
            return LGLocalizedString.categoriesCarsAndMotors
        case .SportsLeisureAndGames:
            return LGLocalizedString.categoriesSportsLeisureAndGames
        case .HomeAndGarden:
            return LGLocalizedString.categoriesHomeAndGarden
        case .MoviesBooksAndMusic:
            return LGLocalizedString.categoriesMoviesBooksAndMusic
        case .FashionAndAccesories:
            return LGLocalizedString.categoriesFashionAndAccessories
        case .BabyAndChild:
            return LGLocalizedString.categoriesBabyAndChild
        case .Other:
            return LGLocalizedString.categoriesOther
        }
    }
        
    public var image : UIImage? {
        switch (self) {
        case .Unassigned:
            return nil
        case .Electronics:
            return UIImage(named: "categories_electronics")
        case .CarsAndMotors:
            return UIImage(named: "categories_cars")
        case .SportsLeisureAndGames:
            return UIImage(named: "categories_sports")
        case .HomeAndGarden:
            return UIImage(named: "categories_homes")
        case .MoviesBooksAndMusic:
            return UIImage(named: "categories_music")
        case .FashionAndAccesories:
            return UIImage(named: "categories_fashion")
        case .BabyAndChild:
            return UIImage(named: "categories_babies")
        case .Other:
            return UIImage(named: "categories_others")
        }
    }
    
    public var imageSmallInactive : UIImage? {
        switch (self) {
        case .Unassigned:
            return nil
        case .Electronics:
            return UIImage(named: "categories_electronics_inactive")
        case .CarsAndMotors:
            return UIImage(named: "categories_cars_inactive")
        case .SportsLeisureAndGames:
            return UIImage(named: "categories_sports_inactive")
        case .HomeAndGarden:
            return UIImage(named: "categories_homes_inactive")
        case .MoviesBooksAndMusic:
            return UIImage(named: "categories_music_inactive")
        case .FashionAndAccesories:
            return UIImage(named: "categories_fashion_inactive")
        case .BabyAndChild:
            return UIImage(named: "categories_babies_inactive")
        case .Other:
            return UIImage(named: "categories_others_inactive")
        }
    }
    
    public var color : UIColor {
        switch (self) {
        case .Unassigned:
            return UIColor.unassignedCategory
        case .Electronics:
            return UIColor.electronicsCategory
        case .CarsAndMotors:
            return UIColor.carsMotorsCategory
        case .SportsLeisureAndGames:
            return UIColor.sportsGamesCategory
        case .HomeAndGarden:
            return UIColor.homeGardenCategory
        case .MoviesBooksAndMusic:
            return UIColor.moviesBooksCategory
        case .FashionAndAccesories:
            return UIColor.fashionAccessoriesCategory
        case .BabyAndChild:
            return UIColor.babyChildCategory
        case .Other:
            return UIColor.otherCategory
        }
    }

    static func categoriesFromString(categories: String) -> [FilterCategoryItem] {
        return categories.characters.split(",").flatMap {
            guard let intValue = Int(String($0)) else { return nil }
            guard let category = ProductCategory(rawValue: intValue) else { return nil }
            return FilterCategoryItem(category: category)
        }
    }
}
