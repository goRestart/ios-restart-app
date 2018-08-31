final class QuickLocationFiltersStandardWireframe: QuickLocationFiltersNavigator {
    private let nc: UINavigationController

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeQuickLocationFilters() {
        nc.popViewController(animated: true)
    }
}
