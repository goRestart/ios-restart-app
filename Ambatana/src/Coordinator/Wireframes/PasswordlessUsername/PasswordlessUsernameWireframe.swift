import Foundation
import LGComponents

final class PasswordlessUsernameWireframe: PasswordlessUsernameNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func closePasswordlessConfirmUsername() {
        root.dismiss(animated: true, completion: nil)
    }

    func openHelp() {
        guard let navController = root as? UINavigationController else { return }
        let vc = LGHelpBuilder.standard(navController).buildHelp()
        navController.pushViewController(vc, animated: true)
    }
}
