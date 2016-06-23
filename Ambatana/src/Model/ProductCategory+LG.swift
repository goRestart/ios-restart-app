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
        case .Electronics:
            return UIColor(rgb: 0x009aab)   // 0 154 171 - tealBlue
        case .CarsAndMotors:
            return UIColor(rgb: 0x9b9b9b)   // 155 155 155 - ???
        case .SportsLeisureAndGames:
            return UIColor(rgb: 0x81ac56)   // 129 172 86 - asparagus
        case .HomeAndGarden:
            return UIColor(rgb: 0xf1b83d)   // 241 184 61 - macaroniAndCheese
        case .MoviesBooksAndMusic:
            return UIColor(rgb: 0xa384bf)   // 163 132 191 - wisteria
        case .FashionAndAccesories:
            return UIColor(rgb: 0xfe6e7f)   // 254 110 127 - ???
        case .BabyAndChild:
            return UIColor(rgb: 0x538fd1)   // 83 143 209 - cornFLower
        case .Other:
            return UIColor(rgb: 0xd1a960)   // 209 169 96 - desert
        }
    }

    static func categoriesFromString(categories: String) -> [ProductCategory] {
        return categories.characters.split(",").flatMap {
            guard let intValue = Int(String($0)) else { return nil }
            return ProductCategory(rawValue: intValue)
        }
    }
}
