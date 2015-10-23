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
        }
    }
}
