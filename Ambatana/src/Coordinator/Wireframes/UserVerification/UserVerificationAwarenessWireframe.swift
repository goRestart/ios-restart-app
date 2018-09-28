import Foundation

final class UserVerificationAwarenessWireframe: UserVerificationAwarenessNavigator {
    private let vc: UIViewController

    init(vc: UIViewController) {
        self.vc = vc
    }

    func closeAwarenessView() {
        vc.dismiss(animated: true, completion: nil)
    }
}
