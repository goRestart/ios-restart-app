//
//  CommonDataTypes.swift
//  Ambatana
//
//  Created by Nacho on 12/2/15.
//  Copyright (c) 2015 Ignacio Nieto Carvajal. All rights reserved.
//

import Foundation

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
    case Eur = "EUR", Usd = "USD", Gbp = "GBP"
    
    func formattedCurrency(price: Double) -> String {
        switch (self) {
        case .Eur:
            return "\(price)\(self.symbol())"
        case .Usd:
            return "\(self.symbol())\(price) "
        case .Gbp:
            return "\(self.symbol())\(price) "
        default:
            return "\(price)"
        }
    }
    
    func symbol() -> String {
        switch (self) {
        case .Eur:
            return "€"
        case .Usd:
            return "$"
        case .Gbp:
            return "£"
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
