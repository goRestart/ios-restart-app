//
//  ListingCategory.swift
//  LGCoreKit
//
//  Created by AHL on 28/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public enum ListingCategory: Int {
    case unassigned = 0
    case electronics = 1
    case motorsAndAccessories = 2
    case sportsLeisureAndGames = 3
    case homeAndGarden = 4
    case moviesBooksAndMusic = 5
    case fashionAndAccesories = 6
    case babyAndChild = 7
    case other = 8
    case cars = 9
    case realEstate = 10

    
    static func visibleValues(filtered: Bool) -> [ListingCategory] {
        if filtered {
            return previousCategories()
        } else {
            return [.cars] + previousCategories()
        }
    }
    
    static func previousCategories() -> [ListingCategory] {
        return [.electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                .fashionAndAccesories, .babyAndChild, .other]
    }
    
    
    public static func visibleValuesInFeed() -> [ListingCategory] {
        return [.cars, .electronics, .homeAndGarden, .sportsLeisureAndGames, .motorsAndAccessories,
                .fashionAndAccesories, .babyAndChild, .moviesBooksAndMusic, .other]
    }
    
    public var isProduct: Bool {
        switch self {
        case .unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden,
             .moviesBooksAndMusic, .fashionAndAccesories, .babyAndChild, .other:
            return true
        case .cars, .realEstate:
            return false
        }
    }
    
    public var isCar: Bool {
        return self == .cars
    }
    
    public var isRealEstate: Bool {
        return self == .realEstate
    }
}
