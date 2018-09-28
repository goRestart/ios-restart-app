import Foundation
import LGComponents

protocol RememberPasswordNavigator: class {
    func closeRememberPassword()
}

final class RememberPasswordWireframe: RememberPasswordNavigator {
    private let root: UIViewController
    
    init(root: UIViewController) {
        self.root = root
    }
    
    func closeRememberPassword() {
        root.popViewController(animated: true)
    }
}
