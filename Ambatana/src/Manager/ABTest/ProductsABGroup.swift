//
//  ProductsABGroup.swift
//  LetGo
//
//  Created by Álvaro Murillo del Puerto on 8/5/18.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct ProductsABGroup: ABGroupType {

    private struct Keys {
        static let servicesCategoryOnSalchichasMenu = "20180508ServicesCategoryOnSalchichasMenu"
    }
    
    let servicesCategoryOnSalchichasMenu: LeanplumABVariable<Int>

    let group: ABGroup = .products
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(servicesCategoryOnSalchichasMenu: LeanplumABVariable<Int>) {
        self.servicesCategoryOnSalchichasMenu = servicesCategoryOnSalchichasMenu
        intVariables.append(contentsOf: [servicesCategoryOnSalchichasMenu])
    }

    static func make() -> ProductsABGroup {
        return ProductsABGroup(servicesCategoryOnSalchichasMenu: .makeInt(key: Keys.servicesCategoryOnSalchichasMenu,
                                                               defaultValue: 0,
                                                               groupType: .products))
    }
}

