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
    case services = 11

    
    static func visibleValues(servicesIncluded: Bool, carsIncluded: Bool, realEstateIncluded: Bool, highlightRealEstate: Bool) -> [ListingCategory] {

        var categories: [ListingCategory] = [.electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                                             .fashionAndAccesories, .babyAndChild]

        if realEstateIncluded {
            categories = highlightRealEstate ? [.realEstate] + categories : categories + [.realEstate]
        }

        if carsIncluded {
            categories = [.cars] + categories
        }

        categories = categories + [.other]

        if servicesIncluded {
            categories = categories + [.services]
        }

        return categories
    }
    
    public static func visibleValuesInFeed(servicesIncluded: Bool, realEstateIncluded: Bool, highlightRealEstate: Bool) -> [ListingCategory] {

        var categories: [ListingCategory] = [.electronics, .homeAndGarden, .sportsLeisureAndGames, .motorsAndAccessories,
                                             .fashionAndAccesories, .babyAndChild, .moviesBooksAndMusic]

        if realEstateIncluded {
            categories = highlightRealEstate ? [.realEstate] + categories : categories + [.realEstate]
        }

        categories = [.cars] + categories  + [.other]

        if servicesIncluded {
            categories = categories + [.services]
        }

        return categories
    }
    
    public var isProduct: Bool {
        switch self {
        case .unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden,
             .moviesBooksAndMusic, .fashionAndAccesories, .babyAndChild, .services, .other:
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
