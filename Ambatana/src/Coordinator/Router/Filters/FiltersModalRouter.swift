final class FiltersModalRouter: FiltersRouter {
    private weak var controller: UIViewController?
    private weak var navigationController: UINavigationController?
    
    init(controller: UIViewController) {
        self.controller = controller
        navigationController = controller.navigationController
    }
    
    func openServicesDropdown(viewModel: DropdownViewModel) {
        navigationController?.pushViewController(
            DropdownViewController(withViewModel: viewModel),
            animated: true
        )
    }
    
    func openEditLocation(withViewModel viewModel: EditLocationViewModel) {
        navigationController?.pushViewController(
            EditLocationViewController(viewModel: viewModel),
            animated: true
        )
    }
    
    func openCarAttributeSelection(withViewModel viewModel: CarAttributeSelectionViewModel) {
        navigationController?.pushViewController(
            CarAttributeSelectionViewController(viewModel: viewModel),
            animated: true
        )
    }
    
    func openListingAttributePicker(viewModel: ListingAttributePickerViewModel) {
        let vc = ListingAttributePickerViewController(viewModel: viewModel)
        viewModel.delegate = vc
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func closeFilters() {
        controller?.dismiss(animated: true, completion: nil)
    }
}
