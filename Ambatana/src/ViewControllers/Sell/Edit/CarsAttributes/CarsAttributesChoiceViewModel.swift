//
//  CarsAttributesChoiceViewModel.swift
//  LetGo
//
//  Created by Dídac on 24/04/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

enum CarsAttributeType {
    case make(makesList: [CarsMake])
    case model(modelsList: [CarsModel])
    case year(yearsList: [Int])

    var list: [Any] {
        switch self {
        case let .make(makes):
            return makes
        case let .model(models):
            return models
        case let .year(years):
            return years
        }
    }

    func itemAtPosition(position: Int) -> Any? {
        guard 0..<list.count ~= position else { return nil }
        return list[position]
    }

    func nameForItemAtPosition(position: Int) -> String {
        switch self {
        case .make:
            guard let currentMake = itemAtPosition(position: position) as? CarsMake else { return "" }
            return currentMake.makeName
        case .model:
            guard let currentModel = itemAtPosition(position: position) as? CarsModel else { return "" }
            return currentModel.modelName
        case .year:
            guard let currentYear = itemAtPosition(position: position) as? Int else { return "" }
            return "\(currentYear)"
        }
    }
}

protocol CarsAttributesChoiceViewModelDelegate: BaseViewModelDelegate {}

protocol CarsAttributesChoiceDelegate: class {
    func didSelectMake(make: CarsMake)
    func didSelectModel(model: CarsModel)
    func didSelectYear(year: Int)
}

class CarsAttributesChoiceViewModel : BaseViewModel {

    weak var delegate: CarsAttributesChoiceViewModelDelegate?
    weak var choiceDelegate: CarsAttributesChoiceDelegate?

    let carsAttributeType = Variable<CarsAttributeType>(.make(makesList: []))

    // init to show Makes table
    init(carsMakes: [CarsMake]) {
        carsAttributeType.value = .make(makesList: carsMakes)
    }

    // init to show Models table
    init(carsModels: [CarsModel]) {
        carsAttributeType.value = .model(modelsList: carsModels)
    }

    // init to show Years table
    init(yearsList: [Int]) {
        carsAttributeType.value = .year(yearsList: yearsList)
    }

    func makeSelected(make: CarsMake) {
        choiceDelegate?.didSelectMake(make: make)
        closeAttributesChoice()
    }

    func modelSelected(model: CarsModel) {
        choiceDelegate?.didSelectModel(model: model)
        closeAttributesChoice()
    }

    func yearSelected(year: Int) {
        choiceDelegate?.didSelectYear(year: year)
        closeAttributesChoice()
    }

    private func closeAttributesChoice() {
        delegate?.vmPop()
    }
} 
