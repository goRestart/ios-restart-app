final class EditLocationStandardWireframe: EditLocationNavigator {
    private let nc: UINavigationController

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeEditLocation() {
        nc.popViewController(animated: true)
    }
}
