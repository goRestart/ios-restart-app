import Foundation

protocol ChatInactiveDetailNavigator {
    func closeChatInactiveDetail()
}

final class ChatInactiveDetailRouter: ChatInactiveDetailNavigator {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func closeChatInactiveDetail() {
        navigationController?.popViewController(animated: true)
    }
}
