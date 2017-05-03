//
//  CarAttributeSelectionViewModel.swift
//  LetGo
//
//  Created by Dídac on 24/04/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

extension CarDetailType {
    var navigationTitle: String {
        switch self {
        case .make:
            return LGLocalizedString.postCategoryDetailCarMake
        case .model:
            return LGLocalizedString.postCategoryDetailCarModel
        case .year:
            return LGLocalizedString.postCategoryDetailCarYear
        }
    }
}

protocol CarAttributeSelectionViewModelDelegate: BaseViewModelDelegate {}

protocol CarAttributeSelectionDelegate: class {
    func didSelectMake(makeId: String, makeName: String)
    func didSelectModel(modelId: String, modelName: String)
    func didSelectYear(year: Int)
}

class CarAttributeSelectionViewModel : BaseViewModel {

    weak var delegate: CarAttributeSelectionViewModelDelegate?
    weak var choiceDelegate: CarAttributeSelectionDelegate?

    var title: String
    var detailType: CarDetailType
    var selectedIndex: Int?


    let wrappedInfoList = Variable<[CarInfoWrapper]>([])

    init(carsMakes: [CarsMake], selectedMake: String?) {
        self.detailType = .make
        self.title = detailType.navigationTitle
        if let selectedMake = selectedMake {
            self.selectedIndex = carsMakes.map {$0.makeId}.index(of: selectedMake)
        }
        wrappedInfoList.value = carsMakes.map { CarInfoWrapper(id: $0.makeId, name: $0.makeName, type: .make )}
    }

    init(carsModels: [CarsModel], selectedModel: String?) {
        self.detailType = .model
        self.title = detailType.navigationTitle
        if let selectedModel = selectedModel {
            self.selectedIndex = carsModels.map {$0.modelId}.index(of: selectedModel)
        }
        wrappedInfoList.value = carsModels.map { CarInfoWrapper(id: $0.modelId, name: $0.modelName, type: .model )}
    }

    init(yearsList: [Int], selectedYear: Int?) {
        self.detailType = .year
        self.title = detailType.navigationTitle
        if let selectedYear = selectedYear {
            self.selectedIndex = yearsList.index(of: selectedYear)
        }
        wrappedInfoList.value = yearsList.map { CarInfoWrapper(id: String($0), name: String($0), type: .year )}
    }

    func carInfoSelected(id: String, name: String, type: CarDetailType) {
        switch type {
        case .make:
            choiceDelegate?.didSelectMake(makeId: id, makeName: name)
        case .model:
            choiceDelegate?.didSelectModel(modelId: id, modelName: name)
        case .year:
            guard let year = Int(id) else { return }
            choiceDelegate?.didSelectYear(year: year)
        }
        closeAttributesChoice()
    }
}

extension CarAttributeSelectionViewModel {
    fileprivate func closeAttributesChoice() {
        delegate?.vmPop()
    }
}
