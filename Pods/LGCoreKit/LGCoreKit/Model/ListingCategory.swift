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
    case carsAndMotors = 2
    case sportsLeisureAndGames = 3
    case homeAndGarden = 4
    case moviesBooksAndMusic = 5
    case fashionAndAccesories = 6
    case babyAndChild = 7
    case other = 8
    case cars = 9

    static func allValues() -> [ListingCategory] {
        return [.unassigned] + visibleValues()
    }
    static func visibleValues() -> [ListingCategory] {
        return [.electronics, .carsAndMotors, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                .fashionAndAccesories, .babyAndChild, .other, .cars]
    }
}
