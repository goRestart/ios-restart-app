import LGComponents

final class ExpressChatWireframe: ExpressChatNavigator {
    private let root: UIViewController

    init(root: UIViewController) {
        self.root = root
    }

    func closeExpressChat(autoFadingOutMessage message: String?) {
        if let message = message {
            root.dismiss(animated: true, completion: { [weak root] in
                root?.showAutoFadingOutMessageAlert(message: message)
            })
        } else {
            root.dismiss(animated: true, completion: nil)
        }
    }
}
