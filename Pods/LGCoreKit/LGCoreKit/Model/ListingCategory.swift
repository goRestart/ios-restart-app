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

    static func allValues() -> [ListingCategory] {
        // TODO: move .cars to visible once the become available
        return [.unassigned, .cars] + visibleValues()
    }
    static public func visibleValues() -> [ListingCategory] {
        return [.electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                .fashionAndAccesories, .babyAndChild, .other]
    }
    
    static public func visibleValuesInFeed() -> [ListingCategory] {
        return [.cars, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                .fashionAndAccesories, .babyAndChild, .other]
    }
    
    public var isProduct: Bool {
        switch self {
        case .unassigned, .electronics, .motorsAndAccessories, .sportsLeisureAndGames, .homeAndGarden,
             .moviesBooksAndMusic, .fashionAndAccesories, .babyAndChild, .other:
            return true
        case .cars:
            return false
        }
    }
    
    public var isCar: Bool {
        return self == .cars
    }
}
