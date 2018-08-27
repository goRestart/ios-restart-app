final class BumpUpsStandardWireframe: BumpUpNavigator {
    private let nc: UIViewController

    init(nc: UINavigationController) {
        self.nc = nc
    }
    func bumpUpDidCancel() {
        nc.popViewController(animated: true, completion: nil)
    }
    func bumpUpDidFinish(completion: (() -> Void)?) {
        nc.popViewController(animated: true, completion: completion)
    }
}
