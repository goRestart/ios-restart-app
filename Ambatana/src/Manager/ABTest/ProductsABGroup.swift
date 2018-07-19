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
        static let predictivePosting = "20180604PredictivePosting"
        static let videoPosting = "20180604VideoPosting"
        static let simplifiedChatButton = "20180611SimplifiedChatButton"
        static let frictionlessShare = "20180716FrictionlessShare"
    }
    
    let servicesCategoryOnSalchichasMenu: LeanplumABVariable<Int>
    let predictivePosting: LeanplumABVariable<Int>
    let videoPosting: LeanplumABVariable<Int>
    let simplifiedChatButton: LeanplumABVariable<Int>
    let frictionlessShare: LeanplumABVariable<Int>

    let group: ABGroup = .products
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(servicesCategoryOnSalchichasMenu: LeanplumABVariable<Int>,
         predictivePosting: LeanplumABVariable<Int>,
         videoPosting: LeanplumABVariable<Int>,
         simplifiedChatButton: LeanplumABVariable<Int>,
         frictionlessShare: LeanplumABVariable<Int>) {
        self.servicesCategoryOnSalchichasMenu = servicesCategoryOnSalchichasMenu
        self.predictivePosting = predictivePosting
        self.videoPosting = videoPosting
        self.simplifiedChatButton = simplifiedChatButton
        self.frictionlessShare = frictionlessShare
        intVariables.append(contentsOf: [servicesCategoryOnSalchichasMenu, predictivePosting, videoPosting,
                                         simplifiedChatButton, frictionlessShare])
    }

    static func make() -> ProductsABGroup {
        return ProductsABGroup(servicesCategoryOnSalchichasMenu: .makeInt(key: Keys.servicesCategoryOnSalchichasMenu,
                                                               defaultValue: 0,
                                                               groupType: .products),
                               predictivePosting: .makeInt(key: Keys.predictivePosting,
                                                           defaultValue: 0,
                                                           groupType: .products),
                               videoPosting: .makeInt(key: Keys.videoPosting,
                                                      defaultValue: 0,
                                                      groupType: .products),
                               simplifiedChatButton: .makeInt(key: Keys.simplifiedChatButton,
                                                              defaultValue: 0,
                                                              groupType: .products),
                               frictionlessShare: .makeInt(key: Keys.frictionlessShare,
                                                           defaultValue: 0,
                                                           groupType: .products))
    }
}

