protocol EditEmailNavigator: class {
    func closeEditEmail()
}


final class EditEmailWireframe: EditEmailNavigator {
    private let nc: UINavigationController

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeEditEmail() {
        nc.popViewController(animated: true)
    }

}
