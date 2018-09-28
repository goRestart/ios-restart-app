import Foundation

protocol ChatInactiveDetailNavigator {
    func closeChatInactiveDetail()
}

final class ChatInactiveDetailWireframe: ChatInactiveDetailNavigator {
    private weak var nc: UINavigationController?

    init(nc: UINavigationController) {
        self.nc = nc
    }

    func closeChatInactiveDetail() {
        nc?.popViewController(animated: true)
    }
}
