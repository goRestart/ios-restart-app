final class QuickLocationFiltersModalWireframe: QuickLocationFiltersNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func closeQuickLocationFilters() {
        root.dismiss(animated: true, completion: nil)
    }
}
