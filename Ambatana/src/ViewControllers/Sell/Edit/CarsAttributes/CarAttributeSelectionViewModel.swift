//
//  CarAttributeSelectionViewModel.swift
//  LetGo
//
//  Created by Dídac on 24/04/17.
//  Copyright © 2017 Ambatana. All rights reserved.
//

import RxSwift
import LGCoreKit

enum CarAttributeSelectionTableStyle {
    case edit
    case filter
}

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
    weak var carAttributeSelectionDelegate: CarAttributeSelectionDelegate?

    var title: String
    var detailType: CarDetailType
    var selectedIndex: Int?
    var style: CarAttributeSelectionTableStyle = .edit


    let wrappedInfoList = Variable<[CarInfoWrapper]>([])

    init(carsMakes: [CarsMake], selectedMake: String?, style: CarAttributeSelectionTableStyle) {
        self.detailType = .make
        self.title = detailType.navigationTitle
        self.style = style
        var carInfoWrapperList: [CarInfoWrapper] = carsMakes.map { CarInfoWrapper(id: $0.makeId, name: $0.makeName, type: .make )}
        switch style {
        case .filter:
            carInfoWrapperList.append(CarInfoWrapper(id: "", name: LGLocalizedString.categoriesOther, type: .make))
        case .edit:
            break
        }

        if let selectedMake = selectedMake {
            self.selectedIndex = carInfoWrapperList.map {$0.id}.index(of: selectedMake)
        }
        wrappedInfoList.value = carInfoWrapperList
    }

    init(carsModels: [CarsModel], selectedModel: String?, style: CarAttributeSelectionTableStyle) {
        self.detailType = .model
        self.title = detailType.navigationTitle
        self.style = style
        var carInfoWrapperList: [CarInfoWrapper] = carsModels.map { CarInfoWrapper(id: $0.modelId, name: $0.modelName, type: .model )}
        switch style {
        case .filter:
            carInfoWrapperList.append(CarInfoWrapper(id: "", name: LGLocalizedString.categoriesOther, type: .model))
        case .edit:
            break
        }

        if let selectedModel = selectedModel {
            self.selectedIndex = carInfoWrapperList.map {$0.id}.index(of: selectedModel)
        }
        wrappedInfoList.value = carInfoWrapperList
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
            carAttributeSelectionDelegate?.didSelectMake(makeId: id, makeName: name)
        case .model:
            carAttributeSelectionDelegate?.didSelectModel(modelId: id, modelName: name)
        case .year:
            guard let year = Int(id) else { return }
            carAttributeSelectionDelegate?.didSelectYear(year: year)
        }
        closeAttributesChoice()
    }
}

extension CarAttributeSelectionViewModel {
    fileprivate func closeAttributesChoice() {
        delegate?.vmPop()
    }
}
