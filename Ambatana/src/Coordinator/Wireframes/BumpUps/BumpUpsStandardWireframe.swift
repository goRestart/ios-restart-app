final class BumpUpsStandardWireframe: BumpUpNavigator {
    private let nc: UINavigationController

    init(nc: UINavigationController) {
        self.nc = nc
    }
    func bumpUpDidCancel() {
        nc.popViewController(animated: true)
    }
    func bumpUpDidFinish(completion: (() -> Void)?) {
        nc.popViewController(animated: true, completion: completion)
    }
}
