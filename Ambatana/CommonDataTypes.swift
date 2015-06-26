//
//  CommonDataTypes.swift
//  LetGo
//
//  Created by Ignacio Nieto Carvajal on 12/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

// constants
let kLetGoDefaultCategoriesLanguage = "en"
let kLetGoFullScreenWidth = UIScreen.mainScreen().bounds.size.width
let kLetGoProductCellSpan: CGFloat = 10.0
let kLetGoProductListOffsetLoadingOffsetInc = 20 // Load 20 products each time.
let kLetGoProductListMaxKmDistance = 10000
let kLetGoDefaultUserImageName = "no_photo"
let kLetGoContentScrollingDownThreshold: CGFloat = 20.0
let kLetGoContentScrollingUpThreshold: CGFloat = -20.0
let kLetGoMaxProductImageSide: CGFloat = 1024
let kLetGoMaxProductImageJPEGQuality: CGFloat = 0.9
let kLetGoProductImageKeys = ["image_0", "image_1", "image_2", "image_3", "image_4"]
let kLetGoProductFirstImageKey = kLetGoProductImageKeys.first!
let kLetGoWebsiteURL = "http://letgo.com"

/** Product list categories */
@objc enum LetGoProductCategory: Int {
    case Electronics = 1, CarsAndMotors = 2, SportsLeisureAndGames = 3, HomeAndGarden = 4, MoviesBooksAndMusic = 5, FashionAndAccesories = 6, BabyAndChild = 7, Other = 8
    
    func getName() -> String {
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
            return NSLocalizedString("categories_fashion_and_accesories", comment: "")
        case .BabyAndChild:
            return NSLocalizedString("categories_baby_and_child", comment: "")
        case .Other:
            return NSLocalizedString("categories_other", comment: "")
        }
    }
    
    static func allCategories() -> [LetGoProductCategory] { return [.Electronics, .CarsAndMotors, .SportsLeisureAndGames, .HomeAndGarden, .MoviesBooksAndMusic, .FashionAndAccesories, .BabyAndChild, .Other] }
    
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

/** Metric system used for measuring distance to products */
@objc enum LetGoDistanceMeasurementSystem: Int {
    case Metric = 0, American = 1
    
    func distanceMeasurementStringForRestAPI() -> String {
        switch (self) {
        case .Metric:
            return "KM"
        case .American:
            return "ML"
        }
    }
    
//    static func retrieveDistanceMeasurementSystemForLocale(locale: NSLocale)  -> LetGoDistanceMeasurementSystem {
//        if let usesMetric = locale.objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
//            return usesMetric ? .Metric : .American
//        } else { return .Metric }
//    }
    
    static func retrieveCurrentDistanceMeasurementSystem() -> LetGoDistanceMeasurementSystem {
        if let usesMetric = NSLocale.currentLocale().objectForKey(NSLocaleUsesMetricSystem)?.boolValue {
            return usesMetric ? .Metric : .American
        } else { return .Metric }
    }
    
    init?(distanceString: String) {
        if distanceString.lowercaseString == "ml" || distanceString.lowercaseString == "miles" { self = .American }
        else if distanceString.lowercaseString == "km" || distanceString.lowercaseString == "kilometres" { self = .Metric }
        else { return nil }
    }
}



/** Filter for products to be retrieved from the REST API */
@objc enum LetGoUserFilterForProducts: Int {
    case Proximity = 1, MinPrice = 2, MaxPrice = 3, CreationDate = 4
    
    func filterStringForRestAPI() -> String? {
        switch (self) {
        case .Proximity:
            return nil
        case .MinPrice:
            return "price asc"
        case .MaxPrice:
            return "price desc"
        case .CreationDate:
            return "created_at desc"
        }
    }
}

/** Product status */
//- Status: 0 si el producto está pendiente de aprobación, 1 si está aprobado, 2 si está descartado, 3 si está vendido.
@objc enum LetGoProductStatus: Int, Printable {
    case Pending = 0, Approved = 1, Discarded = 2, Sold = 3
    var description: String { return "\(self.rawValue)" }
}

