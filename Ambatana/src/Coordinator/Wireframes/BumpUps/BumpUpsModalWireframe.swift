final class BumpUpsModalWireframe: BumpUpNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func bumpUpDidCancel() {
        root.dismiss(animated: true, completion: nil)
    }
    func bumpUpDidFinish(completion: (() -> Void)?) {
        root.dismiss(animated: true, completion: completion)
    }
}
