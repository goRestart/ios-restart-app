//
//  ProductCategory.swift
//  LGCoreKit
//
//  Created by AHL on 28/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public enum ProductCategory: Int {
    case unassigned = 0, electronics = 1, carsAndMotors = 2, sportsLeisureAndGames = 3, homeAndGarden = 4,
    moviesBooksAndMusic = 5, fashionAndAccesories = 6, babyAndChild = 7, other = 8

    static func allValues() -> [ProductCategory] {
        return [.unassigned] + visibleValues()
    }
    static func visibleValues() -> [ProductCategory] {
        return [.electronics, .carsAndMotors, .sportsLeisureAndGames, .homeAndGarden, .moviesBooksAndMusic,
                .fashionAndAccesories, .babyAndChild, .other]
    }
}
