final class QuickLocationFiltersStandardWireframe: QuickLocationFiltersNavigator {
    private weak var nc: UINavigationController?

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeQuickLocationFilters() {
        nc?.popViewController(animated: true)
    }
}
