//
//  ABCore.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct CoreABGroup: ABGroupType {
    private struct Keys {
        static let discardedProducts = "20180219DiscardedProducts"
        static let newUserProfileView = "20180221NewUserProfileView"
        static let searchImprovements = "20180313SearchImprovements"
        static let servicesCategoryEnabled = "20180305ServicesCategoryEnabled"
        static let addPriceTitleDistanceToListings = "20180319AddPriceTitleDistanceToListings"
        static let relaxedSearch = "20180319RelaxedSearch"
    }
    
    let discardedProducts: LeanplumABVariable<Int>
    let newUserProfileView: LeanplumABVariable<Int>
    let searchImprovements: LeanplumABVariable<Int>
    let servicesCategoryEnabled: LeanplumABVariable<Int>
    let addPriceTitleDistanceToListings: LeanplumABVariable<Int>
    let relaxedSearch: LeanplumABVariable<Int>

    let group: ABGroup = .retention
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []
    
    init(discardedProducts: LeanplumABVariable<Int>,
         newUserProfileView: LeanplumABVariable<Int>,
         searchImprovements: LeanplumABVariable<Int>,
         servicesCategoryEnabled: LeanplumABVariable<Int>,
         addPriceTitleDistanceToListings: LeanplumABVariable<Int>,
         relaxedSearch: LeanplumABVariable<Int>) {
        self.discardedProducts = discardedProducts
        self.newUserProfileView = newUserProfileView
        self.searchImprovements = searchImprovements
        self.servicesCategoryEnabled = servicesCategoryEnabled
        self.addPriceTitleDistanceToListings = addPriceTitleDistanceToListings
        self.relaxedSearch = relaxedSearch
        intVariables.append(contentsOf: [discardedProducts,
                                         newUserProfileView,
                                         searchImprovements,
                                         servicesCategoryEnabled,
                                         addPriceTitleDistanceToListings,
                                         relaxedSearch])
    }
    
    static func make() -> CoreABGroup {
        return CoreABGroup(discardedProducts: .makeInt(key: Keys.discardedProducts,
                                                       defaultValue: 0,
                                                       groupType: .core),
                           newUserProfileView: .makeInt(key: Keys.newUserProfileView,
                                                        defaultValue: 0,
                                                        groupType: .core),
                           searchImprovements: .makeInt(key: Keys.searchImprovements,
                                                        defaultValue: 0,
                                                        groupType: .core),
                           servicesCategoryEnabled: .makeInt(key: Keys.servicesCategoryEnabled,
                                                             defaultValue: 0,
                                                             groupType: .products),
                           addPriceTitleDistanceToListings: .makeInt(key: Keys.addPriceTitleDistanceToListings,
                                                                     defaultValue: 0,
                                                                     groupType: .core),
                           relaxedSearch: .makeInt(key: Keys.relaxedSearch,
                                                   defaultValue: 0,
                                                   groupType: .core))
    }
}
