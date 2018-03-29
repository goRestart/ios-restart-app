//
//  ABRealEstate.swift
//  LetGo
//
//  Created by Facundo Menzella on 29/03/2018.
//  Copyright © 2018 Ambatana. All rights reserved.
//

import Foundation

struct RealEstateGroup: ABGroupType {
    private struct Keys {
        static let realEstateNewCopy = "20180126RealEstateNewCopy"
        static let increaseNumberOfPictures = "20180314IncreaseNumberOfPictures"
        static let realEstateTutorial = "20180309RealEstateTutorial"
        static let summaryAsFirstStep = "20180320SummaryAsFirstStep"
    }
    let realEstateNewCopy: LeanplumABVariable<Int>
    let increaseNumberOfPictures: LeanplumABVariable<Int>
    let realEstateTutorial: LeanplumABVariable<Int>
    let summaryAsFirstStep: LeanplumABVariable<Int>

    let group: ABGroup = .realEstate
    var intVariables: [LeanplumABVariable<Int>] = []
    var stringVariables: [LeanplumABVariable<String>] = []
    var floatVariables: [LeanplumABVariable<Float>] = []
    var boolVariables: [LeanplumABVariable<Bool>] = []

    init(realEstateNewCopy: LeanplumABVariable<Int>,
         increaseNumberOfPictures: LeanplumABVariable<Int>,
         realEstateTutorial: LeanplumABVariable<Int>,
         summaryAsFirstStep: LeanplumABVariable<Int>) {
        self.realEstateNewCopy = realEstateNewCopy
        self.increaseNumberOfPictures = increaseNumberOfPictures
        self.realEstateTutorial = realEstateTutorial
        self.summaryAsFirstStep = summaryAsFirstStep

        intVariables.append(contentsOf: [realEstateNewCopy, increaseNumberOfPictures, realEstateTutorial, summaryAsFirstStep])
    }

    static func make() -> RealEstateGroup {
        return RealEstateGroup(realEstateNewCopy: .makeInt(key: Keys.realEstateNewCopy, defaultValue: 0, groupType: .realEstate),
                               increaseNumberOfPictures: .makeInt(key: Keys.increaseNumberOfPictures, defaultValue: 0, groupType: .realEstate),
                               realEstateTutorial: .makeInt(key: Keys.realEstateTutorial, defaultValue: 0, groupType: .realEstate),
                               summaryAsFirstStep: .makeInt(key: Keys.summaryAsFirstStep, defaultValue: 0, groupType: .realEstate))
    }
}
