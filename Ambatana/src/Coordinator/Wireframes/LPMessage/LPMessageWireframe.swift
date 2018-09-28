import Foundation

protocol LPMessageNavigator  {
    func closeLPMessage()
}

final class LPMessageWireframe: LPMessageNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func closeLPMessage() {
        root.dismiss(animated: true, completion: nil)
    }
    
}
