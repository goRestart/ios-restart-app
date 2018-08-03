import Foundation

protocol LPMessageNavigator: class {
    func closeLPMessage()
}

final class LPMessageRouter: LPMessageNavigator {
    private weak var root: UIViewController?

    init(root: UIViewController) {
        self.root = root
    }

    func closeLPMessage() {
        root?.dismiss(animated: true, completion: nil)
    }
    
}
