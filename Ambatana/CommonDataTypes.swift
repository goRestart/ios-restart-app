//
//  CommonDataTypes.swift
//  Ambatana
//
//  Created by Nacho on 12/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

// constants
let kAmbatanaMinPasswordLength = 6
let kAmbatanaDefaultCategoriesLanguage = "en"
let kAmbatanaTableScreenWidth = UIScreen.mainScreen().bounds.size.width
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

// notifications
let kAmbatanaUserPictureUpdatedNotification                     = "AmbatanaUserPictureUpdated"
let kAmbatanaSessionInvalidatedNotification                     = "AmbatanaSessionInvalidated"
let kAmbatanaInvalidCredentialsNotification                     = "AmbatanaInvalidCredentialsNotification"
let kAmbatanaUnableToGetUserLocationNotification                = "AmbatanaUnableToGetUserLocation"
let kAmbatanaUnableToSetUserLocationNotification                = "AmbatanaUnableToSetUserLocationNotification"
let kAmbatanaUserLocationSuccessfullySetNotification            = "AmbatanaUserLocationSuccessfullySetNotification"
let kAmbatanaUserLocationSuccessfullyChangedNotification        = "AmbatanaUserLocationSuccessfullyChangedNotification"

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
}

/** Currencies */

enum Currency: String {
    case Eur = "EUR", Usd = "USD", Gbp = "GBP", Ars = "ARS", Brl = "BRL"
    
    func formattedCurrency(price: Double) -> String {
        switch (self) {
        case .Eur:
            return "\(price)\(self.symbol())"
        case .Usd:
            return "\(self.symbol())\(price)"
        case .Gbp:
            return "\(self.symbol())\(price)"
        case .Ars:
            return "\(self.symbol())\(price)"
        case .Brl:
            return "\(self.symbol())\(price)"
        default:
            return "\(price)"
        }
    }
    
    static func defaultCurrency() -> Currency { return .Usd }
    static func allCurrencies() -> [Currency] { return [.Eur, .Usd, .Gbp, .Ars, .Brl] }
    
    func symbol() -> String {
        switch (self) {
        case .Eur:
            return "€"
        case .Usd:
            return "$"
        case .Gbp:
            return "£"
        case .Ars:
            return "A$"
        case .Brl:
            return "R$"
        default:
            return ""
        }
    }
}

/** Product status */
//- Status: 0 si el producto está pendiente de aprobación, 1 si está aprobado, 2 si está descartado, 3 si está vendido.
enum ProductStatus: Int {
    case Pending = 0, Approved = 1, Discarded = 2, Sold = 3
}
