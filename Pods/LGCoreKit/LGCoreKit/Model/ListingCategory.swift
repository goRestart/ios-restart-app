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

    
    static func visibleValues(carsIncluded: Bool, realEstateIncluded: Bool, highlightRealEstate: Bool) -> [ListingCategory] {
        if carsIncluded {
            return [.cars] + previousCategories(realEstateIncluded: realEstateIncluded, highlightRealEstate: highlightRealEstate)
        } else {
            return previousCategories(realEstateIncluded: realEstateIncluded, highlightRealEstate: highlightRealEstate)
        }
    }
    
    static func previousCategories(realEstateIncluded: Bool, highlightRealEstate: Bool) -> [ListingCategory] {
        if realEstateIncluded {
            if highlightRealEstate {
                return [.realEstate, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                        .fashionAndAccesories, .babyAndChild, .other]
            }
            return [.electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                    .fashionAndAccesories, .babyAndChild, .realEstate, .other]
        } else {
            return [.electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                    .fashionAndAccesories, .babyAndChild, .other]
        }
    }
    
    public static func visibleValuesInFeed(realEstateIncluded: Bool, highlightRealEstate: Bool) -> [ListingCategory] {
        if realEstateIncluded {
            if highlightRealEstate {
                return [.cars, .realEstate, .electronics, .homeAndGarden, .sportsLeisureAndGames, .motorsAndAccessories,
                        .fashionAndAccesories, .babyAndChild, .moviesBooksAndMusic, .other]
            }
            return [.cars, .electronics, .homeAndGarden, .sportsLeisureAndGames, .motorsAndAccessories,
                    .fashionAndAccesories, .babyAndChild, .moviesBooksAndMusic, .realEstate, .other]
        } else {
            return [.cars, .electronics, .homeAndGarden, .sportsLeisureAndGames, .motorsAndAccessories,
                    .fashionAndAccesories, .babyAndChild, .moviesBooksAndMusic, .other]
        }
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
