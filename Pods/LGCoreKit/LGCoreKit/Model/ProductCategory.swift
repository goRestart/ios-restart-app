//
//  ProductCategory.swift
//  LGCoreKit
//
//  Created by AHL on 28/6/15.
//  Copyright (c) 2015 Ambatana Inc. All rights reserved.
//

public enum ProductCategory: Int {
    case Unassigned = 0, Electronics = 1, CarsAndMotors = 2, SportsLeisureAndGames = 3, HomeAndGarden = 4,
    MoviesBooksAndMusic = 5, FashionAndAccesories = 6, BabyAndChild = 7, Other = 8

    static func allValues() -> [ProductCategory] {
        return [.Unassigned] + visibleValues()
    }
    static func visibleValues() -> [ProductCategory] {
        return [.Electronics, .CarsAndMotors, .SportsLeisureAndGames, .HomeAndGarden, .MoviesBooksAndMusic,
                .FashionAndAccesories, .BabyAndChild, .Other]
    }
}
