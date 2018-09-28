final class EditLocationStandardWireframe: EditLocationNavigator {
    private weak var nc: UINavigationController?

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeEditLocation() {
        nc?.popViewController(animated: true)
    }
}
