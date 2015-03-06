//
//  CommonDataTypes.swift
//  Ambatana
//
//  Created by Ignacio Nieto Carvajal on 12/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

// constants
let kAmbatanaMinPasswordLength = 6
let kAmbatanaDefaultCategoriesLanguage = "en"
let kAmbatanaFullScreenWidth = UIScreen.mainScreen().bounds.size.width
let kAmbatanaProductCellSpan: CGFloat = 10.0
let kAmbatanaProductListOffsetLoadingOffsetInc = 10 // Load 20 products each time.
let kAmbatanaProductListMaxKmDistance = 10000
let kAmbatanaDefaultUserImageName = "no_photo"
let kAmbatanaContentScrollingDownThreshold: CGFloat = 20.0
let kAmbatanaContentScrollingUpThreshold: CGFloat = -20.0
let kAmbatanaMaxProductImageSide: CGFloat = 1024
let kAmbatanaMaxProductImageJPEGQuality: CGFloat = 1.0
let kAmbatanaProductImageKeys = ["image_0", "image_1", "image_2", "image_3", "image_4"]
let kAmbatanaProductFirstImageKey = kAmbatanaProductImageKeys.first!
let kAmbatanaWebsiteURL = "http://ambatana.com"

// notifications
let kAmbatanaUserPictureUpdatedNotification                     = "AmbatanaUserPictureUpdated"
let kAmbatanaSessionInvalidatedNotification                     = "AmbatanaSessionInvalidated"
let kAmbatanaInvalidCredentialsNotification                     = "AmbatanaInvalidCredentialsNotification"
let kAmbatanaUnableToGetUserLocationNotification                = "AmbatanaUnableToGetUserLocation"
let kAmbatanaUnableToSetUserLocationNotification                = "AmbatanaUnableToSetUserLocationNotification"
let kAmbatanaUserLocationSuccessfullySetNotification            = "AmbatanaUserLocationSuccessfullySetNotification"
let kAmbatanaUserLocationSuccessfullyChangedNotification        = "AmbatanaUserLocationSuccessfullyChangedNotification"
let kAmbatanaUserBadgeChangedNotification                       = "AmbatanaUserBadgeChangedNotification"

/** Product list categories */
enum ProductListCategory: Int {
    case Electronics = 1, CarsAndMotors = 2, SportsLeisureAndGames = 3, HomeAndGarden = 4, MoviesBooksAndMusic = 5, FashionAndAccesories = 6, BabyAndChild = 7, Other = 8
    
    func getName() -> String {
        switch(self) {
        case .Electronics:
            return translate("electronics")
        case .CarsAndMotors:
            return translate("cars_and_motors")
        case .SportsLeisureAndGames:
            return translate("sports_leisure_and_games")
        case .HomeAndGarden:
            return translate("home_and_garden")
        case .MoviesBooksAndMusic:
            return translate("movies_books_and_music")
        case .FashionAndAccesories:
            return translate("fashion_and_accesories")
        case .BabyAndChild:
            return translate("baby_and_child")
        case .Other:
            return translate("other")
        }
    }
    
    static func allCategories() -> [ProductListCategory] { return [.Electronics, .CarsAndMotors, .SportsLeisureAndGames, .HomeAndGarden, .MoviesBooksAndMusic, .FashionAndAccesories, .BabyAndChild, .Other] }
    
    func getDirifyName() -> String {
        switch(self) {
        case .Electronics:
            return "electronics"
        case .CarsAndMotors:
            return "cars_and_motors"
        case .SportsLeisureAndGames:
            return "sports_leisure_and_games"
        case .HomeAndGarden:
            return "home_and_garden"
        case .MoviesBooksAndMusic:
            return "movies_books_and_music"
        case .FashionAndAccesories:
            return "fashion_and_accesories"
        case .BabyAndChild:
            return "baby_and_child"
        case .Other:
            return "other"
        }
    }
    
    func imageForCategory() -> UIImage? {
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

/** Product status */
//- Status: 0 si el producto está pendiente de aprobación, 1 si está aprobado, 2 si está descartado, 3 si está vendido.
enum ProductStatus: Int {
    case Pending = 0, Approved = 1, Discarded = 2, Sold = 3
}
