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

    static var allValues: [ListingCategory] = [.unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames,
                                               .homeAndGarden, .moviesBooksAndMusic, .fashionAndAccesories, .babyAndChild,
                                               .other, .cars, .realEstate, .services]
    
    public var isProduct: Bool {
        switch self {
        case .unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden,
             .moviesBooksAndMusic, .fashionAndAccesories, .babyAndChild, .other:
            return true
        case .cars, .realEstate, .services:
            return false
        }
    }
    
    public var isCar: Bool {
        return self == .cars
    }
    
    public var isRealEstate: Bool {
        return self == .realEstate
    }
    
    public var isServices: Bool {
        return self == .services
    }
    
    public var isCategoryEditable: Bool {
        switch self {
        case .realEstate, .cars, .services:
            return false
        case .babyAndChild, .electronics, .fashionAndAccesories,
             .homeAndGarden, .motorsAndAccessories, .moviesBooksAndMusic,
             .other, .sportsLeisureAndGames, .unassigned:
            return true
        }
    }

    public var isCategoryNotEditable: Bool {
        return !isCategoryEditable
    }
}
