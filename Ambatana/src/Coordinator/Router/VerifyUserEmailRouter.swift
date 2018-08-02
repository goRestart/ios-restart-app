import Foundation

final class VerifyUserEmailRouter: VerifyUserEmailNavigator {
    private weak var navigationController: UINavigationController!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeEmailVerification() {
        navigationController?.popViewController(animated: true)
    }
}
