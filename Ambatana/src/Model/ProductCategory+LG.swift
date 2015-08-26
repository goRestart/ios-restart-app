//
//  ProductCategory+LG.swift
//  LetGo
//
//  Created by Albert Hernández López on 29/06/15.
//  Copyright (c) 2015 Ambatana. All rights reserved.
//

import LGCoreKit

extension ProductCategory {
    public func name() -> String {
        switch(self) {
        case .Electronics:
            return NSLocalizedString("categories_electronics", comment: "")
        case .CarsAndMotors:
            return NSLocalizedString("categories_cars_and_motors", comment: "")
        case .SportsLeisureAndGames:
            return NSLocalizedString("categories_sports_leisure_and_games", comment: "")
        case .HomeAndGarden:
            return NSLocalizedString("categories_home_and_garden", comment: "")
        case .MoviesBooksAndMusic:
            return NSLocalizedString("categories_movies_books_and_music", comment: "")
        case .FashionAndAccesories:
            return NSLocalizedString("categories_fashion_and_accessories", comment: "")
        case .BabyAndChild:
            return NSLocalizedString("categories_baby_and_child", comment: "")
        case .Other:
            return NSLocalizedString("categories_other", comment: "")
        }
    }
    
    public func image() -> UIImage? {
        switch (self) {
        case .Electronics:
            return UIImage(named: "categories_electronics")!
        case .CarsAndMotors:
            return UIImage(named: "categories_cars")!
        case .SportsLeisureAndGames:
            return UIImage(named: "categories_sports")!
        case .HomeAndGarden:
            return UIImage(named: "categories_homes")!
        case .MoviesBooksAndMusic:
            return UIImage(named: "categories_music")!
        case .FashionAndAccesories:
            return UIImage(named: "categories_fashion")!
        case .BabyAndChild:
            return UIImage(named: "categories_babies")!
        case .Other:
            return UIImage(named: "categories_others")!
        default:
            return nil
        }
    }
}
