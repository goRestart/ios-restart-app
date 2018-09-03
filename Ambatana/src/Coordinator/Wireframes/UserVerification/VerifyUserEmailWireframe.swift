import Foundation

final class VerifyUserEmailWireframe: VerifyUserEmailNavigator {
    private let nc: UINavigationController

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeEmailVerification() {
        nc.popViewController(animated: true)
    }
}
