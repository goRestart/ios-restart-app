//
//  CategoriesTabNavigator.swift
//  LetGo
//
//  Created by Albert Hernández López on 01/08/16.
//  Copyright © 2016 Ambatana. All rights reserved.
//

protocol CategoriesTabNavigator: MainTabNavigator {
    func openMainProducts(with filters: ProductFilters)
}
