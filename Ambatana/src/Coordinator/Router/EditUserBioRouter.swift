import Foundation

final class EditUserBioRouter: EditUserBioNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeEditUserBio() {
        navigationController?.popViewController(animated: true)
    }
}
