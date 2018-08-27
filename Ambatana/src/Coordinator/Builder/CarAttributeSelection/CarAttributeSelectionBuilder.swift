import LGCoreKit

protocol CarAttributesSelectionAssembly {
    func buildCarMakesSelection(_ carMakes: [CarsMake],
                                selectedMake: String?,
                                style: CarAttributeSelectionTableStyle,
                                delegate: CarAttributeSelectionDelegate) -> UIViewController
    func buildCarModelsSelection(_ carModels: [CarsModel],
                                 selectedModel: String?,
                                 style: CarAttributeSelectionTableStyle,
                                 delegate: CarAttributeSelectionDelegate) -> UIViewController
    func buildCarYearSelection(_ yearsList: [Int],
                               selectedYear: Int?,
                               delegate: CarAttributeSelectionDelegate) -> UIViewController
}

enum CarAttributesSelectionBuilder {
    case standard(UINavigationController)
}

extension CarAttributesSelectionBuilder: CarAttributesSelectionAssembly {
    func buildCarMakesSelection(_ carMakes: [CarsMake],
                                selectedMake: String?,
                                style: CarAttributeSelectionTableStyle,
                                delegate: CarAttributeSelectionDelegate) -> UIViewController {
        let vm = CarAttributeSelectionViewModel(carsMakes: carMakes,
                                                selectedMake: selectedMake,
                                                style: style)
        vm.carAttributeSelectionDelegate = delegate
        let vc = CarAttributeSelectionViewController(viewModel: vm)
        return vc
    }

    func buildCarModelsSelection(_ carModels: [CarsModel],
                                 selectedModel: String?,
                                 style: CarAttributeSelectionTableStyle,
                                 delegate: CarAttributeSelectionDelegate) -> UIViewController {
        let vm = CarAttributeSelectionViewModel(carsModels: carModels,
                                                selectedModel: selectedModel,
                                                style: style)
        vm.carAttributeSelectionDelegate = delegate
        let vc = CarAttributeSelectionViewController(viewModel: vm)
        return vc
    }

    func buildCarYearSelection(_ yearsList: [Int],
                               selectedYear: Int?,
                               delegate: CarAttributeSelectionDelegate) -> UIViewController {
        let vm = CarAttributeSelectionViewModel(yearsList: yearsList, selectedYear: selectedYear)
        vm.carAttributeSelectionDelegate = delegate
        let vc = CarAttributeSelectionViewController(viewModel: vm)
        return vc
    }
}
