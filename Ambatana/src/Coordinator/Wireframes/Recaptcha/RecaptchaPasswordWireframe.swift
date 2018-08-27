import Foundation
import LGComponents

protocol RecaptchaNavigator {
    func closeRecaptcha()
}

final class RecaptchaPasswordWireframe: RecaptchaNavigator {
    private let root: UIViewController
    
    init(root: UIViewController) {
        self.root = root
    }
    
    func closeRecaptcha() {
        root.dismiss(animated: true, completion: nil)
    }
}

